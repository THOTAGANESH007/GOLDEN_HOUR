/**
 * EmergencyHelplineBar.jsx
 * Quick speed-dial access for Indian national emergency services (108, 112, 100, 101).
 */
export default function EmergencyHelplineBar() {
  const helplines = [
    { label: 'Ambulance', number: '108', icon: '🚑', color: 'var(--red)' },
    { label: 'Emergency', number: '112', icon: '🚨', color: 'var(--orange)' },
    { label: 'Police', number: '100', icon: '👮', color: 'var(--blue)' },
    { label: 'Fire', number: '101', icon: '🚒', color: '#c53030' },
  ];

  return (
    <div className="card helplines-card">
      <div className="card-header">
        <span className="icon">🆘</span>
        Emergency Helplines (India)
      </div>
      <div className="card-body">
        <div className="helpline-grid">
          {helplines.map((h) => (
            <a
              key={h.number}
              href={`tel:${h.number}`}
              className="helpline-btn"
              aria-label={`Call ${h.label} ${h.number}`}
            >
              <span className="helpline-icon">{h.icon}</span>
              <span className="helpline-number">{h.number}</span>
              <span className="helpline-label">{h.label}</span>
            </a>
          ))}
        </div>
      </div>
    </div>
  );
}
