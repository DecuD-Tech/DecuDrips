-- Add content snapshot and quality multiplier columns to streams table
-- FIX-01: Quality scorer needs actual document content, not file paths
-- FIX-09: Persist quality multiplier for auditing and historical replay
ALTER TABLE streams ADD COLUMN IF NOT EXISTS content_snapshot TEXT DEFAULT '';
ALTER TABLE streams ADD COLUMN IF NOT EXISTS quality_multiplier REAL DEFAULT 1.0;

-- Add fingerprint_hash and user_agent columns to votes table (if not present)
ALTER TABLE votes ADD COLUMN IF NOT EXISTS fingerprint_hash TEXT;
ALTER TABLE votes ADD COLUMN IF NOT EXISTS user_agent TEXT;
