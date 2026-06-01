use std::net::SocketAddr;

use sqlx::postgres::PgPoolOptions;
use tracing_subscriber::EnvFilter;

use docudrip_server::config::Config;
use docudrip_server::routes;
use docudrip_server::state::AppState;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Load .env file (silently ignored if missing — production uses real env vars)
    dotenvy::dotenv().ok();

    // Initialize structured logging
    tracing_subscriber::fmt()
        .with_env_filter(
            EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("info")),
        )
        .init();

    // Parse typed configuration from environment
    let config = Config::from_env()?;
    tracing::info!("Configuration loaded, starting server on port {}", config.port);

    // Create PostgreSQL connection pool
    let db = PgPoolOptions::new()
        .max_connections(10)
        .connect(&config.database_url)
        .await?;
    tracing::info!("Connected to PostgreSQL");

    // Run pending migrations
    sqlx::migrate!("./migrations").run(&db).await?;
    tracing::info!("Database migrations applied");

    // Build shared application state
    let state = AppState::new(config.clone(), db);

    // Build the Axum router
    let app = routes::build_router(state);

    // Bind and serve
    let addr = SocketAddr::from(([0, 0, 0, 0], config.port));
    let listener = tokio::net::TcpListener::bind(addr).await?;
    tracing::info!("Server listening on {addr}");
    axum::serve(listener, app).await?;

    Ok(())
}
