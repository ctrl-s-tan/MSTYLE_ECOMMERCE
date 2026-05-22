-- ============================================================
-- Commission Claims Tracking Table
-- Run in Supabase Dashboard → SQL Editor
-- ============================================================

CREATE TABLE IF NOT EXISTS commission_claims (
  id              BIGSERIAL     PRIMARY KEY,
  order_id        BIGINT        NOT NULL,
  seller_email    TEXT          NOT NULL,
  rider_email     TEXT,
  order_total     NUMERIC(10,2) NOT NULL DEFAULT 0,
  delivery_fee    NUMERIC(10,2) NOT NULL DEFAULT 0,
  seller_commission  NUMERIC(10,2) NOT NULL DEFAULT 0,
  rider_commission   NUMERIC(10,2) NOT NULL DEFAULT 0,
  total_platform_earnings NUMERIC(10,2) NOT NULL DEFAULT 0,
  order_date      DATE,
  date_completed  DATE,
  is_claimed      BOOLEAN       DEFAULT FALSE,
  claimed_date    DATE,
  claimed_by      TEXT,
  notes           TEXT,
  created_at      TIMESTAMPTZ   DEFAULT NOW(),
  updated_at      TIMESTAMPTZ   DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_commission_claims_order_id     ON commission_claims(order_id);
CREATE INDEX IF NOT EXISTS idx_commission_claims_seller_email ON commission_claims(seller_email);
CREATE INDEX IF NOT EXISTS idx_commission_claims_is_claimed   ON commission_claims(is_claimed);
CREATE INDEX IF NOT EXISTS idx_commission_claims_claimed_date ON commission_claims(claimed_date);
