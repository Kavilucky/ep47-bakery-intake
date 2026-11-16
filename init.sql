-- Схема контроля накладных (пример). Выполняется один раз при первом запуске PostgreSQL.
CREATE TABLE IF NOT EXISTS price_list (          -- эталонный прайс и ожидаемое количество: заполняет хозяин
  name          TEXT PRIMARY KEY,                -- название позиции как в накладной
  unit          TEXT NOT NULL,
  price_agreed  NUMERIC(12, 2) NOT NULL CHECK (price_agreed > 0),
  qty_expected  NUMERIC(12, 3) NOT NULL CHECK (qty_expected >= 0),   -- сколько должны привезти по заказу
  tolerance_pct NUMERIC(5, 2) NOT NULL DEFAULT 2                      -- допустимый рост цены, %
);
CREATE TABLE IF NOT EXISTS invoices (            -- принятые накладные
  id         BIGSERIAL PRIMARY KEY,
  chat_id    BIGINT NOT NULL,                    -- чат Telegram сотрудника
  raw        JSONB NOT NULL,                     -- строки, которые распознала модель
  status     TEXT NOT NULL DEFAULT 'checked' CHECK (status IN ('checked', 'blocked', 'accepted', 'closed_with_act')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  closed_at  TIMESTAMPTZ
);
CREATE TABLE IF NOT EXISTS invoice_lines (       -- строки накладной
  id         BIGSERIAL PRIMARY KEY,
  invoice_id BIGINT NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
  name       TEXT NOT NULL,
  qty        NUMERIC(12, 3) NOT NULL,
  unit       TEXT,
  price      NUMERIC(12, 2) NOT NULL,
  line_sum   NUMERIC(14, 2)
);
CREATE INDEX IF NOT EXISTS invoice_lines_invoice_idx ON invoice_lines (invoice_id);
-- Образцы прайса (вымышленные, замените своими):
INSERT INTO price_list (name, unit, price_agreed, qty_expected) VALUES
  ('Сливки 33%', 'л', 400, 10),
  ('Молоко 3,2%', 'л', 112, 40),
  ('Масло 82%', 'кг', 520, 15)
ON CONFLICT (name) DO NOTHING;
