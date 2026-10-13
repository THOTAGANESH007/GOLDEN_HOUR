/**
 * AllergiesBadges.jsx
 * Shows allergy tags (amber) and chronic conditions (blue).
 */
export default function AllergiesBadges({ allergies = [], conditions = [] }) {
  const hasAllergies = allergies.length > 0;
  const hasConditions = conditions.length > 0;

  if (!hasAllergies && !hasConditions) return null;

  return (
    <>
      {hasAllergies && (
        <div className="card">
          <div className="card-header">
            <span className="icon">⚠️</span>
            Allergies
          </div>
          <div className="card-body">
            <div className="badges" role="list" aria-label="Allergies">
              {allergies.map((a, i) => (
                <span key={i} className="badge badge-allergy" role="listitem">
                  {a}
                </span>
              ))}
            </div>
          </div>
        </div>
      )}

      {hasConditions && (
        <div className="card">
          <div className="card-header">
            <span className="icon">🫀</span>
            Chronic Conditions
          </div>
          <div className="card-body">
            <div className="badges" role="list" aria-label="Chronic conditions">
              {conditions.map((c, i) => (
                <span key={i} className="badge badge-condition" role="listitem">
                  {c}
                </span>
              ))}
            </div>
          </div>
        </div>
      )}
    </>
  );
}
