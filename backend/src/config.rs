use anyhow::{Context, Result};

#[derive(Debug, Clone)]
pub struct Config {
    // Database
    pub database_url: String,

    // GitHub OAuth
    pub github_client_id: String,
    pub github_client_secret: String,
    pub github_redirect_uri: String,
    pub github_webhook_secret: String,

    // JWT
    pub jwt_secret: String,
    pub jwt_expiry_hours: u64,

    // Server
    pub port: u16,
    pub cors_origin: String,
}

impl Config {
    /// Parse configuration from environment variables.
    /// Panics on missing required vars (fail fast at startup).
    pub fn from_env() -> Result<Self> {
        Ok(Self {
            database_url: std::env::var("DATABASE_URL")
                .context("DATABASE_URL must be set")?,
            github_client_id: std::env::var("GITHUB_CLIENT_ID")
                .context("GITHUB_CLIENT_ID must be set")?,
            github_client_secret: std::env::var("GITHUB_CLIENT_SECRET")
                .context("GITHUB_CLIENT_SECRET must be set")?,
            github_redirect_uri: std::env::var("GITHUB_REDIRECT_URI")
                .unwrap_or_else(|_| "http://localhost:8080/api/v1/auth/github/callback".into()),
            github_webhook_secret: std::env::var("GITHUB_WEBHOOK_SECRET")
                .context("GITHUB_WEBHOOK_SECRET must be set")?,
            jwt_secret: std::env::var("JWT_SECRET")
                .context("JWT_SECRET must be set")?,
            jwt_expiry_hours: std::env::var("JWT_EXPIRY_HOURS")
                .unwrap_or_else(|_| "168".into())
                .parse()
                .context("JWT_EXPIRY_HOURS must be a valid u64")?,
            port: std::env::var("PORT")
                .unwrap_or_else(|_| "8080".into())
                .parse()
                .context("PORT must be a valid u16")?,
            cors_origin: std::env::var("CORS_ORIGIN")
                .unwrap_or_else(|_| "http://localhost:5173".into()),
        })
    }
}
