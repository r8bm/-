PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  role TEXT NOT NULL CHECK(role IN ('restaurant_admin','restaurant_staff','driver')),
  name TEXT NOT NULL,
  phone TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS drivers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'offline' CHECK(status IN ('offline','available_at_restaurant','assigned','picked_up','on_way','arrived_customer','delivered_returning','returned','late_return','under_penalty')),
  vehicle_type TEXT,
  last_lat REAL,
  last_lng REAL,
  last_location_at TEXT,
  tracking_enabled INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS restaurant_settings (
  id INTEGER PRIMARY KEY CHECK(id = 1),
  restaurant_name TEXT NOT NULL DEFAULT 'My Restaurant',
  restaurant_lat REAL NOT NULL DEFAULT 31.04219,
  restaurant_lng REAL NOT NULL DEFAULT 46.25726,
  geofence_radius_meters INTEGER NOT NULL DEFAULT 100,
  average_return_speed_kmh REAL NOT NULL DEFAULT 25,
  return_buffer_minutes INTEGER NOT NULL DEFAULT 10,
  minimum_return_minutes INTEGER NOT NULL DEFAULT 10,
  commission_type TEXT NOT NULL DEFAULT 'fixed' CHECK(commission_type IN ('fixed','delivery_fee_percent','daily_salary_plus_per_order','zone_fixed')),
  fixed_commission_amount INTEGER NOT NULL DEFAULT 3000,
  commission_delivery_fee_percent REAL NOT NULL DEFAULT 70,
  daily_salary_amount INTEGER NOT NULL DEFAULT 0,
  per_order_commission_amount INTEGER NOT NULL DEFAULT 1000,
  penalty_enabled INTEGER NOT NULL DEFAULT 1,
  auto_penalty_enabled INTEGER NOT NULL DEFAULT 0,
  penalty_percent REAL NOT NULL DEFAULT 50,
  penalty_duration_minutes INTEGER NOT NULL DEFAULT 60,
  require_manager_approval_for_penalty INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS consents (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  driver_id INTEGER NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  tracking_accepted INTEGER NOT NULL,
  camera_accepted INTEGER NOT NULL,
  background_tracking_accepted INTEGER NOT NULL,
  policy_version TEXT NOT NULL DEFAULT '1.0',
  accepted_text TEXT NOT NULL,
  accepted_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_name TEXT NOT NULL,
  customer_phone TEXT,
  customer_lat REAL NOT NULL,
  customer_lng REAL NOT NULL,
  customer_address TEXT,
  food_price INTEGER NOT NULL CHECK(food_price >= 0),
  delivery_fee INTEGER NOT NULL CHECK(delivery_fee >= 0),
  total_price INTEGER NOT NULL CHECK(total_price >= 0),
  payment_method TEXT NOT NULL DEFAULT 'cash' CHECK(payment_method IN ('cash','card','prepaid','debt')),
  status TEXT NOT NULL DEFAULT 'new' CHECK(status IN ('new','assigned','picked_up','arrived_customer','delivered','returning','returned','cancelled')),
  driver_id INTEGER REFERENCES drivers(id),
  assigned_at TEXT,
  picked_up_at TEXT,
  arrived_customer_at TEXT,
  delivered_at TEXT,
  allowed_return_minutes INTEGER,
  allowed_return_by TEXT,
  returned_at TEXT,
  proof_photo_path TEXT,
  proof_note TEXT,
  return_distance_km REAL,
  late_minutes INTEGER NOT NULL DEFAULT 0,
  created_by INTEGER REFERENCES users(id),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS driver_locations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  driver_id INTEGER NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  lat REAL NOT NULL,
  lng REAL NOT NULL,
  accuracy_meters REAL,
  speed_mps REAL,
  provider TEXT,
  recorded_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS penalties (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  driver_id INTEGER NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  order_id INTEGER REFERENCES orders(id) ON DELETE SET NULL,
  reason TEXT NOT NULL,
  late_minutes INTEGER NOT NULL DEFAULT 0,
  penalty_percent REAL NOT NULL DEFAULT 50,
  starts_at TEXT NOT NULL,
  ends_at TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('pending','active','cancelled','expired')),
  approved_by INTEGER REFERENCES users(id),
  created_by INTEGER REFERENCES users(id),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS commissions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id INTEGER NOT NULL UNIQUE REFERENCES orders(id) ON DELETE CASCADE,
  driver_id INTEGER NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  delivery_fee INTEGER NOT NULL,
  base_commission INTEGER NOT NULL,
  penalty_id INTEGER REFERENCES penalties(id) ON DELETE SET NULL,
  penalty_percent REAL NOT NULL DEFAULT 0,
  penalty_reduction INTEGER NOT NULL DEFAULT 0,
  driver_commission_final INTEGER NOT NULL,
  restaurant_share_from_delivery INTEGER NOT NULL,
  restaurant_share_from_penalty INTEGER NOT NULL DEFAULT 0,
  calculated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS settlements (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  driver_id INTEGER NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  settlement_date TEXT NOT NULL,
  order_count INTEGER NOT NULL DEFAULT 0,
  total_food_price INTEGER NOT NULL DEFAULT 0,
  total_delivery_fee INTEGER NOT NULL DEFAULT 0,
  total_cash_collected INTEGER NOT NULL DEFAULT 0,
  expected_return_to_restaurant INTEGER NOT NULL DEFAULT 0,
  amount_returned_by_driver INTEGER NOT NULL DEFAULT 0,
  remaining_on_driver INTEGER NOT NULL DEFAULT 0,
  gross_driver_commission INTEGER NOT NULL DEFAULT 0,
  total_penalty_reduction INTEGER NOT NULL DEFAULT 0,
  final_driver_commission INTEGER NOT NULL DEFAULT 0,
  penalty_count INTEGER NOT NULL DEFAULT 0,
  total_penalty_minutes INTEGER NOT NULL DEFAULT 0,
  created_by INTEGER REFERENCES users(id),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(driver_id, settlement_date)
);

CREATE TABLE IF NOT EXISTS audit_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  actor_user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id INTEGER,
  old_value TEXT,
  new_value TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT OR IGNORE INTO restaurant_settings (id) VALUES (1);
