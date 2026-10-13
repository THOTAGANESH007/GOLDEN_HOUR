import { useState } from 'react';

/**
 * LocationShareBtn.jsx
 * Gets the responder's GPS and opens it in Google Maps,
 * also copies the link to clipboard for sharing.
 */
export default function LocationShareBtn({ onLocationCaptured }) {
  const [status, setStatus] = useState('idle'); // idle | loading | done | error
  const [mapsUrl, setMapsUrl] = useState(null);

  const handleShare = () => {
    if (!navigator.geolocation) {
      setStatus('error');
      return;
    }

    setStatus('loading');
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        const { latitude, longitude } = pos.coords;
        const url = `https://www.google.com/maps?q=${latitude},${longitude}`;
        setMapsUrl(url);
        setStatus('done');
        if (onLocationCaptured) onLocationCaptured({ latitude, longitude });
      },
      () => setStatus('error'),
      { timeout: 8000 }
    );
  };

  const handleCopy = () => {
    if (mapsUrl) navigator.clipboard.writeText(mapsUrl);
  };

  return (
    <div className="card">
      <div className="card-header">
        <span className="icon">📍</span>
        Share Your Location
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
            📍 Share My Location with Family
          </button>
        )}
        {status === 'loading' && (
          <p style={{ textAlign: 'center', color: '#4b5563' }}>
            Getting your location…
          </p>
        )}
        {status === 'done' && mapsUrl && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            <a
              className="btn btn-location"
              href={mapsUrl}
              target="_blank"
              rel="noopener noreferrer"
              style={{ width: '100%', justifyContent: 'center' }}
            >
              📍 Open in Google Maps
            </a>
            <button
              id="copy-location-btn"
              className="btn btn-secondary"
              style={{ width: '100%' }}
              onClick={handleCopy}
            >
              📋 Copy Location Link
            </button>
          </div>
        )}
        {status === 'error' && (
          <p style={{ color: '#e53e3e', textAlign: 'center', fontSize: 14 }}>
            Could not get location. Please share manually.
          </p>
        )}
      </div>
    </div>
  );
}
