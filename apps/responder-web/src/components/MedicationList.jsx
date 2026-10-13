/**
 * MedicationList.jsx
 * Displays current medications: name, dosage, frequency.
 */
export default function MedicationList({ medications = [] }) {
  if (!medications || medications.length === 0) return null;

  return (
    <div className="card">
      <div className="card-header">
        <span className="icon">💊</span>
        Current Medications
      </div>
      <div className="card-body" role="list" aria-label="Medications">
        {medications.map((med, i) => (
          <div className="med-item" key={i} role="listitem">
            <span className="med-name">{med.name}</span>
            <span className="med-detail">
              {med.dosage}
              {med.frequency ? ` — ${med.frequency}` : ''}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}
