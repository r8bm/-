const { get, insert, update } = require('./db');
function roundMoney(v) { return Math.round(Number(v || 0)); }
function getSettings() { return get().settings; }
function baseCommissionForOrder(order, settings = getSettings()) {
  if (settings.commission_type === 'delivery_fee_percent') return roundMoney(order.delivery_fee * (settings.commission_delivery_fee_percent / 100));
  if (settings.commission_type === 'daily_salary_plus_per_order') return roundMoney(settings.per_order_commission_amount);
  return roundMoney(settings.fixed_commission_amount);
}
function activePenaltyForDriverAt(driverId, isoTime) {
  return get().penalties.filter(p => Number(p.driver_id) === Number(driverId) && p.status === 'active' && new Date(p.starts_at) <= new Date(isoTime) && new Date(p.ends_at) >= new Date(isoTime)).sort((a,b)=>new Date(b.created_at)-new Date(a.created_at))[0] || null;
}
function calculateAndStoreCommission(orderId) {
  const d = get(); const order = d.orders.find(o => Number(o.id) === Number(orderId));
  if (!order || !order.driver_id || !order.delivered_at) return null;
  const base = baseCommissionForOrder(order, d.settings);
  const penalty = activePenaltyForDriverAt(order.driver_id, order.delivered_at);
  const penaltyPercent = penalty ? Number(penalty.penalty_percent) : 0;
  const reduction = roundMoney(base * (penaltyPercent / 100));
  const payload = { order_id: order.id, driver_id: order.driver_id, delivery_fee: order.delivery_fee, base_commission: base, penalty_id: penalty?.id || null, penalty_percent: penaltyPercent, penalty_reduction: reduction, driver_commission_final: Math.max(0, base - reduction), restaurant_share_from_delivery: Math.max(0, order.delivery_fee - base), restaurant_share_from_penalty: reduction, calculated_at: new Date().toISOString() };
  const existing = d.commissions.find(c => Number(c.order_id) === Number(orderId));
  if (existing) return update('commissions', existing.id, payload);
  return insert('commissions', payload);
}
module.exports = { getSettings, baseCommissionForOrder, activePenaltyForDriverAt, calculateAndStoreCommission };
