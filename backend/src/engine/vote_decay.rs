use chrono::{DateTime, Utc};

const HALF_LIFE_DAYS: f64 = 30.0; // Vote weight halves every 30 days (#5.2)

/// Calculate exponential time-decay weight ($w = e^{-\lambda \cdot t}$) for a vote based on its age.
pub fn decay_weight(vote_created: DateTime<Utc>, now: DateTime<Utc>) -> f64 {
    let age_seconds = (now - vote_created).num_seconds();
    if age_seconds <= 0 {
        return 1.0;
    }
    let age_days = age_seconds as f64 / 86400.0;
    let lambda = (2.0_f64.ln()) / HALF_LIFE_DAYS;
    (-lambda * age_days).exp()
}

/// Calculate weighted helpfulness approval ratio (0.0 to 1.0) given a series of votes (is_upvote, created_at).
pub fn weighted_approval_ratio(votes: &[(bool, DateTime<Utc>)]) -> f64 {
    if votes.is_empty() {
        return 1.0; // Default 100% approval if no votes cast
    }

    let now = Utc::now();
    let mut weighted_up = 0.0;
    let mut weighted_total = 0.0;

    for (is_upvote, created_at) in votes {
        let weight = decay_weight(*created_at, now);
        weighted_total += weight;
        if *is_upvote {
            weighted_up += weight;
        }
    }

    if weighted_total == 0.0 {
        1.0
    } else {
        weighted_up / weighted_total
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::Duration;

    #[test]
    fn test_decay_weight_fresh_vote() {
        let now = Utc::now();
        let weight = decay_weight(now, now);
        assert!((weight - 1.0).abs() < 0.001);
    }

    #[test]
    fn test_decay_weight_30_days_old() {
        let now = Utc::now();
        let old_vote = now - Duration::days(30);
        let weight = decay_weight(old_vote, now);
        assert!((weight - 0.5).abs() < 0.01); // Halves after 30 days
    }
}
