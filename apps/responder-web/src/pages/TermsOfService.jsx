import React from 'react';

export default function TermsOfService() {
  return (
    <div style={{ maxWidth: '800px', margin: '0 auto', padding: '40px 20px', fontFamily: 'system-ui, -apple-system, sans-serif', color: '#1a202c', lineHeight: '1.7' }}>
      <header style={{ borderBottom: '2px solid #e2e8f0', paddingBottom: '20px', marginBottom: '30px' }}>
        <h1 style={{ fontSize: '2.2rem', color: '#b7791f', margin: '0 0 10px 0' }}>Golden Hour — Terms of Service</h1>
        <p style={{ color: '#718096', margin: 0 }}>
          <strong>Effective Date:</strong> October 18, 2026 | <strong>Jurisdiction:</strong> India
        </p>
      </header>

      <section style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '1.4rem', color: '#2d3748' }}>1. Acceptance of Terms</h2>
        <p>
          By creating an account, downloading the Golden Hour mobile application, or scanning a Golden Hour QR code, you agree to be bound by these Terms of Service.
        </p>
      </section>

      <section style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '1.4rem', color: '#2d3748' }}>2. Nature of Service & Medical Disclaimer</h2>
        <div style={{ background: '#fffaf0', borderLeft: '4px solid #dd6b20', padding: '16px', borderRadius: '4px', marginBottom: '15px' }}>
          <strong>CRITICAL ADVISORY:</strong> Golden Hour is an emergency information dissemination utility, NOT a healthcare provider, hospital, ambulance dispatcher, or diagnostic medical device.
        </div>
        <ul>
          <li>In an acute emergency, always dial India's emergency helpline <strong>108 (Ambulance)</strong> or <strong>112 (National Emergency)</strong> immediately.</li>
          <li>Information displayed on the emergency responder page is user-provided and intended solely as supplementary reference for attending clinicians and first responders.</li>
          <li>Good Samaritan responders scanning this QR code are protected under India's Good Samaritan guidelines approved by the Hon'ble Supreme Court of India.</li>
        </ul>
      </section>

      <section style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '1.4rem', color: '#2d3748' }}>3. User Responsibilities</h2>
        <ul>
          <li>You are solely responsible for ensuring the accuracy of your blood group, allergies, medications, and emergency contact phone numbers.</li>
          <li>You agree not to submit false, misleading, or malicious emergency information.</li>
          <li>You agree to notify your emergency contacts that their phone numbers have been registered for automated incident alerts.</li>
        </ul>
      </section>

      <section style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '1.4rem', color: '#2d3748' }}>4. Service Availability & Limitations</h2>
        <p>
          Emergency SMS and WhatsApp deliveries rely on telecommunication carriers and third-party APIs. While our backend deploys redundant multi-channel fallbacks (SMS, WhatsApp, FCM Push), Golden Hour does not guarantee delivery in areas without carrier cellular coverage.
        </p>
      </section>

      <section style={{ marginBottom: '30px' }}>
        <h2 style={{ fontSize: '1.4rem', color: '#2d3748' }}>5. Account Deletion & Termination</h2>
        <p>
          You may terminate your account at any time via the in-app "Delete Account" button. Upon deletion, your QR code is permanently deactivated, and all associated personal records are wiped from our active databases.
        </p>
      </section>

      <section style={{ marginBottom: '30px', background: '#f7fafc', padding: '20px', borderRadius: '8px' }}>
        <h2 style={{ fontSize: '1.2rem', color: '#2d3748', margin: '0 0 10px 0' }}>6. Contact & Support</h2>
        <p style={{ margin: 0 }}>
          For inquiries regarding these Terms of Service, contact: <a href="mailto:support@goldenhr.in" style={{ color: '#b7791f' }}>support@goldenhr.in</a>
        </p>
      </section>
    </div>
  );
}
