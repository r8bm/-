require('dotenv').config();
const fs = require('fs');
const path = require('path');
const dbPath = path.resolve(process.cwd(), process.env.DB_PATH || './data/delivery.json');

const empty = () => ({
  seq: { users: 0, drivers: 0, consents: 0, orders: 0, driver_locations: 0, penalties: 0, commissions: 0, settlements: 0, audit_logs: 0 },
  users: [], drivers: [], consents: [], orders: [], driver_locations: [], penalties: [], commissions: [], settlements: [], audit_logs: [],
  settings: {
    id: 1,
    restaurant_name: 'My Restaurant', restaurant_lat: 31.04219, restaurant_lng: 46.25726,
    geofence_radius_meters: 100, average_return_speed_kmh: 25, return_buffer_minutes: 10, minimum_return_minutes: 10,
    commission_type: 'fixed', fixed_commission_amount: 3000, commission_delivery_fee_percent: 70,
    daily_salary_amount: 0, per_order_commission_amount: 1000,
    penalty_enabled: 1, auto_penalty_enabled: 0, penalty_percent: 50, penalty_duration_minutes: 60, require_manager_approval_for_penalty: 1,
    created_at: new Date().toISOString(), updated_at: new Date().toISOString()
  }
});
let data = null;
function ensure() { fs.mkdirSync(path.dirname(dbPath), { recursive: true }); if (!fs.existsSync(dbPath)) fs.writeFileSync(dbPath, JSON.stringify(empty(), null, 2)); }
function load() { ensure(); data = JSON.parse(fs.readFileSync(dbPath, 'utf8')); return data; }
function save() { ensure(); fs.writeFileSync(dbPath, JSON.stringify(data, null, 2)); }
function get() { if (!data) load(); return data; }
function reset(newData) { data = newData || empty(); save(); return data; }
function nextId(table) { const d=get(); d.seq[table] = (d.seq[table] || 0) + 1; return d.seq[table]; }
function insert(table, row) { const d=get(); const now = new Date().toISOString(); const item = { id: nextId(table), created_at: now, ...row }; d[table].push(item); save(); return item; }
function update(table, id, patch) { const d=get(); const i = d[table].findIndex(x => Number(x.id) === Number(id)); if (i < 0) return null; d[table][i] = { ...d[table][i], ...patch, updated_at: new Date().toISOString() }; save(); return d[table][i]; }
function remove(table, id) { const d=get(); const i = d[table].findIndex(x => Number(x.id) === Number(id)); if (i < 0) return false; d[table].splice(i, 1); save(); return true; }
function audit(actor, action, entity_type, entity_id, old_value, new_value) { return insert('audit_logs', { actor_user_id: actor?.id || null, action, entity_type, entity_id: entity_id || null, old_value, new_value }); }
function nowIso() { return new Date().toISOString(); }
module.exports = { get, load, save, reset, empty, insert, update, remove, audit, nowIso, dbPath };
