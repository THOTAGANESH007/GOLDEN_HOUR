export default function Deactivated() {
  return (
    <div className="error-wrap">
      <div className="error-icon">🔒</div>
      <h2 className="error-title">QR Code Deactivated</h2>
      <p className="error-desc">
        The patient has temporarily deactivated their QR code.
        Please contact emergency services or the patient's family directly.
      </p>
      <a href="tel:108" className="btn btn-call" style={{ marginTop: 24 }}>
        📞 Call 108 — Emergency Services
      </a>
    </div>
  );
}
