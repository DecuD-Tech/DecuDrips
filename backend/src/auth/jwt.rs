use chrono::Utc;
use jsonwebtoken::{decode, encode, DecodingKey, EncodingKey, Header, Validation};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::error::AppError;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Claims {
    /// User ID (from `users.id`)
    pub sub: Uuid,
    /// GitHub user ID
    pub github_id: i64,
    /// GitHub username
    pub username: String,
    /// User role: "contributor" | "sponsor" | "admin"
    pub role: String,
    /// Expiry (Unix timestamp)
    pub exp: usize,
    /// Issued at (Unix timestamp)
    pub iat: usize,
}

/// Encode a JWT from user data.
pub fn encode_token(
    user_id: Uuid,
    github_id: i64,
    username: &str,
    role: &str,
    secret: &str,
    expiry_hours: u64,
) -> Result<String, AppError> {
    let now = Utc::now();
    let exp = (now + chrono::Duration::hours(expiry_hours as i64)).timestamp() as usize;

    let claims = Claims {
        sub: user_id,
        github_id,
        username: username.to_string(),
        role: role.to_string(),
        exp,
        iat: now.timestamp() as usize,
    };

    encode(
        &Header::default(),
        &claims,
        &EncodingKey::from_secret(secret.as_bytes()),
    )
    .map_err(|e| AppError::Internal(anyhow::anyhow!("JWT encode error: {e}")))
}

/// Decode and validate a JWT, returning the claims.
pub fn decode_token(token: &str, secret: &str) -> Result<Claims, AppError> {
    let token_data = decode::<Claims>(
        token,
        &DecodingKey::from_secret(secret.as_bytes()),
        &Validation::default(),
    )
    .map_err(|_| AppError::Unauthorized)?;

    Ok(token_data.claims)
}

#[cfg(test)]
mod tests {
    use super::*;

    const TEST_SECRET: &str = "test-secret-key-for-unit-tests";

    #[test]
    fn encode_decode_roundtrip() {
        let user_id = Uuid::new_v4();
        let token =
            encode_token(user_id, 12345, "testuser", "contributor", TEST_SECRET, 168).unwrap();
        let claims = decode_token(&token, TEST_SECRET).unwrap();

        assert_eq!(claims.sub, user_id);
        assert_eq!(claims.github_id, 12345);
        assert_eq!(claims.username, "testuser");
        assert_eq!(claims.role, "contributor");
    }

    #[test]
    fn expired_token_rejected() {
        let user_id = Uuid::new_v4();
        // Create a token that expired 1 hour ago
        let now = Utc::now();
        let exp = (now - chrono::Duration::hours(1)).timestamp() as usize;

        let claims = Claims {
            sub: user_id,
            github_id: 1,
            username: "expired".into(),
            role: "contributor".into(),
            exp,
            iat: (now - chrono::Duration::hours(2)).timestamp() as usize,
        };

        let token = encode(
            &Header::default(),
            &claims,
            &EncodingKey::from_secret(TEST_SECRET.as_bytes()),
        )
        .unwrap();

        assert!(decode_token(&token, TEST_SECRET).is_err());
    }

    #[test]
    fn invalid_secret_rejected() {
        let user_id = Uuid::new_v4();
        let token =
            encode_token(user_id, 1, "user", "contributor", TEST_SECRET, 168).unwrap();

        assert!(decode_token(&token, "wrong-secret").is_err());
    }

    #[test]
    fn malformed_token_rejected() {
        assert!(decode_token("not.a.valid.jwt", TEST_SECRET).is_err());
        assert!(decode_token("", TEST_SECRET).is_err());
        assert!(decode_token("garbage", TEST_SECRET).is_err());
    }

    #[test]
    fn claims_contain_correct_role() {
        let user_id = Uuid::new_v4();
        let token =
            encode_token(user_id, 99, "sponsor_user", "sponsor", TEST_SECRET, 168).unwrap();
        let claims = decode_token(&token, TEST_SECRET).unwrap();
        assert_eq!(claims.role, "sponsor");
    }
}
