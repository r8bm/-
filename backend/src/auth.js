const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { get } = require('./db');
const secret = process.env.JWT_SECRET || 'dev-secret';
function hashPassword(password) { return bcrypt.hashSync(password, 10); }
function verifyPassword(password, hash) { return bcrypt.compareSync(password, hash); }
function signToken(user) { return jwt.sign({ sub: user.id, role: user.role, name: user.name, phone: user.phone }, secret, { expiresIn: '30d' }); }
function requireAuth(req, res, next) {
  try {
    const auth = req.headers.authorization || '';
    const token = auth.startsWith('Bearer ') ? auth.slice(7) : null;
    if (!token) return res.status(401).json({ error: 'Unauthorized' });
    const payload = jwt.verify(token, secret);
    const user = get().users.find(u => Number(u.id) === Number(payload.sub));
    if (!user || !user.is_active) return res.status(401).json({ error: 'User disabled or not found' });
    req.user = { id: user.id, role: user.role, name: user.name, phone: user.phone, is_active: user.is_active };
    next();
  } catch (_) { res.status(401).json({ error: 'Invalid token' }); }
}
function requireRole(...roles) { return (req, res, next) => roles.includes(req.user?.role) ? next() : res.status(403).json({ error: 'Forbidden' }); }
module.exports = { hashPassword, verifyPassword, signToken, requireAuth, requireRole };
