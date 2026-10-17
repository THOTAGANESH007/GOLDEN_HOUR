import { useState, useEffect, useCallback } from 'react';
import { useParams } from 'react-router-dom';
import { fetchPublicProfile, updateScanEvent } from '../services/api';
import CriticalInfoCard from '../components/CriticalInfoCard';
import AllergiesBadges from '../components/AllergiesBadges';
import MedicationList from '../components/MedicationList';
import EmergencyContacts from '../components/EmergencyContacts';
import LocationShareBtn from '../components/LocationShareBtn';
import EmergencyHelplineBar from '../components/EmergencyHelplineBar';
import ClinicalActionsBar from '../components/ClinicalActionsBar';

export default function EmergencyProfile() {
  const { uid } = useParams();
  const [profile, setProfile] = useState(null);
  const [status, setStatus] = useState('loading'); // loading | ok | deactivated | notfound | error
  const [responderName, setResponderName] = useState('');
  const [responderHospital, setResponderHospital] = useState('');
  const [responderSaved, setResponderSaved] = useState(false);
  const [savingResponder, setSavingResponder] = useState(false);
  const [gps, setGps] = useState({ latitude: null, longitude: null });
  const [darkMode, setDarkMode] = useState(() => {
    return localStorage.getItem('goldenhour_theme') === 'dark';
  });

  useEffect(() => {
    if (darkMode) {
      document.body.classList.add('dark-mode');
      localStorage.setItem('goldenhour_theme', 'dark');
    } else {
      document.body.classList.remove('dark-mode');
      localStorage.setItem('goldenhour_theme', 'light');
    }
  }, [darkMode]);

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
      if (err.response?.status === 403 || err.response?.data?.detail === 'QR_DEACTIVATED') {
        setStatus('deactivated');
      } else if (err.response?.status === 404) {
        setStatus('notfound');
      } else {
        setStatus('error');
      }
    }
  }, [uid, responderName, responderHospital, gps]);

  useEffect(() => {
    load();
  }, [uid]); // eslint-disable-line

  const handleSaveResponder = async (e) => {
    e?.preventDefault();
    if (!profile?.scan_event_id) return;
    setSavingResponder(true);
    try {
      await updateScanEvent(profile.scan_event_id, {
        responderName: responderName || undefined,
        responderHospital: responderHospital || undefined,
      });
      setResponderSaved(true);
      setTimeout(() => setResponderSaved(false), 3000);
    } catch (err) {
      console.warn('Failed to update responder details:', err);
    } finally {
      setSavingResponder(false);
    }
  };

  if (status === 'loading') {
    return (
      <div className="loading-wrap">
        <div className="spinner" role="status" aria-label="Loading" />
        <p style={{ color: 'var(--gray-600)' }}>Accessing secure emergency medical record…</p>
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
          📞 Call 108 — Ambulance
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
          📞 Call 108 — Ambulance
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
          Could not load patient data. Check your mobile connection.
        </p>
        <button className="btn btn-secondary" style={{ marginTop: 24 }} onClick={load}>
          🔄 Retry Connection
        </button>
      </div>
    );
  }

  return (
    <>
      {/* Emergency Header */}
      <header className="emergency-header" role="banner">
        <div className="header-top">
          <div className="logo">GOLDEN HOUR MEDICAL ID</div>
          <button
            className="theme-toggle-btn"
            onClick={() => setDarkMode((prev) => !prev)}
            aria-label="Toggle dark mode"
          >
            {darkMode ? '☀️ Light' : '🌙 Dark'}
          </button>
        </div>
        <h1>Emergency Medical Record</h1>
        <div className="active-pulse-badge">
          <span className="pulse-dot" />
          ACTIVE EMERGENCY RESPONSE SESSION
        </div>
      </header>

      <main className="container" role="main">
        {/* Instant Indian Emergency Helplines Speed Dial */}
        <EmergencyHelplineBar />

        {/* Clinical Quick Tools: Audio Readout, Print Chart, Copy Summary */}
        <ClinicalActionsBar profile={profile} />

        {/* Critical Info Card: Blood Group + Name + Organ Donor */}
        <CriticalInfoCard profile={profile} />

        {/* Allergies & Chronic Conditions */}
        <AllergiesBadges
          allergies={profile.allergies}
          conditions={profile.chronic_conditions}
        />

        {/* Emergency Contacts with Instant Call & WhatsApp */}
        <EmergencyContacts contacts={profile.contacts} />

        {/* Current Medications */}
        <MedicationList medications={profile.medications} />

        {/* Live Scene Location Sharing */}
        <LocationShareBtn
          scanEventId={profile.scan_event_id}
          onLocationCaptured={({ latitude, longitude }) =>
            setGps({ latitude, longitude })
          }
        />

        {/* Responder Info Form */}
        <div className="card">
          <div className="card-header">
            <span className="icon">🏥</span>
            Attending Responder / Paramedic
          </div>
          <div className="card-body">
            <form onSubmit={handleSaveResponder} className="responder-form">
              <div className="form-group">
                <label htmlFor="responder-name">Your Name / ID</label>
                <input
                  id="responder-name"
                  type="text"
                  placeholder="e.g. Dr. A. Kumar / Paramedic 402"
                  value={responderName}
                  onChange={(e) => setResponderName(e.target.value)}
                  aria-label="Responder name"
                />
              </div>
              <div className="form-group">
                <label htmlFor="responder-hospital">Hospital / Ambulance Station</label>
                <input
                  id="responder-hospital"
                  type="text"
                  placeholder="e.g. Apollo Hospital, Hyderabad / 108 Crew"
                  value={responderHospital}
                  onChange={(e) => setResponderHospital(e.target.value)}
                  aria-label="Responder hospital"
                />
              </div>
              <div style={{ display: 'flex', gap: 8, alignItems: 'center', marginTop: 4 }}>
                <button
                  type="submit"
                  className="btn btn-secondary"
                  disabled={savingResponder}
                  style={{ flex: 1 }}
                >
                  {savingResponder ? 'Saving…' : '💾 Attach My Details to Alert'}
                </button>
                {responderSaved && (
                  <span style={{ color: 'var(--green)', fontSize: 13, fontWeight: 700 }}>
                    ✓ Attached!
                  </span>
                )}
              </div>
            </form>
          </div>
        </div>

        {/* Doctor Info */}
        {(profile.doctor_name || profile.doctor_phone) && (
          <div className="card">
            <div className="card-header">
              <span className="icon">👨‍⚕️</span>
              Primary Treating Physician
            </div>
            <div className="card-body">
              {profile.doctor_name && (
                <div className="info-row">
                  <span className="info-label">Doctor Name</span>
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
                    📞 Call Treating Doctor
                  </a>
                </div>
              )}
            </div>
          </div>
        )}

        {/* Medical History */}
        {((profile.past_surgeries?.length > 0) || (profile.implants?.length > 0)) && (
          <div className="card">
            <div className="card-header">
              <span className="icon">🔬</span>
              Surgical & Implant History
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

        {/* Primary Call 108 Emergency Services */}
        <a
          id="call-emergency-services"
          className="btn btn-call"
          href="tel:108"
          style={{
            display: 'flex',
            marginTop: 22,
            width: '100%',
            justifyContent: 'center',
            fontSize: 18,
            padding: '16px 20px',
            boxShadow: 'var(--shadow-lg)',
          }}
          aria-label="Call 108 emergency services"
        >
          🚨 Call 108 — Ambulance Services
        </a>

        {/* Medical Disclaimer */}
        <footer className="disclaimer" role="note">
          ⚠️ <strong>Medical Disclaimer:</strong> Information is self-reported by the patient or their guardian.
          Verify clinically before administering emergency pharmacological treatment.
          Secured by <strong>Golden Hour Platform</strong>.
        </footer>
      </main>

      {/* noscript fallback */}
      <noscript>
        <div style={{ padding: 24, background: '#fff3cd', textAlign: 'center', color: '#856404' }}>
          <strong>JavaScript is disabled.</strong> Please enable JavaScript to access full interactive emergency tools.
          For immediate ambulance dispatch, dial <a href="tel:108" style={{ fontWeight: 'bold' }}>108</a>.
        </div>
      </noscript>
    </>
  );
}
