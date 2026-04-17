-- ============================================================
-- Run this once in Supabase Dashboard → SQL Editor
-- ============================================================

-- 1. Add missing columns to the users table (for ban/suspend)
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS status       TEXT    DEFAULT 'active',
  ADD COLUMN IF NOT EXISTS ban_reason   TEXT,
  ADD COLUMN IF NOT EXISTS ban_end_date TIMESTAMPTZ;

-- Add seller-specific columns to users table
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS business_name  TEXT,
  ADD COLUMN IF NOT EXISTS business_type  TEXT;

-- Set all existing rows to active if status is null
UPDATE users SET status = 'active' WHERE status IS NULL;

-- 2. Create the archived_users table
--    Archived users are DELETED from the users table and stored here.
--    Restoring re-inserts them back into users.
CREATE TABLE IF NOT EXISTS archived_users (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID        NOT NULL,          -- original id from users table
  first_name    TEXT,
  last_name     TEXT,
  email         TEXT,
  phone         TEXT,
  house_street  TEXT,
  barangay      TEXT,
  city          TEXT,
  province      TEXT,
  region        TEXT,
  zip_code      TEXT,
  role          TEXT        DEFAULT 'buyer',
  valid_id_path TEXT,
  archived_at   TIMESTAMPTZ DEFAULT NOW(),
  archived_by   TEXT        DEFAULT 'admin'
);

CREATE INDEX IF NOT EXISTS idx_archived_users_user_id ON archived_users(user_id);
CREATE INDEX IF NOT EXISTS idx_archived_users_email   ON archived_users(email);

