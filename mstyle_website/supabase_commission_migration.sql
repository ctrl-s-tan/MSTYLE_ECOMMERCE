-- ============================================================
-- Commission Claim Tracking System — Supabase Migration
-- Run in Supabase Dashboard → SQL Editor
-- ============================================================

-- ── 1. seller_commission_claims ──────────────────────────────
-- One row per seller per claim request.
-- Admin marks it as paid and records the exact claim date.
CREATE TABLE IF NOT EXISTS seller_commission_claims (
  id              BIGSERIAL     PRIMARY KEY,
  seller_email    TEXT          NOT NULL,
  seller_name     TEXT,
  amount          NUMERIC(10,2) NOT NULL DEFAULT 0,
  status          TEXT          NOT NULL DEFAULT 'pending'
                                CHECK (status IN ('pending','approved','paid','rejected')),
  claim_date      DATE,                          -- date seller submitted the claim
  paid_date       DATE,                          -- date admin marked as paid
  payment_method  TEXT,                          -- e.g. GCash, Bank Transfer
  reference_no    TEXT,                          -- payment reference / transaction ID
  notes           TEXT,
  created_at      TIMESTAMPTZ   DEFAULT NOW(),
  updated_at      TIMESTAMPTZ   DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_scc_seller_email ON seller_commission_claims(seller_email);
CREATE INDEX IF NOT EXISTS idx_scc_status       ON seller_commission_claims(status);
CREATE INDEX IF NOT EXISTS idx_scc_paid_date    ON seller_commission_claims(paid_date);
CREATE INDEX IF NOT EXISTS idx_scc_claim_date   ON seller_commission_claims(claim_date);

-- ── 2. Auto-update updated_at ────────────────────────────────
CREATE OR REPLACE FUNCTION update_scc_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_scc_updated_at ON seller_commission_claims;
CREATE TRIGGER trg_scc_updated_at
  BEFORE UPDATE ON seller_commission_claims
  FOR EACH ROW EXECUTE FUNCTION update_scc_updated_at();
