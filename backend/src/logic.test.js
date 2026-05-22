const { calculateAllowedReturn, isInsideGeofence, diffMinutesLate } = require('./geo');
const result = calculateAllowedReturn({ customerLat: 31.0602, customerLng: 46.2471, restaurantLat: 31.04219, restaurantLng: 46.25726, averageReturnSpeedKmh: 25, returnBufferMinutes: 10, minimumReturnMinutes: 10 });
console.log('Allowed return test:', result);
if (result.allowedReturnMinutes < 10) throw new Error('Allowed return must respect minimum');
if (!isInsideGeofence(31.04219, 46.25726, 31.04219, 46.25726, 100)) throw new Error('Geofence center should be inside');
const late = diffMinutesLate('2026-05-22T10:00:00.000Z', '2026-05-22T10:13:01.000Z');
if (late !== 14) throw new Error(`Expected 14 late minutes, got ${late}`);
console.log('Logic tests passed.');
