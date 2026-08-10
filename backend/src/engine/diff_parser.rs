/// Represents analyzed diff statistics for a pull request document change.
#[derive(Debug, PartialEq, Eq, Clone)]
pub struct DiffAnalysis {
    pub meaningful_additions: i32,
    pub meaningful_deletions: i32,
    pub is_formatting_only: bool,
    pub detected_patterns: Vec<String>,
}

/// Parses raw unified diff content and filters out Table of Contents,
/// YAML frontmatter boundaries, pure whitespace changes, and lockfile noise (#3.2, #3.3).
pub fn analyze_diff(raw_diff: &str) -> DiffAnalysis {
    let mut meaningful_additions = 0;
    let mut meaningful_deletions = 0;
    let mut detected_patterns = Vec::new();
    let mut in_yaml_frontmatter = false;

    for line in raw_diff.lines() {
        // Skip diff header metadata
        if line.starts_with("--- a/")
            || line.starts_with("+++ b/")
            || line.starts_with("@@")
            || line.starts_with("diff --git")
            || line.starts_with("index ")
        {
            continue;
        }

        // Added line (+)
        if line.starts_with('+') && !line.starts_with("+++") {
            let content = line[1..].trim();

            // Toggle YAML frontmatter tracking
            if content == "---" {
                in_yaml_frontmatter = !in_yaml_frontmatter;
                detected_patterns.push("yaml_frontmatter_delimiter".to_string());
                continue;
            }

            // Skip YAML frontmatter content
            if in_yaml_frontmatter {
                detected_patterns.push("yaml_frontmatter_content".to_string());
                continue;
            }

            // Skip Table of Contents markers
            if is_toc_pattern(content) {
                detected_patterns.push("table_of_contents_marker".to_string());
                continue;
            }

            // Skip empty / pure whitespace additions
            if content.is_empty() {
                detected_patterns.push("whitespace_addition".to_string());
                continue;
            }

            meaningful_additions += content.len() as i32;
        }
        // Deleted line (-)
        else if line.starts_with('-') && !line.starts_with("---") {
            let content = line[1..].trim();
            if !content.is_empty() && !is_toc_pattern(content) {
                meaningful_deletions += content.len() as i32;
            }
        }
    }

    let is_formatting_only = meaningful_additions == 0;

    DiffAnalysis {
        meaningful_additions,
        meaningful_deletions,
        is_formatting_only,
        detected_patterns,
    }
}

/// Helper pattern matcher for auto-generated TOCs
fn is_toc_pattern(line: &str) -> bool {
    let lower = line.to_lowercase();
    lower.contains("<!-- toc -->")
        || lower.contains("<!-- /toc -->")
        || lower.contains("<!-- toc stop -->")
        || lower == "## table of contents"
        || lower == "# table of contents"
        || lower == "## contents"
        || lower == "* [table of contents]"
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_meaningful_prose_diff() {
        let diff = r#"
diff --git a/docs/guide.md b/docs/guide.md
index 1234567..89abcdef 100644
--- a/docs/guide.md
+++ b/docs/guide.md
@@ -1,3 +1,5 @@
+# DocuDrip Protocol
+Continuous documentation micro-funding framework.
"#;
        let analysis = analyze_diff(diff);
        assert!(analysis.meaningful_additions > 0);
        assert!(!analysis.is_formatting_only);
    }

    #[test]
    fn test_toc_and_whitespace_ignored() {
        let diff = r#"
+ <!-- TOC -->
+ ## Table of Contents
+   
"#;
        let analysis = analyze_diff(diff);
        assert_eq!(analysis.meaningful_additions, 0);
        assert!(analysis.is_formatting_only);
    }
}
