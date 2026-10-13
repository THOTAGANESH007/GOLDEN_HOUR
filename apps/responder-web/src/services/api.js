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

export default api;
