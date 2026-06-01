use chrono::{DateTime, Utc};

/// Calculate the accumulated drip for a stream at a given point in time.
///
/// No background task needed — called on read when serving stream data.
///
/// Formula:
///   accumulated = (char_count × base_rate × locale_mult × feedback_mult × elapsed_secs) / 86400
pub fn calculate_accumulated(
    character_count: i32,
    base_rate: f64,
    locale_multiplier: f64,
    approval_ratio: f64,
    created_at: DateTime<Utc>,
    now: DateTime<Utc>,
) -> f64 {
    let elapsed_seconds = (now - created_at).num_seconds().max(0) as f64;
    let feedback_mult = feedback_multiplier(approval_ratio);

    (character_count as f64) * base_rate * locale_multiplier * feedback_mult * elapsed_seconds
        / 86_400.0
}

/// Maps community approval ratio (0.0–1.0) to a payout multiplier.
///
/// | Rating   | Multiplier |
/// |----------|------------|
/// | ≥ 95%    | 1.5×       |
/// | ≥ 90%    | 1.2×       |
/// | ≥ 75%    | 1.0×       |
/// | ≥ 60%    | 0.8×       |
/// | < 60%    | 0.5×       |
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
        let created = now - Duration::seconds(86400); // exactly 1 day ago
        // 10000 chars × 0.001 rate × 1.0 locale × 1.5 feedback (100% approval) × 86400s / 86400
        let result = calculate_accumulated(10000, 0.001, 1.0, 1.0, created, now);
        assert!((result - 15.0).abs() < 0.001, "Expected ~15.0, got {result}");
    }

    #[test]
    fn accumulated_with_locale_boost() {
        let now = Utc::now();
        let created = now - Duration::seconds(3600); // 1 hour ago
        let result = calculate_accumulated(5000, 0.002, 1.5, 0.80, created, now);
        // 5000 × 0.002 × 1.5 × 1.0 (80% → 1.0×) × 3600 / 86400
        let expected = 5000.0 * 0.002 * 1.5 * 1.0 * 3600.0 / 86400.0;
        assert!(
            (result - expected).abs() < 0.0001,
            "Expected {expected}, got {result}"
        );
    }

    #[test]
    fn accumulated_zero_elapsed() {
        let now = Utc::now();
        let result = calculate_accumulated(10000, 0.001, 1.0, 1.0, now, now);
        assert!((result).abs() < f64::EPSILON, "Expected 0.0, got {result}");
    }

    #[test]
    fn accumulated_zero_chars() {
        let now = Utc::now();
        let created = now - Duration::seconds(3600);
        let result = calculate_accumulated(0, 0.001, 1.0, 1.0, created, now);
        assert!((result).abs() < f64::EPSILON, "Expected 0.0, got {result}");
    }

    #[test]
    fn accumulated_future_created_at_returns_zero() {
        let now = Utc::now();
        let future = now + Duration::seconds(100);
        let result = calculate_accumulated(10000, 0.001, 1.0, 1.0, future, now);
        assert!(
            (result).abs() < f64::EPSILON,
            "Expected 0.0 for future created_at, got {result}"
        );
    }

    #[test]
    fn feedback_multiplier_boundaries() {
        assert!((feedback_multiplier(1.00) - 1.5).abs() < f64::EPSILON);
        assert!((feedback_multiplier(0.95) - 1.5).abs() < f64::EPSILON);
        assert!((feedback_multiplier(0.94) - 1.2).abs() < f64::EPSILON);
        assert!((feedback_multiplier(0.90) - 1.2).abs() < f64::EPSILON);
        assert!((feedback_multiplier(0.89) - 1.0).abs() < f64::EPSILON);
        assert!((feedback_multiplier(0.75) - 1.0).abs() < f64::EPSILON);
        assert!((feedback_multiplier(0.74) - 0.8).abs() < f64::EPSILON);
        assert!((feedback_multiplier(0.60) - 0.8).abs() < f64::EPSILON);
        assert!((feedback_multiplier(0.59) - 0.5).abs() < f64::EPSILON);
        assert!((feedback_multiplier(0.00) - 0.5).abs() < f64::EPSILON);
    }

    #[test]
    fn pool_exhausted_exact() {
        assert!(is_pool_exhausted(100.0, 100.0));
    }

    #[test]
    fn pool_exhausted_over() {
        assert!(is_pool_exhausted(100.01, 100.0));
    }

    #[test]
    fn pool_not_exhausted() {
        assert!(!is_pool_exhausted(99.99, 100.0));
    }
}
