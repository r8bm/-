function toRad(value) { return (value * Math.PI) / 180; }

function haversineKm(lat1, lng1, lat2, lng2) {
  const earthKm = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a = Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return 2 * earthKm * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function isInsideGeofence(lat, lng, centerLat, centerLng, radiusMeters) {
  return haversineKm(lat, lng, centerLat, centerLng) * 1000 <= radiusMeters;
}

function calculateAllowedReturn({ customerLat, customerLng, restaurantLat, restaurantLng, averageReturnSpeedKmh, returnBufferMinutes, minimumReturnMinutes }) {
  const distanceKm = haversineKm(customerLat, customerLng, restaurantLat, restaurantLng);
  const travelMinutes = (distanceKm / Math.max(averageReturnSpeedKmh, 1)) * 60;
  const allowed = Math.max(minimumReturnMinutes, Math.ceil(travelMinutes + returnBufferMinutes));
  return { distanceKm: Number(distanceKm.toFixed(3)), allowedReturnMinutes: allowed };
}

function addMinutesIso(startDate, minutes) {
  return new Date(new Date(startDate).getTime() + minutes * 60_000).toISOString();
}

function diffMinutesLate(deadlineIso, actualIso) {
  const late = Math.ceil((new Date(actualIso).getTime() - new Date(deadlineIso).getTime()) / 60_000);
  return Math.max(0, late);
}

module.exports = { haversineKm, isInsideGeofence, calculateAllowedReturn, addMinutesIso, diffMinutesLate };
