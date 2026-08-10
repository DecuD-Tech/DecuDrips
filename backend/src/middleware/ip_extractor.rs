use axum::{
    extract::ConnectInfo,
    http::HeaderMap,
};
use std::net::SocketAddr;

/// Extracts the real client IP address, prioritizing reverse proxy headers:
/// `X-Forwarded-For` (first IP in comma-separated list) > `X-Real-IP` > Socket `ConnectInfo`.
pub fn extract_client_ip(
    headers: &HeaderMap,
    connect_info: Option<&ConnectInfo<SocketAddr>>,
) -> String {
    // 1. Check X-Forwarded-For header
    if let Some(forwarded) = headers.get("X-Forwarded-For") {
        if let Ok(value) = forwarded.to_str() {
            if let Some(first_ip) = value.split(',').next() {
                let trimmed = first_ip.trim();
                if !trimmed.is_empty() {
                    return trimmed.to_string();
                }
            }
        }
    }

    // 2. Check X-Real-IP header
    if let Some(real_ip) = headers.get("X-Real-IP") {
        if let Ok(value) = real_ip.to_str() {
            let trimmed = value.trim();
            if !trimmed.is_empty() {
                return trimmed.to_string();
            }
        }
    }

    // 3. Fall back to direct socket connection info
    connect_info
        .map(|ci| ci.0.ip().to_string())
        .unwrap_or_else(|| "127.0.0.1".to_string())
}

#[cfg(test)]
mod tests {
    use super::*;
    use axum::http::HeaderValue;

    #[test]
    fn test_extract_forwarded_for_first_ip() {
        let mut headers = HeaderMap::new();
        headers.insert("X-Forwarded-For", HeaderValue::from_static("203.0.113.195, 70.41.3.18, 150.172.238.178"));
        let ip = extract_client_ip(&headers, None);
        assert_eq!(ip, "203.0.113.195");
    }

    #[test]
    fn test_extract_real_ip_fallback() {
        let mut headers = HeaderMap::new();
        headers.insert("X-Real-IP", HeaderValue::from_static("198.51.100.1"));
        let ip = extract_client_ip(&headers, None);
        assert_eq!(ip, "198.51.100.1");
    }

    #[test]
    fn test_extract_socket_fallback() {
        let headers = HeaderMap::new();
        let addr: SocketAddr = "192.0.2.1:8080".parse().unwrap();
        let connect_info = ConnectInfo(addr);
        let ip = extract_client_ip(&headers, Some(&connect_info));
        assert_eq!(ip, "192.0.2.1");
    }
}
