-- Add locale_boost column to streams table
-- #4.2 / #8.3: Dynamic translation grant multipliers (e.g. 2.0x for es, pt, ja, hi, zh)
ALTER TABLE streams ADD COLUMN IF NOT EXISTS locale_boost REAL DEFAULT 1.0;