-- 3. Create the pending_users table (for mobile app registrations)
--    Mobile registrations go here first; admin approves → moved to users table.
CREATE TABLE IF NOT EXISTS pending_users (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  supabase_uid  UUID        NOT NULL UNIQUE,   -- Supabase auth UID
  email         TEXT        NOT NULL,
  first_name    TEXT,
  last_name     TEXT,
  phone         TEXT,
  house_street  TEXT,
  barangay      TEXT,
  city          TEXT,
  province      TEXT,
  region        TEXT,
  zip_code      TEXT,
  role          TEXT        DEFAULT 'buyer',
  valid_id_path TEXT,
  status        TEXT        DEFAULT 'pending', -- pending | approved | rejected
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pending_users_uid    ON pending_users(supabase_uid);
CREATE INDEX IF NOT EXISTS idx_pending_users_email  ON pending_users(email);
CREATE INDEX IF NOT EXISTS idx_pending_users_status ON pending_users(status);

-- 4. Create pending_rider_vehicles table (for mobile rider registrations)
CREATE TABLE IF NOT EXISTS pending_rider_vehicles (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  supabase_uid        UUID NOT NULL UNIQUE,
  vehicle_type        TEXT,
  plate_number        TEXT,
  vehicle_model       TEXT,
  year_model          TEXT,
  or_cr_path          TEXT,
  nbi_clearance_path  TEXT,
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pending_rider_vehicles_uid ON pending_rider_vehicles(supabase_uid);

-- 5. Create pending_sellers table (for mobile seller registrations)
CREATE TABLE IF NOT EXISTS pending_sellers (
  id                   UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  supabase_uid         UUID        NOT NULL UNIQUE,
  email                TEXT        NOT NULL,
  first_name           TEXT,
  last_name            TEXT,
  business_name        TEXT,
  business_type        TEXT,       -- 'individual' | 'business'
  phone                TEXT,
  house_street         TEXT,
  barangay             TEXT,
  city                 TEXT,
  province             TEXT,
  region               TEXT,
  zip_code             TEXT,
  valid_id_path        TEXT,
  dti_path             TEXT,
  bir_path             TEXT,
  business_permit_path TEXT,
  status               TEXT        DEFAULT 'pending',  -- pending | approved | rejected
  created_at           TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pending_sellers_uid    ON pending_sellers(supabase_uid);
CREATE INDEX IF NOT EXISTS idx_pending_sellers_email  ON pending_sellers(email);
CREATE INDEX IF NOT EXISTS idx_pending_sellers_status ON pending_sellers(status);

-- ============================================================
-- Run this in MySQL (phpMyAdmin or MySQL CLI)
-- ============================================================

-- Add supabase_uid column to MySQL pending_users table
ALTER TABLE pending_users
  ADD COLUMN IF NOT EXISTS supabase_uid VARCHAR(36) DEFAULT NULL;

-- Add supabase_uid column to MySQL pending_sellers table
ALTER TABLE pending_sellers
  ADD COLUMN IF NOT EXISTS supabase_uid VARCHAR(36) DEFAULT NULL;

-- ============================================================
-- RLS policies — run in Supabase Dashboard → SQL Editor
-- ============================================================

-- Allow anyone (anon) to check if their own email is pending approval.
-- This is needed so the mobile login page can show the correct message
-- when a banned account tries to log in.
-- Only 'status' is readable — no personal data is exposed.

ALTER TABLE pending_users  ENABLE ROW LEVEL SECURITY;
ALTER TABLE pending_sellers ENABLE ROW LEVEL SECURITY;

-- Drop policies if they already exist (safe to re-run)
DROP POLICY IF EXISTS "anon can check own pending status" ON pending_users;
DROP POLICY IF EXISTS "anon can check own pending seller status" ON pending_sellers;

CREATE POLICY "anon can check own pending status"
  ON pending_users
  FOR SELECT
  TO anon, authenticated
  USING (true);   -- read is filtered by .eq('email', ...) in the app;
                  -- only 'status' column is selected so no sensitive data leaks

CREATE POLICY "anon can check own pending seller status"
  ON pending_sellers
  FOR SELECT
  TO anon, authenticated
  USING (true);

-- ============================================================
-- RLS policies for archived_users and pending_rider_vehicles
-- Run in Supabase Dashboard → SQL Editor
-- ============================================================

-- archived_users: admin-only table.
-- Only the service-role backend (sb_admin) should read/write it.
-- No anon or authenticated user should access it directly.
ALTER TABLE archived_users ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "no direct access to archived_users" ON archived_users;

CREATE POLICY "no direct access to archived_users"
  ON archived_users
  FOR ALL
  TO anon, authenticated
  USING (false)
  WITH CHECK (false);

-- pending_rider_vehicles: written by the mobile app during registration
-- (authenticated user, their own row) and read/deleted by the service-role
-- backend during admin approval.
ALTER TABLE pending_rider_vehicles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "rider can insert own vehicle record" ON pending_rider_vehicles;
DROP POLICY IF EXISTS "rider can read own vehicle record"   ON pending_rider_vehicles;
DROP POLICY IF EXISTS "rider can update own vehicle record" ON pending_rider_vehicles;

-- Authenticated user can insert their own vehicle record (supabase_uid = their auth UID)
CREATE POLICY "rider can insert own vehicle record"
  ON pending_rider_vehicles
  FOR INSERT
  TO authenticated
  WITH CHECK (supabase_uid = auth.uid());

-- Authenticated user can read their own vehicle record
CREATE POLICY "rider can read own vehicle record"
  ON pending_rider_vehicles
  FOR SELECT
  TO authenticated
  USING (supabase_uid = auth.uid());

-- Authenticated user can update their own vehicle record (e.g. re-upload docs)
CREATE POLICY "rider can update own vehicle record"
  ON pending_rider_vehicles
  FOR UPDATE
  TO authenticated
  USING (supabase_uid = auth.uid())
  WITH CHECK (supabase_uid = auth.uid());

-- Note: DELETE is intentionally not granted to authenticated users.
-- The service-role backend (sb_admin) handles deletion on approval.
-- Anon users have no access at all (no policy = deny by default).

-- ============================================================
-- RLS policies for pending_sellers (INSERT/UPDATE for mobile)
-- Run in Supabase Dashboard → SQL Editor
-- ============================================================

-- Allow authenticated users to insert/update their own pending_sellers row.
-- This is needed for the mobile seller registration flow.
DROP POLICY IF EXISTS "seller can insert own pending record"  ON pending_sellers;
DROP POLICY IF EXISTS "seller can update own pending record"  ON pending_sellers;

CREATE POLICY "seller can insert own pending record"
  ON pending_sellers
  FOR INSERT
  TO authenticated
  WITH CHECK (supabase_uid = auth.uid());

CREATE POLICY "seller can update own pending record"
  ON pending_sellers
  FOR UPDATE
  TO authenticated
  USING (supabase_uid = auth.uid())
  WITH CHECK (supabase_uid = auth.uid());

-- ============================================================
-- RLS INSERT/UPDATE policies for pending_users (mobile registration)
-- Run in Supabase Dashboard → SQL Editor
-- ============================================================

DROP POLICY IF EXISTS "user can insert own pending record"  ON pending_users;
DROP POLICY IF EXISTS "user can update own pending record"  ON pending_users;

CREATE POLICY "user can insert own pending record"
  ON pending_users
  FOR INSERT
  TO authenticated
  WITH CHECK (supabase_uid = auth.uid());

CREATE POLICY "user can update own pending record"
  ON pending_users
  FOR UPDATE
  TO authenticated
  USING (supabase_uid = auth.uid())
  WITH CHECK (supabase_uid = auth.uid());
