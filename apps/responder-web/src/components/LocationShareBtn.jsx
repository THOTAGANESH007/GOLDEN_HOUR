import { useState } from 'react';
import { updateScanEvent } from '../services/api';

/**
 * LocationShareBtn.jsx
 * Gets the responder's GPS, syncs it to the scan event in backend,
 * and opens it in Google Maps with one-tap clipboard copy.
 */
export default function LocationShareBtn({ scanEventId, onLocationCaptured }) {
  const [status, setStatus] = useState('idle'); // idle | loading | done | error
  const [mapsUrl, setMapsUrl] = useState(null);
  const [synced, setSynced] = useState(false);
  const [locationArea, setLocationArea] = useState('');
  const [copied, setCopied] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');
  const [loadingMsg, setLoadingMsg] = useState('Acquiring high-accuracy GPS coordinates…');

  const handleShare = () => {
    if (!navigator.geolocation) {
      setErrorMsg('Geolocation is not supported by your browser.');
      setStatus('error');
      return;
    }

    setStatus('loading');
    setErrorMsg('');
    setLoadingMsg('Acquiring GPS fix…');

    const handleSuccess = async (pos) => {
      const { latitude, longitude } = pos.coords;
      const url = `https://www.google.com/maps?q=${latitude},${longitude}`;
      setMapsUrl(url);
      setStatus('done');
      if (onLocationCaptured) onLocationCaptured({ latitude, longitude });

      if (scanEventId) {
        try {
          const res = await updateScanEvent(scanEventId, { latitude, longitude });
          if (res?.location_area) {
            setLocationArea(res.location_area);
          }
          setSynced(true);
        } catch (e) {
          console.warn('GPS backend sync fallback:', e);
        }
      }
    };

    // First attempt: High-accuracy with 20-second timeout to allow permission grant
    navigator.geolocation.getCurrentPosition(
      handleSuccess,
      (err) => {
        // If high accuracy times out or fails, fallback to coarse/network location
        if (err.code === 3 || err.code === 2) {
          setLoadingMsg('Refining with cellular / Wi-Fi network location…');
          navigator.geolocation.getCurrentPosition(
            handleSuccess,
            (fallbackErr) => {
              if (fallbackErr.code === 1) {
                setErrorMsg('Location permission was denied. Please allow location in your browser address bar and try again.');
              } else {
                setErrorMsg('GPS signal timed out. Please ensure phone location is enabled in settings and try again.');
              }
              setStatus('error');
            },
            { timeout: 20000, enableHighAccuracy: false, maximumAge: 300000 }
          );
        } else if (err.code === 1) {
          setErrorMsg('Location permission was denied. Please allow location in your browser address bar and try again.');
          setStatus('error');
        } else {
          setErrorMsg('Location unavailable. Please check device location settings.');
          setStatus('error');
        }
      },
      { timeout: 20000, enableHighAccuracy: true, maximumAge: 60000 }
    );
  };

  const handleCopy = () => {
    if (mapsUrl) {
      navigator.clipboard.writeText(mapsUrl);
      setCopied(true);
      setTimeout(() => setCopied(false), 2500);
    }
  };

  return (
    <div className="card">
      <div className="card-header">
        <span className="icon">📍</span>
        Live Scene Location
      </div>
      <div className="card-body location-btn-wrap">
        {status === 'idle' && (
          <button
            id="share-location-btn"
            className="btn btn-location"
            style={{ width: '100%' }}
            onClick={handleShare}
            aria-label="Share responder location"
          >
            📍 Share My GPS Location with Family
          </button>
        )}
        {status === 'loading' && (
          <div style={{ textAlign: 'center', padding: '8px 0' }}>
            <div className="spinner" style={{ width: 28, height: 28, margin: '0 auto 8px', borderWidth: 3 }} />
            <p style={{ color: 'var(--gray-600)', fontSize: 14 }}>
              {loadingMsg}
            </p>
          </div>
        )}
        {status === 'done' && mapsUrl && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {synced && (
              <div className="synced-badge">
                ✓ Location {locationArea ? `near ${locationArea} ` : ''}securely logged to patient record
              </div>
            )}
            <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
              <a
                className="btn btn-location"
                href={mapsUrl}
                target="_blank"
                rel="noopener noreferrer"
                style={{ flex: 1, justifyContent: 'center' }}
              >
                🗺️ Open in Google Maps
              </a>
              <button
                id="copy-location-btn"
                className="btn btn-secondary"
                style={{ flex: 1 }}
                onClick={handleCopy}
              >
                {copied ? '✓ Link Copied!' : '📋 Copy Map Link'}
              </button>
            </div>
          </div>
        )}
        {status === 'error' && (
          <div style={{ textAlign: 'center', padding: '8px 4px' }}>
            <p style={{ color: 'var(--red)', fontSize: 13, marginBottom: 10, lineHeight: 1.4 }}>
              {errorMsg || 'Location access denied or unavailable.'}
            </p>
            <button className="btn btn-secondary" onClick={handleShare}>
              🔄 Try Again
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
