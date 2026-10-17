import axios from 'axios';

const BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api/v1';

const api = axios.create({
  baseURL: BASE_URL,
  timeout: 10000,
});

/**
 * Fetch public patient profile for a given QR UID.
 * Optionally passes responder info and GPS coordinates.
 */
export async function fetchPublicProfile({
  uid,
  responderName,
  responderHospital,
  latitude,
  longitude,
}) {
  const params = {};
  if (responderName) params.responder_name = responderName;
  if (responderHospital) params.responder_hospital = responderHospital;
  if (latitude !== null && latitude !== undefined) params.latitude = latitude;
  if (longitude !== null && longitude !== undefined) params.longitude = longitude;

  const response = await api.get(`/qr/public/${uid}`, { params });
  return response.data;
}

/**
 * Update scan event with responder info, GPS coordinates, or false alarm flag.
 */
export async function updateScanEvent(scanEventId, {
  responderName,
  responderHospital,
  latitude,
  longitude,
  isFalseAlarm,
}) {
  const payload = {};
  if (responderName !== undefined) payload.responder_name = responderName;
  if (responderHospital !== undefined) payload.responder_hospital = responderHospital;
  if (latitude !== undefined) payload.latitude = latitude;
  if (longitude !== undefined) payload.longitude = longitude;
  if (isFalseAlarm !== undefined) payload.is_false_alarm = isFalseAlarm;

  const response = await api.patch(`/qr/public/scan/${scanEventId}`, payload);
  return response.data;
}

export default api;
