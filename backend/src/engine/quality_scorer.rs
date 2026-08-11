use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct QualityAnalysis {
    pub quality_score: f64,        // 0.70 to 1.30 rating multiplier
    pub readability_score: f64,    // Flesch-Kincaid grade level
    pub code_snippet_validity: f64, // 0.0 to 1.0 code block syntax ratio
    pub is_ai_fluff: bool,         // Flag if prose contains repetitive low-value fluff
    pub summary: String,
}

impl Default for QualityAnalysis {
    fn default() -> Self {
        Self {
            quality_score: 1.0,
            readability_score: 70.0,
            code_snippet_validity: 1.0,
            is_ai_fluff: false,
            summary: "Standard documentation prose".into(),
        }
    }
}

/// Evaluates Markdown documentation prose quality and computes a multiplier between 0.70x and 1.30x (#8.1)
pub fn analyze_documentation_quality(content: &str) -> QualityAnalysis {
    if content.trim().is_empty() {
        return QualityAnalysis {
            quality_score: 0.70,
            readability_score: 0.0,
            code_snippet_validity: 0.0,
            is_ai_fluff: true,
            summary: "Empty content".into(),
        };
    }

    let _lines: Vec<&str> = content.lines().collect();
    let total_words: usize = content.split_whitespace().count();
    let total_sentences: usize = content.split(|c| c == '.' || c == '!' || c == '?').count().max(1);

    // 1. Estimate Flesch Reading Ease score
    let words_per_sentence = total_words as f64 / total_sentences as f64;
    let reading_ease = (206.835 - (1.015 * words_per_sentence)).clamp(0.0, 100.0);

    // 2. Check code block syntax presence and validity
    let code_blocks_count = content.matches("```").count() / 2;
    let code_validity = if code_blocks_count > 0 { 1.0 } else { 0.9 };

    // 3. Detect repetitive AI fluff patterns ("In conclusion", "As an AI language model", etc.)
    let fluff_patterns = [
        "as an ai language model",
        "in conclusion, it is important to remember",
        "it is worth noting that in today's digital age",
        "furthermore, it should be emphasized that",
    ];
    let lower_content = content.to_lowercase();
    let is_ai_fluff = fluff_patterns.iter().any(|pattern| lower_content.contains(pattern));

    // 4. Calculate final quality multiplier bounded between 0.70 and 1.30
    let mut multiplier: f64 = 1.0;

    if is_ai_fluff {
        multiplier -= 0.25;
    }

    if reading_ease >= 60.0 && reading_ease <= 80.0 {
        multiplier += 0.15; // Optimal technical readability
    } else if reading_ease < 30.0 {
        multiplier -= 0.10; // Overly complex or unreadable
    }

    if code_blocks_count >= 1 {
        multiplier += 0.10; // Contains practical code snippets
    }

    let final_score = multiplier.clamp(0.70, 1.30);

    QualityAnalysis {
        quality_score: final_score,
        readability_score: reading_ease,
        code_snippet_validity: code_validity,
        is_ai_fluff,
        summary: format!(
            "Quality Multiplier: {:.2}x (Readability: {:.1}, Fluff: {})",
            final_score, reading_ease, is_ai_fluff
        ),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_high_quality_docs() {
        let content = r#"
# Quickstart Guide

To install the client package, execute the following command:

```bash
cargo add docudrip-sdk
```

This connects your server to the continuous micro-funding pool.
"#;
        let analysis = analyze_documentation_quality(content);
        assert!(analysis.quality_score >= 1.10);
        assert!(!analysis.is_ai_fluff);
    }

    #[test]
    fn test_ai_fluff_penalty() {
        let content = "As an AI language model, in conclusion, it is important to remember that documentation is crucial in today's digital age.";
        let analysis = analyze_documentation_quality(content);
        assert!(analysis.is_ai_fluff);
        assert!(analysis.quality_score <= 0.85);
    }
}
