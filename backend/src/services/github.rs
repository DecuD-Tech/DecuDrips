use reqwest::{Client, StatusCode};
use serde::{Deserialize, Serialize};

use crate::error::AppError;

pub struct GitHubClient {
    http: Client,
}

#[derive(Deserialize, Debug)]
pub struct GitHubUser {
    pub id: i64,
    pub login: String,
    pub avatar_url: Option<String>,
}

#[derive(Deserialize, Debug)]
pub struct AccessTokenResponse {
    pub access_token: String,
    pub token_type: String,
    pub scope: String,
}

#[derive(Serialize, Debug)]
struct AccessTokenRequest<'a> {
    client_id: &'a str,
    client_secret: &'a str,
    code: &'a str,
    redirect_uri: &'a str,
}

#[derive(Deserialize, Debug)]
pub struct PrFile {
    pub filename: String,
    pub additions: i32,
    pub deletions: i32,
    pub changes: i32,
    pub status: String,
}

impl GitHubClient {
    pub fn new() -> Self {
        Self {
            http: Client::builder()
                .user_agent("DocuDrip-Backend/1.0")
                .build()
                .expect("Failed to build HTTP client"),
        }
    }

    /// Exchanges an OAuth code for an access token.
    pub async fn exchange_code(
        &self,
        client_id: &str,
        client_secret: &str,
        code: &str,
        redirect_uri: &str,
    ) -> Result<String, AppError> {
        let req_body = AccessTokenRequest {
            client_id,
            client_secret,
            code,
            redirect_uri,
        };

        let response = self
            .http
            .post("https://github.com/login/oauth/access_token")
            .header("Accept", "application/json")
            .json(&req_body)
            .send()
            .await
            .map_err(|e| AppError::GitHub(format!("Failed to request access token: {e}")))?;

        if !response.status().is_success() {
            return Err(AppError::GitHub(format!(
                "GitHub returned error status: {}",
                response.status()
            )));
        }

        let token_resp: AccessTokenResponse = response
            .json()
            .await
            .map_err(|e| AppError::GitHub(format!("Failed to parse access token response: {e}")))?;

        Ok(token_resp.access_token)
    }

    /// Fetches the authenticated user's profile using their access token.
    pub async fn fetch_user(&self, access_token: &str) -> Result<GitHubUser, AppError> {
        let response = self
            .http
            .get("https://api.github.com/user")
            .header("Authorization", format!("Bearer {access_token}"))
            .header("Accept", "application/vnd.github.v3+json")
            .send()
            .await
            .map_err(|e| AppError::GitHub(format!("Failed to fetch user: {e}")))?;

        if !response.status().is_success() {
            if response.status() == StatusCode::UNAUTHORIZED {
                return Err(AppError::Unauthorized);
            }
            return Err(AppError::GitHub(format!(
                "GitHub API error: {}",
                response.status()
            )));
        }

        let user: GitHubUser = response
            .json()
            .await
            .map_err(|e| AppError::GitHub(format!("Failed to parse user response: {e}")))?;

        Ok(user)
    }

    /// Fetches the list of files changed in a Pull Request.
    pub async fn fetch_pr_files(
        &self,
        repo_full_name: &str,
        pr_number: i32,
    ) -> Result<Vec<PrFile>, AppError> {
        let url = format!("https://api.github.com/repos/{repo_full_name}/pulls/{pr_number}/files");
        
        let response = self
            .http
            .get(&url)
            .header("Accept", "application/vnd.github.v3+json")
            .send()
            .await
            .map_err(|e| AppError::GitHub(format!("Failed to fetch PR files: {e}")))?;

        if !response.status().is_success() {
            return Err(AppError::GitHub(format!(
                "GitHub API error fetching PR files: {}",
                response.status()
            )));
        }

        let files: Vec<PrFile> = response
            .json()
            .await
            .map_err(|e| AppError::GitHub(format!("Failed to parse PR files response: {e}")))?;

        Ok(files)
    }
}
