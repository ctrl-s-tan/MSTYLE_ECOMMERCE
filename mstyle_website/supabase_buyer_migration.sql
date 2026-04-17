-- ============================================================
-- Buyer tables migration for Supabase
-- Run this in Supabase Dashboard → SQL Editor
-- ============================================================
-- Covers: cart, checkout, orders (shared), wishlist,
--         buyer_notifications, buyer_rider_messages,
--         buyer_seller_messages (shared with seller migration),
--         conversations (shared with seller migration)
-- ============================================================

-- ── 1. orders (shared — safe to re-run) ──────────────────────
-- Already created in supabase_rider_migration.sql.
-- Re-running CREATE TABLE IF NOT EXISTS is safe.
CREATE TABLE IF NOT EXISTS orders (
  id                  BIGSERIAL     PRIMARY KEY,
  name                TEXT,
  quantity            INT           DEFAULT 1,
  total_price         NUMERIC(10,2),
  payment_method      TEXT,
  status              TEXT          DEFAULT 'Pending',
  cancellation_reason TEXT,
  cancelled_at        TIMESTAMPTZ,
  email               TEXT,          -- buyer email
  address             TEXT,
  seller_email        TEXT,
  rider_email         TEXT,
  product_id          BIGINT,
  image               TEXT,
  variations          TEXT,
  size                TEXT,
  shipping_fee        NUMERIC(10,2) DEFAULT 50,
  date                TIMESTAMPTZ   DEFAULT NOW(),
  delivered_at        TIMESTAMPTZ,
  received_at         TIMESTAMPTZ,
  auto_complete_at    TIMESTAMPTZ,
  is_auto_completed   BOOLEAN       DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_orders_email        ON orders(email);
CREATE INDEX IF NOT EXISTS idx_orders_seller_email ON orders(seller_email);
CREATE INDEX IF NOT EXISTS idx_orders_rider_email  ON orders(rider_email);
CREATE INDEX IF NOT EXISTS idx_orders_status       ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_date         ON orders(date);

-- ── 2. cart ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS cart (
  id           BIGSERIAL     PRIMARY KEY,
  name         TEXT          NOT NULL,
  price        NUMERIC(10,2) NOT NULL,
  quantity     INT           NOT NULL DEFAULT 1,
  variations   TEXT,
  image        TEXT,
  size         TEXT,
  email        TEXT          NOT NULL,   -- buyer email
  seller_email TEXT          NOT NULL,
  product_id   BIGINT        NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_cart_email        ON cart(email);
CREATE INDEX IF NOT EXISTS idx_cart_product_id   ON cart(product_id);
CREATE INDEX IF NOT EXISTS idx_cart_seller_email ON cart(seller_email);

-- ── 3. checkout ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS checkout (
  id           BIGSERIAL     PRIMARY KEY,
  name         TEXT          NOT NULL,
  price        NUMERIC(10,2) NOT NULL,
  quantity     INT           NOT NULL DEFAULT 1,
  variations   TEXT,
  image        TEXT,
  size         TEXT,
  email        TEXT          NOT NULL,   -- buyer email
  address      TEXT,
  seller_email TEXT,
  product_id   BIGINT,
  shipping_fee NUMERIC(10,2) DEFAULT 50
);

CREATE INDEX IF NOT EXISTS idx_checkout_email        ON checkout(email);
CREATE INDEX IF NOT EXISTS idx_checkout_seller_email ON checkout(seller_email);
CREATE INDEX IF NOT EXISTS idx_checkout_product_id   ON checkout(product_id);

-- ── 4. wishlist ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS wishlist (
  id         BIGSERIAL   PRIMARY KEY,
  user_id    BIGINT      NOT NULL,
  product_id BIGINT      NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, product_id)
);

CREATE INDEX IF NOT EXISTS idx_wishlist_user_id    ON wishlist(user_id);
CREATE INDEX IF NOT EXISTS idx_wishlist_product_id ON wishlist(product_id);

-- ── 5. buyer_notifications ───────────────────────────────────
-- Already created in supabase_rider_migration.sql — safe to re-run
CREATE TABLE IF NOT EXISTS buyer_notifications (
  id          BIGSERIAL   PRIMARY KEY,
  buyer_email TEXT        NOT NULL,
  message     TEXT        NOT NULL,
  type        TEXT        DEFAULT 'status_update',
  is_read     BOOLEAN     DEFAULT FALSE,
  order_id    BIGINT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_buyer_notif_email   ON buyer_notifications(buyer_email);
CREATE INDEX IF NOT EXISTS idx_buyer_notif_is_read ON buyer_notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_buyer_notif_order   ON buyer_notifications(order_id);

-- ── 6. buyer_rider_messages ──────────────────────────────────
-- Already created in supabase_rider_migration.sql — safe to re-run
CREATE TABLE IF NOT EXISTS buyer_rider_messages (
  id             BIGSERIAL   PRIMARY KEY,
  order_id       BIGINT      NOT NULL,
  sender_email   TEXT        NOT NULL,
  receiver_email TEXT        NOT NULL,
  message        TEXT        NOT NULL,
  is_read        BOOLEAN     DEFAULT FALSE,
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_brm_order_id  ON buyer_rider_messages(order_id);
CREATE INDEX IF NOT EXISTS idx_brm_sender    ON buyer_rider_messages(sender_email);
CREATE INDEX IF NOT EXISTS idx_brm_receiver  ON buyer_rider_messages(receiver_email);
CREATE INDEX IF NOT EXISTS idx_brm_is_read   ON buyer_rider_messages(is_read);

-- ── 7. buyer_seller_messages (shared) ────────────────────────
-- Already created in supabase_seller_migration.sql — safe to re-run
CREATE TABLE IF NOT EXISTS buyer_seller_messages (
  id              BIGSERIAL   PRIMARY KEY,
  conversation_id TEXT        NOT NULL,
  sender_email    TEXT        NOT NULL,
  receiver_email  TEXT        NOT NULL,
  sender_type     TEXT        NOT NULL,   -- 'buyer' | 'seller'
  message_text    TEXT        NOT NULL,
  is_read         BOOLEAN     DEFAULT FALSE,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_bsm_conversation_id ON buyer_seller_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_bsm_sender          ON buyer_seller_messages(sender_email);
CREATE INDEX IF NOT EXISTS idx_bsm_receiver        ON buyer_seller_messages(receiver_email);
CREATE INDEX IF NOT EXISTS idx_bsm_is_read         ON buyer_seller_messages(is_read);

-- ── 8. conversations (shared) ────────────────────────────────
-- Already created in supabase_seller_migration.sql — safe to re-run
CREATE TABLE IF NOT EXISTS conversations (
  id              BIGSERIAL   PRIMARY KEY,
  conversation_id TEXT        NOT NULL UNIQUE,
  buyer_email     TEXT        NOT NULL,
  seller_email    TEXT        NOT NULL,
  product_id      BIGINT,
  order_id        BIGINT,
  last_message_at TIMESTAMPTZ DEFAULT NOW(),
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_conversations_buyer_email  ON conversations(buyer_email);
CREATE INDEX IF NOT EXISTS idx_conversations_seller_email ON conversations(seller_email);
CREATE INDEX IF NOT EXISTS idx_conversations_product_id   ON conversations(product_id);
CREATE INDEX IF NOT EXISTS idx_conversations_order_id     ON conversations(order_id);

-- ============================================================
-- RLS Policies
-- ============================================================

ALTER TABLE orders                ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE checkout              ENABLE ROW LEVEL SECURITY;
ALTER TABLE wishlist              ENABLE ROW LEVEL SECURITY;
ALTER TABLE buyer_notifications   ENABLE ROW LEVEL SECURITY;
ALTER TABLE buyer_rider_messages  ENABLE ROW LEVEL SECURITY;
ALTER TABLE buyer_seller_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations         ENABLE ROW LEVEL SECURITY;

-- orders: buyers, sellers, and riders can read orders they are involved in
DROP POLICY IF EXISTS "users can read own orders" ON orders;
CREATE POLICY "users can read own orders"
  ON orders FOR SELECT TO authenticated
  USING (
    email        = auth.jwt() ->> 'email'
    OR seller_email = auth.jwt() ->> 'email'
    OR rider_email  = auth.jwt() ->> 'email'
  );

-- cart: buyers can fully manage their own cart
DROP POLICY IF EXISTS "buyer can manage own cart" ON cart;
CREATE POLICY "buyer can manage own cart"
  ON cart FOR ALL TO authenticated
  USING (email = auth.jwt() ->> 'email')
  WITH CHECK (email = auth.jwt() ->> 'email');

-- checkout: buyers can fully manage their own checkout
DROP POLICY IF EXISTS "buyer can manage own checkout" ON checkout;
CREATE POLICY "buyer can manage own checkout"
  ON checkout FOR ALL TO authenticated
  USING (email = auth.jwt() ->> 'email')
  WITH CHECK (email = auth.jwt() ->> 'email');

-- wishlist: buyers can fully manage their own wishlist
-- Note: user_id here is the Supabase auth UID (UUID stored as BIGINT is a mismatch;
--       if your users table uses UUID primary keys, change BIGINT to UUID above)
DROP POLICY IF EXISTS "buyer can manage own wishlist" ON wishlist;
CREATE POLICY "buyer can manage own wishlist"
  ON wishlist FOR ALL TO authenticated
  USING (user_id::TEXT = auth.uid()::TEXT)
  WITH CHECK (user_id::TEXT = auth.uid()::TEXT);

-- buyer_notifications: buyers can read/manage their own
DROP POLICY IF EXISTS "buyer can read own notifications" ON buyer_notifications;
CREATE POLICY "buyer can read own notifications"
  ON buyer_notifications FOR ALL TO authenticated
  USING (buyer_email = auth.jwt() ->> 'email');

-- buyer_rider_messages: participants can read
DROP POLICY IF EXISTS "participants can read buyer_rider_messages" ON buyer_rider_messages;
CREATE POLICY "participants can read buyer_rider_messages"
  ON buyer_rider_messages FOR SELECT TO authenticated
  USING (
    sender_email   = auth.jwt() ->> 'email'
    OR receiver_email = auth.jwt() ->> 'email'
  );

-- buyer_seller_messages: participants can read
DROP POLICY IF EXISTS "participants can read buyer_seller_messages" ON buyer_seller_messages;
CREATE POLICY "participants can read buyer_seller_messages"
  ON buyer_seller_messages FOR SELECT TO authenticated
  USING (
    sender_email   = auth.jwt() ->> 'email'
    OR receiver_email = auth.jwt() ->> 'email'
  );

-- conversations: participants can read their own
DROP POLICY IF EXISTS "participants can read conversations" ON conversations;
CREATE POLICY "participants can read conversations"
  ON conversations FOR SELECT TO authenticated
  USING (
    buyer_email  = auth.jwt() ->> 'email'
    OR seller_email = auth.jwt() ->> 'email'
  );

-- ============================================================
-- Seed data migration from MySQL
-- Run the INSERT statements below ONLY if you want to migrate
-- existing MySQL data into Supabase.
-- Replace the VALUES with your actual exported data.
-- ============================================================

-- Example: migrate existing buyer_notifications
-- INSERT INTO buyer_notifications (id, buyer_email, message, type, is_read, created_at, order_id)
-- VALUES
--   (95, 'tolentinomariely09@gmail.com', 'Great news! Your order ...', 'shipped', TRUE, '2025-12-05 23:05:24', 25),
--   ...
-- ON CONFLICT (id) DO NOTHING;

-- Example: migrate existing buyer_rider_messages
-- INSERT INTO buyer_rider_messages (id, order_id, sender_email, receiver_email, message, is_read, created_at)
-- VALUES
--   (37, 46, 'tolentinoann2001@gmail.com', 'tolentinomariely09@gmail.com', 'May tip ba?', TRUE, '2025-12-05 23:09:16'),
--   ...
-- ON CONFLICT (id) DO NOTHING;
