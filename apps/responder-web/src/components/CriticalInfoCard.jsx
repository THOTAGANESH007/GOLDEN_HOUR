/**
 * CriticalInfoCard.jsx
 * Displays blood group prominently + patient name, donor status.
 */
export default function CriticalInfoCard({ profile }) {
  const { full_name, blood_group, is_organ_donor } = profile;

  return (
    <div className="card critical-card">
      <div className="card-header">
        <span className="icon">🩸</span>
        Critical Medical Info
      </div>
      <div className="card-body">
        {blood_group ? (
          <>
            <div className="blood-group" aria-label={`Blood group ${blood_group}`}>
              {blood_group}
            </div>
            <div className="blood-group-label">Blood Group</div>
          </>
        ) : (
          <p className="no-data" style={{ marginBottom: 12 }}>
            Blood group not recorded
          </p>
        )}

        {full_name && (
          <div className="info-row">
            <span className="info-label">Patient Name</span>
            <span className="info-value">{full_name}</span>
          </div>
        )}

        {is_organ_donor && (
          <div className="donor-badge" aria-label="Organ donor">
            💚 Registered Organ Donor
          </div>
        )}
      </div>
    </div>
  );
}
