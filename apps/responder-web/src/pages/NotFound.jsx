export default function NotFound() {
  return (
    <div className="error-wrap">
      <div className="error-icon">❓</div>
      <h2 className="error-title">QR Not Found</h2>
      <p className="error-desc">
        This QR code is not registered in the Golden Hour system.
        The patient may have regenerated their QR or this code may be invalid.
      </p>
      <a href="tel:108" className="btn btn-call" style={{ marginTop: 24 }}>
        📞 Call 108 — Emergency Services
      </a>
    </div>
  );
}
