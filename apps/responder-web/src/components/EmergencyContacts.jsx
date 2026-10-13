/**
 * EmergencyContacts.jsx
 * One-tap call + WhatsApp buttons for each emergency contact.
 */
export default function EmergencyContacts({ contacts = [] }) {
  if (!contacts || contacts.length === 0) {
    return (
      <div className="card">
        <div className="card-header">
          <span className="icon">📞</span>
          Emergency Contacts
        </div>
        <div className="card-body">
          <p className="no-data">No emergency contacts registered</p>
        </div>
      </div>
    );
  }

  return (
    <div className="card">
      <div className="card-header">
        <span className="icon">📞</span>
        Emergency Contacts
      </div>
      <div className="card-body" role="list" aria-label="Emergency contacts">
        {contacts.map((contact, i) => (
          <div className="contact-item" key={i} role="listitem">
            <div>
              <div className="contact-name">{contact.name}</div>
              <div className="contact-relation">{contact.relation}</div>
            </div>
            <div className="contact-actions">
              <a
                id={`call-contact-${i}`}
                className="btn btn-call"
                href={`tel:${contact.phone}`}
                aria-label={`Call ${contact.name}`}
              >
                📞 Call
              </a>
              {contact.whatsapp_enabled && (
                <a
                  id={`whatsapp-contact-${i}`}
                  className="btn btn-whatsapp"
                  href={`https://wa.me/${contact.phone.replace('+', '')}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  aria-label={`WhatsApp ${contact.name}`}
                >
                  💬 WhatsApp
                </a>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
