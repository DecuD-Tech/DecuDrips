use axum::{
    async_trait,
    extract::FromRequestParts,
    http::request::Parts,
};
use uuid::Uuid;

use crate::error::AppError;
use crate::auth::jwt;
use crate::state::AppState;

/// Authenticated user extracted from a valid JWT in the Authorization header.
#[derive(Debug, Clone)]
pub struct AuthUser {
    pub id: Uuid,
    pub github_id: i64,
    pub username: String,
    pub role: String,
}

/// Optional authentication — passes `None` if no token, validates if present.
#[derive(Debug, Clone)]
pub struct OptionalAuth(pub Option<AuthUser>);

/// Sponsor-only guard — rejects with 403 if authenticated user is not a sponsor.
/// Compile-time enforced: only sponsors can hit endpoints using this extractor.
#[derive(Debug, Clone)]
pub struct SponsorUser(pub AuthUser);

// Helper: extract bearer token from Authorization header.
fn extract_bearer_token(parts: &Parts) -> Option<&str> {
    parts
        .headers
        .get("authorization")?
        .to_str()
        .ok()?
        .strip_prefix("Bearer ")
}

#[async_trait]
impl FromRequestParts<AppState> for AuthUser {
    type Rejection = AppError;

    async fn from_request_parts(
        parts: &mut Parts,
        state: &AppState,
    ) -> Result<Self, Self::Rejection> {
        let token = extract_bearer_token(parts).ok_or(AppError::Unauthorized)?;
        let claims = jwt::decode_token(token, &state.config.jwt_secret)?;

        Ok(AuthUser {
            id: claims.sub,
            github_id: claims.github_id,
            username: claims.username,
            role: claims.role,
        })
    }
}

#[async_trait]
impl FromRequestParts<AppState> for OptionalAuth {
    type Rejection = AppError;

    async fn from_request_parts(
        parts: &mut Parts,
        state: &AppState,
    ) -> Result<Self, Self::Rejection> {
        let Some(token) = extract_bearer_token(parts) else {
            return Ok(OptionalAuth(None));
        };

        match jwt::decode_token(token, &state.config.jwt_secret) {
            Ok(claims) => Ok(OptionalAuth(Some(AuthUser {
                id: claims.sub,
                github_id: claims.github_id,
                username: claims.username,
                role: claims.role,
            }))),
            Err(_) => Ok(OptionalAuth(None)),
        }
    }
}

#[async_trait]
impl FromRequestParts<AppState> for SponsorUser {
    type Rejection = AppError;

    async fn from_request_parts(
        parts: &mut Parts,
        state: &AppState,
    ) -> Result<Self, Self::Rejection> {
        let user = AuthUser::from_request_parts(parts, state).await?;
        if user.role != "sponsor" {
            return Err(AppError::Forbidden);
        }
        Ok(SponsorUser(user))
    }
}
