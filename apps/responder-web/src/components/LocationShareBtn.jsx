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
  const [copied, setCopied] = useState(false);

  const handleShare = () => {
    if (!navigator.geolocation) {
      setStatus('error');
      return;
    }

    setStatus('loading');
    navigator.geolocation.getCurrentPosition(
      async (pos) => {
        const { latitude, longitude } = pos.coords;
        const url = `https://www.google.com/maps?q=${latitude},${longitude}`;
        setMapsUrl(url);
        setStatus('done');
        if (onLocationCaptured) onLocationCaptured({ latitude, longitude });

        if (scanEventId) {
          try {
            await updateScanEvent(scanEventId, { latitude, longitude });
            setSynced(true);
          } catch (e) {
            console.warn('GPS backend sync fallback:', e);
          }
        }
      },
      () => setStatus('error'),
      { timeout: 9000, enableHighAccuracy: true }
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
              Acquiring high-accuracy GPS coordinates…
            </p>
          </div>
        )}
        {status === 'done' && mapsUrl && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {synced && (
              <div className="synced-badge">
                ✓ GPS coordinates securely logged to patient record
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
          <div style={{ textAlign: 'center' }}>
            <p style={{ color: 'var(--red)', fontSize: 14, marginBottom: 8 }}>
              Location access denied or unavailable.
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
