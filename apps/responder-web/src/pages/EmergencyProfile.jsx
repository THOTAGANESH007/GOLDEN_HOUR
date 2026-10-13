import { useState, useEffect, useCallback } from 'react';
import { useParams } from 'react-router-dom';
import { fetchPublicProfile } from '../services/api';
import CriticalInfoCard from '../components/CriticalInfoCard';
import AllergiesBadges from '../components/AllergiesBadges';
import MedicationList from '../components/MedicationList';
import EmergencyContacts from '../components/EmergencyContacts';
import LocationShareBtn from '../components/LocationShareBtn';

export default function EmergencyProfile() {
  const { uid } = useParams();
  const [profile, setProfile] = useState(null);
  const [status, setStatus] = useState('loading'); // loading | ok | deactivated | notfound | error
  const [responderName, setResponderName] = useState('');
  const [responderHospital, setResponderHospital] = useState('');
  const [gps, setGps] = useState({ latitude: null, longitude: null });

  const load = useCallback(async () => {
    try {
      const data = await fetchPublicProfile({
        uid,
        responderName: responderName || undefined,
        responderHospital: responderHospital || undefined,
        latitude: gps.latitude,
        longitude: gps.longitude,
      });
      setProfile(data);
      setStatus('ok');
    } catch (err) {
      if (err.response?.status === 403) setStatus('deactivated');
      else if (err.response?.status === 404) setStatus('notfound');
      else setStatus('error');
    }
  }, [uid, responderName, responderHospital, gps]);

  useEffect(() => { load(); }, [uid]); // eslint-disable-line

  if (status === 'loading') {
    return (
      <div className="loading-wrap">
        <div className="spinner" role="status" aria-label="Loading" />
        <p style={{ color: '#4b5563' }}>Loading emergency information…</p>
      </div>
    );
  }

  if (status === 'deactivated') {
    return (
      <div className="error-wrap">
        <div className="error-icon">🔒</div>
        <h2 className="error-title">QR Deactivated</h2>
        <p className="error-desc">
          This QR code has been deactivated by the patient.
          Please contact emergency services directly.
        </p>
        <a href="tel:108" className="btn btn-call" style={{ marginTop: 24 }}>
          📞 Call 108
        </a>
      </div>
    );
  }

  if (status === 'notfound') {
    return (
      <div className="error-wrap">
        <div className="error-icon">❓</div>
        <h2 className="error-title">QR Not Found</h2>
        <p className="error-desc">
          This QR code is not registered in Golden Hour.
          Please call emergency services immediately.
        </p>
        <a href="tel:108" className="btn btn-call" style={{ marginTop: 24 }}>
          📞 Call 108
        </a>
      </div>
    );
  }

  if (status === 'error') {
    return (
      <div className="error-wrap">
        <div className="error-icon">⚠️</div>
        <h2 className="error-title">Unable to Load</h2>
        <p className="error-desc">
          Could not load patient data. Check your connection.
        </p>
        <button className="btn btn-secondary" style={{ marginTop: 24 }} onClick={load}>
          🔄 Retry
        </button>
      </div>
    );
  }

  return (
    <>
      {/* Header */}
      <div className="emergency-header" role="banner">
        <div className="logo">Golden Hour</div>
        <h1>Emergency Medical ID</h1>
        <div className="subtitle">⚡ Scanned QR — Emergency Active</div>
      </div>

      <div className="container" role="main">
        {/* Responder info form */}
        <div className="card">
          <div className="card-header">
            <span className="icon">🏥</span>
            Responder Info (Optional)
          </div>
          <div className="card-body">
            <div className="responder-form">
              <div className="form-group">
                <label htmlFor="responder-name">Your Name / ID</label>
                <input
                  id="responder-name"
                  type="text"
                  placeholder="e.g. Dr. Kumar"
                  value={responderName}
                  onChange={(e) => setResponderName(e.target.value)}
                  aria-label="Responder name"
                />
              </div>
              <div className="form-group">
                <label htmlFor="responder-hospital">Hospital / Organisation</label>
                <input
                  id="responder-hospital"
                  type="text"
                  placeholder="e.g. Apollo Hospital, Hyderabad"
                  value={responderHospital}
                  onChange={(e) => setResponderHospital(e.target.value)}
                  aria-label="Responder hospital"
                />
              </div>
            </div>
          </div>
        </div>

        {/* Critical info */}
        <CriticalInfoCard profile={profile} />

        {/* Allergies + Conditions */}
        <AllergiesBadges
          allergies={profile.allergies}
          conditions={profile.chronic_conditions}
        />

        {/* Emergency contacts */}
        <EmergencyContacts contacts={profile.contacts} />

        {/* Medications */}
        <MedicationList medications={profile.medications} />

        {/* Location sharing */}
        <LocationShareBtn
          onLocationCaptured={({ latitude, longitude }) =>
            setGps({ latitude, longitude })
          }
        />

        {/* Doctor info */}
        {(profile.doctor_name || profile.doctor_phone) && (
          <div className="card">
            <div className="card-header">
              <span className="icon">👨‍⚕️</span>
              Primary Physician
            </div>
            <div className="card-body">
              {profile.doctor_name && (
                <div className="info-row">
                  <span className="info-label">Name</span>
                  <span className="info-value">{profile.doctor_name}</span>
                </div>
              )}
              {profile.doctor_phone && (
                <div className="info-row">
                  <span className="info-label">Phone</span>
                  <a
                    id="call-doctor-btn"
                    className="btn btn-call"
                    href={`tel:${profile.doctor_phone}`}
                    style={{ marginTop: 8 }}
                    aria-label="Call primary physician"
                  >
                    📞 Call Doctor
                  </a>
                </div>
              )}
            </div>
          </div>
        )}

        {/* Medical history */}
        {((profile.past_surgeries?.length > 0) || (profile.implants?.length > 0)) && (
          <div className="card">
            <div className="card-header">
              <span className="icon">🔬</span>
              Medical History
            </div>
            <div className="card-body">
              {profile.past_surgeries?.length > 0 && (
                <div className="info-row">
                  <span className="info-label">Past Surgeries</span>
                  <span className="info-value">
                    {profile.past_surgeries.join(', ')}
                  </span>
                </div>
              )}
              {profile.implants?.length > 0 && (
                <div className="info-row">
                  <span className="info-label">Implants / Devices</span>
                  <span className="info-value">
                    {profile.implants.join(', ')}
                  </span>
                </div>
              )}
            </div>
          </div>
        )}

        {/* Call 108 */}
        <a
          id="call-emergency-services"
          className="btn btn-call"
          href="tel:108"
          style={{ display: 'flex', marginTop: 20, width: '100%', justifyContent: 'center', fontSize: 18, padding: '16px 18px' }}
          aria-label="Call 108 emergency services"
        >
          🚨 Call 108 — Emergency Services
        </a>

        {/* Disclaimer */}
        <div className="disclaimer" role="note">
          ⚠️ <strong>Medical Disclaimer:</strong> Data is self-reported by the patient.
          Always verify clinically before administering treatment.
          Powered by <strong>Golden Hour</strong>.
        </div>
      </div>

      {/* noscript fallback */}
      <noscript>
        <div style={{ padding: 20, background: '#fff3cd', textAlign: 'center' }}>
          <strong>JavaScript is disabled.</strong> Please enable it to view the patient's full medical profile.
          Call <a href="tel:108">108</a> for immediate emergency assistance.
        </div>
      </noscript>
    </>
  );
}
