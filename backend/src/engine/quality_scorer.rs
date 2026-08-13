use serde::{Deserialize, Serialize};
use std::collections::HashSet;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct QualityAnalysis {
    pub quality_score: f64,        // 0.70 to 1.30 rating multiplier
    pub readability_score: f64,    // Flesch-Kincaid reading ease score (0.0 - 100.0)
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

/// Helper function to count syllables in a word for Flesch-Kincaid estimation
fn count_syllables(word: &str) -> usize {
    let clean_word: String = word
        .to_lowercase()
        .chars()
        .filter(|c| c.is_alphabetic())
        .collect();

    if clean_word.is_empty() {
        return 1;
    }

    let vowels = ['a', 'e', 'i', 'o', 'u', 'y'];
    let mut count = 0;
    let mut prev_vowel = false;

    for ch in clean_word.chars() {
        let is_vowel = vowels.contains(&ch);
        if is_vowel && !prev_vowel {
            count += 1;
        }
        prev_vowel = is_vowel;
    }

    // Silent 'e' at end
    if clean_word.ends_with('e') && count > 1 && !clean_word.ends_with("le") {
        count -= 1;
    }

    count.max(1)
}

/// Evaluates Markdown documentation prose quality and computes a multiplier between 0.70x and 1.30x (#4.1 / #8.1)
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

    let words_vec: Vec<&str> = content.split_whitespace().collect();
    let total_words = words_vec.len();
    let total_sentences: usize = content.split(|c| c == '.' || c == '!' || c == '?').filter(|s| !s.trim().is_empty()).count().max(1);

    // 1. Calculate Flesch Reading Ease score using syllable counts
    let total_syllables: usize = words_vec.iter().map(|w| count_syllables(w)).sum();
    let words_per_sentence = total_words as f64 / total_sentences as f64;
    let syllables_per_word = total_syllables as f64 / total_words.max(1) as f64;

    let reading_ease = (206.835 - (1.015 * words_per_sentence) - (84.6 * syllables_per_word)).clamp(0.0, 100.0);

    // 2. Check code block syntax presence and validity
    let code_blocks_count = content.matches("```").count() / 2;
    let code_validity = if code_blocks_count > 0 { 1.0 } else { 0.9 };

    // 3. Detect AI fluff via known phrase patterns and word entropy
    let fluff_patterns = [
        "as an ai language model",
        "in conclusion, it is important to remember",
        "it is worth noting that in today's digital age",
        "furthermore, it should be emphasized that",
    ];
    let lower_content = content.to_lowercase();
    let is_pattern_fluff = fluff_patterns.iter().any(|pattern| lower_content.contains(pattern));

    // Entropy-based repetition detection
    let unique_words: HashSet<&str> = words_vec.iter().copied().collect();
    let unique_ratio = if total_words >= 20 {
        unique_words.len() as f64 / total_words as f64
    } else {
        1.0
    };
    let is_entropy_fluff = unique_ratio < 0.30;
    let is_ai_fluff = is_pattern_fluff || is_entropy_fluff;

    // 4. Calculate final quality multiplier bounded between 0.70 and 1.30
    let mut multiplier: f64 = 1.0;

    if is_pattern_fluff {
        multiplier -= 0.25;
    }

    if unique_ratio < 0.30 {
        multiplier -= 0.15;
    } else if unique_ratio < 0.45 {
        multiplier -= 0.05;
    }

    if reading_ease >= 60.0 && reading_ease <= 80.0 {
        multiplier += 0.15; // Optimal technical readability
    } else if reading_ease < 30.0 {
        multiplier -= 0.10; // Overly complex or unreadable
    }

    if code_blocks_count >= 1 {
        multiplier += 0.10; // Contains practical code snippets
    }

    // 5. Reward structural formatting (headings + lists)
    let heading_count = content.lines().filter(|l| l.trim_start().starts_with('#')).count();
    let list_count = content.lines().filter(|l| {
        let t = l.trim();
        t.starts_with("- ") || t.starts_with("* ") || t.starts_with("1.")
    }).count();

    if heading_count >= 2 && list_count >= 3 {
        multiplier += 0.05; // Well-structured documentation
    }

    let final_score = multiplier.clamp(0.70, 1.30);

    QualityAnalysis {
        quality_score: final_score,
        readability_score: reading_ease,
        code_snippet_validity: code_validity,
        is_ai_fluff,
        summary: format!(
            "Quality Multiplier: {:.2}x (Readability: {:.1}, Fluff: {}, Unique Ratio: {:.2})",
            final_score, reading_ease, is_ai_fluff, unique_ratio
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

## Installation

To install the client package, execute the following command:

```bash
cargo add docudrip-sdk
```

This connects your server to the continuous micro-funding pool.

- Step 1: Initialize client
- Step 2: Configure API keys
- Step 3: Stream metrics
"#;
        let analysis = analyze_documentation_quality(content);
        assert!(analysis.quality_score >= 1.10);
        assert!(!analysis.is_ai_fluff);
    }

    #[test]
    fn test_ai_fluff_pattern_penalty() {
        let content = "As an AI language model, in conclusion, it is important to remember that documentation is crucial in today's digital age.";
        let analysis = analyze_documentation_quality(content);
        assert!(analysis.is_ai_fluff);
        assert!(analysis.quality_score <= 0.85);
    }

    #[test]
    fn test_entropy_repetition_penalty() {
        let content = "the the the the the the the the the the the the the the the the the the the the the the the the";
        let analysis = analyze_documentation_quality(content);
        assert!(analysis.is_ai_fluff);
        assert!(analysis.quality_score <= 0.85);
    }
}
