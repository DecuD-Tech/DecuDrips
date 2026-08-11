use chrono::{DateTime, Utc};

/// Calculate targeted locale translation grant multiplier (#8.3).
/// Returns 2.0x multiplier boost for high-demand under-translated locales.
pub fn locale_multiplier(locale: &str) -> f64 {
    match locale.to_lowercase().as_str() {
        "es" | "pt" | "ja" | "hi" | "zh" | "de" => 2.0, // 2.0x translation grant boost (#8.3)
        "fr" | "it" | "ru" | "ko" => 1.5,
        _ => 1.0, // Default English / standard locale
    }
}

/// Calculate the accumulated drip for a stream at a given point in time.
///
/// Formula (#8.2):
///   accumulated = (char_count × base_rate × locale_mult × feedback_mult × quality_mult × elapsed_secs) / 86400
pub fn calculate_accumulated(
    character_count: i32,
    base_rate: f64,
    locale: &str,
    approval_ratio: f64,
    quality_multiplier: f64,
    created_at: DateTime<Utc>,
    now: DateTime<Utc>,
) -> f64 {
    let elapsed_seconds = (now - created_at).num_seconds().max(0) as f64;
    let feedback_mult = feedback_multiplier(approval_ratio);
    let loc_mult = locale_multiplier(locale);

    (character_count as f64)
        * base_rate
        * loc_mult
        * feedback_mult
        * quality_multiplier
        * elapsed_seconds
        / 86_400.0
}

/// Maps community approval ratio (0.0–1.0) to a payout multiplier.
pub fn feedback_multiplier(approval_ratio: f64) -> f64 {
    let rating = (approval_ratio * 100.0) as u32;
    match rating {
        95..=100 => 1.5,
        90..=94 => 1.2,
        75..=89 => 1.0,
        60..=74 => 0.8,
        _ => 0.5,
    }
}

/// Check whether a pool's total dripped has met or exceeded its funding amount.
pub fn is_pool_exhausted(total_dripped: f64, funding_amount: f64) -> bool {
    total_dripped >= funding_amount
}

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::Duration;

    #[test]
    fn accumulated_basic() {
        let now = Utc::now();
        let created = now - Duration::seconds(86400); // 1 day ago
        // 10000 chars × 0.001 rate × 1.0 locale (en) × 1.5 feedback (100%) × 1.0 quality × 86400s / 86400
        let result = calculate_accumulated(10000, 0.001, "en", 1.0, 1.0, created, now);
        assert!((result - 15.0).abs() < 0.001, "Expected ~15.0, got {result}");
    }

    #[test]
    fn accumulated_with_locale_and_quality_boost() {
        let now = Utc::now();
        let created = now - Duration::seconds(3600); // 1 hour ago
        // 5000 × 0.002 × 2.0 (es boost) × 1.0 feedback × 1.2 quality × 3600 / 86400
        let result = calculate_accumulated(5000, 0.002, "es", 0.80, 1.2, created, now);
        let expected = 5000.0 * 0.002 * 2.0 * 1.0 * 1.2 * 3600.0 / 86400.0;
        assert!(
            (result - expected).abs() < 0.0001,
            "Expected {expected}, got {result}"
        );
    }
}
