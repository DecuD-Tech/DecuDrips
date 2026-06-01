(function () {
  const BACKEND_URL = 'http://localhost:8080/api/v1';

  class DocuDripWidget extends HTMLElement {
    constructor() {
      super();
      this.attachShadow({ mode: 'open' });
      this.streamId = null;
      this.rating = null;
      this.hasVoted = false;
    }

    async connectedCallback() {
      this.streamId = this.getAttribute('data-stream');
      if (!this.streamId) {
        this.shadowRoot.innerHTML = `<div style="color: #ff007f; font-family: sans-serif; font-size: 0.8rem; font-weight: bold;">[DocuDrip] Error: Missing data-stream attribute</div>`;
        return;
      }

      // Check if user has already voted on this stream locally
      this.hasVoted = localStorage.getItem(`docudrip_voted_${this.streamId}`) === 'true';

      // Load widget stylesheet
      const linkElem = document.createElement('link');
      linkElem.setAttribute('rel', 'stylesheet');
      linkElem.setAttribute('href', 'http://localhost:8080/widget.css'); // Loaded from backend static mount or dev port
      this.shadowRoot.appendChild(linkElem);

      // Create main widget card container
      this.container = document.createElement('div');
      this.container.className = 'docudrip-widget-card';
      this.shadowRoot.appendChild(this.container);

      await this.fetchStreamRating();
      this.render();
    }

    async fetchStreamRating() {
      try {
        const response = await fetch(`${BACKEND_URL}/streams/${this.streamId}`);
        if (response.ok) {
          const data = await response.json();
          this.rating = Math.round(data.approval_ratio * 100);
        }
      } catch (err) {
        console.error('[DocuDrip Widget] Error loading stream:', err);
      }
    }

    async submitVote(isUpvote) {
      if (this.hasVoted) return;

      try {
        const response = await fetch(`${BACKEND_URL}/streams/${this.streamId}/vote`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            is_upvote: isUpvote,
            voter_ip: null, // Let backend automatically extract IP
          }),
        });

        if (response.ok || response.status === 409) {
          this.hasVoted = true;
          localStorage.setItem(`docudrip_voted_${this.streamId}`, 'true');
          await this.fetchStreamRating();
          this.render();
        } else {
          console.error('[DocuDrip Widget] Failed to submit vote');
        }
      } catch (err) {
        console.error('[DocuDrip Widget] Network error:', err);
      }
    }

    render() {
      const showRating = this.rating !== null;
      let ratingColor = '#ff007f'; // Pink
      if (this.rating >= 90) ratingColor = '#10b981'; // Green
      else if (this.rating >= 75) ratingColor = '#f59e0b'; // Amber

      this.container.innerHTML = `
        <div class="widget-brand">
          <svg class="brand-drip" viewBox="0 0 24 24" width="12" height="12" fill="#00f0ff" stroke="#00f0ff" stroke-width="2">
            <path d="M12 22a7 7 0 0 0 7-7c0-4.3-7-13-7-13S5 10.7 5 15a7 7 0 0 0 7 7z" />
          </svg>
          <span>DocuDrip Protocol</span>
        </div>
        <div class="widget-question">
          ${this.hasVoted ? 'Thank you for your feedback!' : 'Was this documentation page helpful?'}
        </div>
        
        ${!this.hasVoted ? `
          <div class="widget-actions">
            <button class="widget-btn upvote-btn">
              <svg viewBox="0 0 24 24" width="14" height="14" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round">
                <path d="M14 9V5a3 3 0 0 0-3-3l-4 9v11h11.28a2 2 0 0 0 2-1.7l1.38-9a2 2 0 0 0-2-2.3zM7 22H4a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2h3" />
              </svg>
              <span>Helpful</span>
            </button>
            <button class="widget-btn downvote-btn">
              <svg viewBox="0 0 24 24" width="14" height="14" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round">
                <path d="M10 15v4a3 3 0 0 0 3 3l4-9V2H5.72a2 2 0 0 0-2 1.7l-1.38 9a2 2 0 0 0 2 2.3zm7-13h3a2 2 0 0 1 2 2v7a2 2 0 0 1-2 2h-3" />
              </svg>
              <span>Unhelpful</span>
            </button>
          </div>
        ` : `
          <div class="widget-success-check">
            <svg viewBox="0 0 24 24" width="20" height="20" stroke="#10b981" stroke-width="2.5" fill="none" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="20 6 9 17 4 12" />
            </svg>
            <span>Vote successfully logged to ledger</span>
          </div>
        `}

        ${showRating ? `
          <div class="widget-meta">
            Helpfulness Rating: <span style="color: ${ratingColor}; font-weight: bold;">${this.rating}%</span>
          </div>
        ` : ''}
      `;

      // Wire button click handlers if user hasn't voted yet
      if (!this.hasVoted) {
        const upBtn = this.container.querySelector('.upvote-btn');
        const downBtn = this.container.querySelector('.downvote-btn');

        if (upBtn) upBtn.addEventListener('click', () => this.submitVote(true));
        if (downBtn) downBtn.addEventListener('click', () => this.submitVote(false));
      }
    }
  }

  // Register custom component if not already registered
  if (!customElements.get('docudrip-widget')) {
    customElements.define('docudrip-widget', DocuDripWidget);
  }
})();
