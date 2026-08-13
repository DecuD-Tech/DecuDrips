/// Detects document locale from file path and returns a payout multiplier boost (#4.2 / #8.3).
/// Examples:
/// - "docs/es/guide.md" -> 2.0 (High-demand Spanish translation)
/// - "i18n/ja/setup.md" -> 2.0 (High-demand Japanese translation)
/// - "docs/fr/intro.md" -> 1.5 (Standard French translation)
/// - "docs/guide.md"    -> 1.0 (Default English)
pub fn detect_locale_multiplier(file_path: &str) -> (f64, String) {
    let path_lower = file_path.to_lowercase();
    let segments: Vec<&str> = path_lower.split('/').collect();

    let high_demand = [
        ("es", 2.0),
        ("pt", 2.0),
        ("ja", 2.0),
        ("hi", 2.0),
        ("zh", 2.0),
        ("ar", 2.0),
        ("bn", 2.0),
    ];

    let standard = [
        ("fr", 1.5),
        ("de", 1.5),
        ("ko", 1.5),
        ("it", 1.5),
        ("ru", 1.5),
        ("nl", 1.5),
        ("pl", 1.5),
        ("tr", 1.5),
    ];

    // 1. Check directory path segments (e.g., "docs/es/setup.md", "i18n/ja/intro.md")
    for segment in &segments {
        for (lang, boost) in &high_demand {
            if *segment == *lang {
                return (*boost, (*lang).to_string());
            }
        }
        for (lang, boost) in &standard {
            if *segment == *lang {
                return (*boost, (*lang).to_string());
            }
        }
    }

    // 2. Check filename locale suffix patterns (e.g., "guide.es.md", "setup.ja.mdx")
    if let Some(filename) = segments.last() {
        let parts: Vec<&str> = filename.split('.').collect();
        if parts.len() >= 3 {
            let locale_candidate = parts[parts.len() - 2];
            for (lang, boost) in &high_demand {
                if locale_candidate == *lang {
                    return (*boost, (*lang).to_string());
                }
            }
            for (lang, boost) in &standard {
                if locale_candidate == *lang {
                    return (*boost, (*lang).to_string());
                }
            }
        }
    }

    (1.0, "en".to_string())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_high_demand_locale_paths() {
        let (boost, loc) = detect_locale_multiplier("docs/es/getting-started.md");
        assert_eq!(boost, 2.0);
        assert_eq!(loc, "es");

        let (boost, loc) = detect_locale_multiplier("i18n/ja/architecture.md");
        assert_eq!(boost, 2.0);
        assert_eq!(loc, "ja");

        let (boost, loc) = detect_locale_multiplier("content/hi/tutorial.mdx");
        assert_eq!(boost, 2.0);
        assert_eq!(loc, "hi");
    }

    #[test]
    fn test_standard_locale_paths() {
        let (boost, loc) = detect_locale_multiplier("docs/fr/intro.md");
        assert_eq!(boost, 1.5);
        assert_eq!(loc, "fr");

        let (boost, loc) = detect_locale_multiplier("docs/de/reference.rst");
        assert_eq!(boost, 1.5);
        assert_eq!(loc, "de");
    }

    #[test]
    fn test_locale_filename_suffixes() {
        let (boost, loc) = detect_locale_multiplier("docs/guide.es.md");
        assert_eq!(boost, 2.0);
        assert_eq!(loc, "es");

        let (boost, loc) = detect_locale_multiplier("setup.de.mdx");
        assert_eq!(boost, 1.5);
        assert_eq!(loc, "de");
    }

    #[test]
    fn test_default_english() {
        let (boost, loc) = detect_locale_multiplier("docs/architecture.md");
        assert_eq!(boost, 1.0);
        assert_eq!(loc, "en");

        let (boost, loc) = detect_locale_multiplier("README.md");
        assert_eq!(boost, 1.0);
        assert_eq!(loc, "en");
    }
}
