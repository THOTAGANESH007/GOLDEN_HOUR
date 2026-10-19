import React from 'react';

export default function PrivacyPolicy() {
  return (
    <div style={{ maxWidth: '800px', margin: '0 auto', padding: '40px 20px', fontFamily: 'system-ui, -apple-system, sans-serif', color: '#1a202c', lineHeight: '1.7' }}>
      <header style={{ borderBottom: '2px solid #e2e8f0', paddingBottom: '20px', marginBottom: '30px' }}>
        <h1 style={{ fontSize: '2.2rem', color: '#b7791f', margin: '0 0 10px 0' }}>Golden Hour — Privacy Policy</h1>
        <p style={{ color: '#718096', margin: 0 }}>
          <strong>Effective Date:</strong> October 18, 2026 | <strong>Jurisdiction:</strong> India (DPDPA 2023 Compliant)
        </p>
      </header>

      <section style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '1.4rem', color: '#2d3748' }}>1. Introduction & Overview</h2>
        <p>
          Golden Hour ("we", "our", or "us") provides a universal medical emergency QR code platform designed to deliver critical, lifesaving health information to first responders and bystanders during the critical "Golden Hour" of a medical emergency.
        </p>
        <p>
          We are committed to safeguarding your personal and sensitive health data in strict compliance with India's <strong>Digital Personal Data Protection Act (DPDPA 2023)</strong> and Google Play’s User Data Policies.
        </p>
      </section>

      <section style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '1.4rem', color: '#2d3748' }}>2. Data We Collect</h2>
        <ul>
          <li><strong>Identity & Contact Information:</strong> Mobile phone number (used for secure OTP authentication), full name, date of birth, gender, and profile photo (optional).</li>
          <li><strong>Emergency Medical Data:</strong> Blood group, severe drug/food allergies, chronic medical conditions (e.g. Diabetes, Asthma), current medications, past surgeries, medical implants, and organ donor status.</li>
          <li><strong>Emergency Contacts:</strong> Names, phone numbers, and relationships of individuals you designate to receive automated SMS/WhatsApp alerts upon QR scan.</li>
          <li><strong>Emergency Incident Information:</strong> Timestamp, approximate GPS coordinates (if voluntarily shared by the bystander/responder), and attending paramedic/hospital name.</li>
        </ul>
      </section>

      <section style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '1.4rem', color: '#2d3748' }}>3. How Your Data Is Used</h2>
        <ul>
          <li>To display vital medical information to emergency responders and Good Samaritans when your physical QR code is scanned.</li>
          <li>To automatically dispatch emergency alerts via SMS, WhatsApp, and push notifications to your emergency contacts.</li>
          <li>To maintain an emergency scan history audit log within your mobile app.</li>
        </ul>
        <p><strong>We NEVER sell, rent, monetize, or use your health data for targeted advertising.</strong></p>
      </section>

      <section style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '1.4rem', color: '#2d3748' }}>4. Privacy-by-Design Architecture</h2>
        <ul>
          <li><strong>Opaque QR Identifiers:</strong> QR codes encode ONLY a secure, random 8-character token (e.g., <code>/p/X7K2M9QP</code>). No Personally Identifiable Information (PII) is stored in the QR code itself.</li>
          <li><strong>Per-Field Privacy Controls:</strong> You can hide non-critical fields (such as your full name, photo, or date of birth) from the public emergency screen at any time via in-app privacy toggles.</li>
          <li><strong>Instant QR Deactivation & Regeneration:</strong> If you lose your helmet sticker or card, you can invalidate the QR code in 1 tap from the mobile app.</li>
        </ul>
      </section>

      <section style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '1.4rem', color: '#2d3748' }}>5. Data Retention & Right to Erasure (DPDPA 2023)</h2>
        <p>
          In accordance with Section 12 of the Digital Personal Data Protection Act (DPDPA 2023), you hold the unconditional right to erase your data:
        </p>
        <p>
          You can permanently delete your account and all associated medical data, contacts, and scan records at any time directly inside the app: <strong>Settings → Delete Account (DPDPA Right to Erasure)</strong>. Deletion is instantaneous and permanent.
        </p>
      </section>

      <section style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '1.4rem', color: '#2d3748' }}>6. Data Security</h2>
        <p>
          All data in transit is encrypted using TLS 1.3. Database storage is protected via Row-Level Security (RLS) policies and AES-256 encryption at rest. Access is strictly audited.
        </p>
      </section>

      <section style={{ marginBottom: '30px', background: '#f7fafc', padding: '20px', borderRadius: '8px' }}>
        <h2 style={{ fontSize: '1.2rem', color: '#2d3748', margin: '0 0 10px 0' }}>7. Grievance Officer & Contact Information</h2>
        <p style={{ margin: 0 }}>
          Under the Information Technology Act and DPDPA 2023, for any privacy inquiries, complaints, or rights requests, contact our designated Grievance Officer:
        </p>
        <p style={{ margin: '10px 0 0 0' }}>
          <strong>Email:</strong> <a href="mailto:privacy@goldenhr.in" style={{ color: '#b7791f' }}>privacy@goldenhr.in</a><br />
          <strong>Grievance Officer:</strong> Data Protection Officer, Golden Hour Healthcare<br />
          <strong>Location:</strong> Hyderabad, Telangana, India
        </p>
      </section>
    </div>
  );
}
