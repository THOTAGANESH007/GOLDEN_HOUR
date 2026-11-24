import { useState, useEffect } from 'react';

interface HealthStatus {
  status: string;
  environment: string;
  version: string;
}

export default function App() {
  const [health, setHealth] = useState<HealthStatus | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchHealth = async () => {
      try {
        const res = await fetch('http://localhost:8000/health');
        if (res.ok) {
          const data = await res.json();
          setHealth(data);
        } else {
          setHealth({ status: 'degraded', environment: 'local', version: '1.0.4' });
        }
      } catch {
        setHealth({ status: 'unreachable', environment: 'offline', version: '1.0.4' });
      } finally {
        setLoading(false);
      }
    };
    fetchHealth();
  }, []);

  return (
    <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
      {/* Top Navbar */}
      <header
        style={{
          borderBottom: '1px solid rgba(255, 255, 255, 0.1)',
          padding: '16px 32px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          background: 'rgba(15, 23, 42, 0.85)',
          backdropFilter: 'blur(12px)',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
          <div
            style={{
              width: '40px',
              height: '40px',
              borderRadius: '10px',
              background: 'linear-gradient(135deg, #DC2626 0%, #991B1B 100%)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '22px',
              fontWeight: 800,
            }}
          >
            GH
          </div>
          <div>
            <div style={{ fontSize: '18px', fontWeight: 700, letterSpacing: '-0.3px' }}>
              Golden Hour — Admin Portal
            </div>
            <div style={{ fontSize: '12px', color: '#94A3B8' }}>
              Statutory Non-Clinical Emergency Safety & ICE Notification Platform
            </div>
          </div>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          <span
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: '6px',
              padding: '6px 12px',
              borderRadius: '9999px',
              fontSize: '12px',
              fontWeight: 600,
              backgroundColor:
                health?.status === 'ok' || health?.status === 'healthy'
                  ? 'rgba(34, 197, 94, 0.15)'
                  : 'rgba(234, 179, 8, 0.15)',
              color:
                health?.status === 'ok' || health?.status === 'healthy'
                  ? '#4ADE80'
                  : '#FDE047',
              border: '1px solid rgba(255, 255, 255, 0.1)',
            }}
          >
            <span
              style={{
                width: '8px',
                height: '8px',
                borderRadius: '50%',
                backgroundColor:
                  health?.status === 'ok' || health?.status === 'healthy'
                    ? '#22C55E'
                    : '#EAB308',
              }}
            />
            Backend: {loading ? 'Checking...' : health?.status || 'Active'}
          </span>
          <span
            style={{
              fontSize: '11px',
              background: 'rgba(255, 255, 255, 0.08)',
              padding: '6px 10px',
              borderRadius: '6px',
              color: '#CBD5E1',
            }}
          >
            India DPDPA 2023 Compliant
          </span>
        </div>
      </header>

      {/* Main Content Area */}
      <main style={{ flex: 1, padding: '32px', maxWidth: '1280px', margin: '0 auto', width: '100%' }}>
        {/* Metric Cards */}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))',
            gap: '20px',
            marginBottom: '32px',
          }}
        >
          <div
            style={{
              background: '#1E293B',
              borderRadius: '16px',
              padding: '24px',
              border: '1px solid rgba(255, 255, 255, 0.08)',
            }}
          >
            <div style={{ color: '#94A3B8', fontSize: '14px', marginBottom: '8px' }}>
              Universal Emergency QRs
            </div>
            <div style={{ fontSize: '32px', fontWeight: 800, color: '#F8FAFC' }}>Active</div>
            <div style={{ fontSize: '12px', color: '#38BDF8', marginTop: '6px' }}>
              256-bit AES Encrypted Non-Clinical QR Data
            </div>
          </div>

          <div
            style={{
              background: '#1E293B',
              borderRadius: '16px',
              padding: '24px',
              border: '1px solid rgba(255, 255, 255, 0.08)',
            }}
          >
            <div style={{ color: '#94A3B8', fontSize: '14px', marginBottom: '8px' }}>
              Statutory Helplines
            </div>
            <div style={{ fontSize: '28px', fontWeight: 800, color: '#F8FAFC' }}>
              112 / 108 / 100
            </div>
            <div style={{ fontSize: '12px', color: '#4ADE80', marginTop: '6px' }}>
              National Emergency Integration Enabled
            </div>
          </div>

          <div
            style={{
              background: '#1E293B',
              borderRadius: '16px',
              padding: '24px',
              border: '1px solid rgba(255, 255, 255, 0.08)',
            }}
          >
            <div style={{ color: '#94A3B8', fontSize: '14px', marginBottom: '8px' }}>
              Local Docker Services
            </div>
            <div style={{ fontSize: '20px', fontWeight: 700, color: '#F8FAFC' }}>
              FastAPI + Postgres + Redis
            </div>
            <div style={{ fontSize: '12px', color: '#A855F7', marginTop: '6px' }}>
              Docker Compose Orchestrated
            </div>
          </div>
        </div>

        {/* Informational Panel */}
        <section
          style={{
            background: '#1E293B',
            borderRadius: '16px',
            padding: '28px',
            border: '1px solid rgba(255, 255, 255, 0.08)',
          }}
        >
          <h2 style={{ fontSize: '20px', fontWeight: 700, marginTop: 0, marginBottom: '12px' }}>
            Emergency Response & ICE Audit Logs
          </h2>
          <p style={{ color: '#94A3B8', fontSize: '14px', lineHeight: 1.6, marginBottom: '20px' }}>
            This local administration portal monitors non-clinical emergency safety QR interactions,
            statutory helpline alerts, and bystander guidance logs under the India Digital Personal Data
            Protection Act (DPDPA 2023).
          </p>

          <div
            style={{
              border: '1px dashed rgba(255, 255, 255, 0.15)',
              borderRadius: '12px',
              padding: '24px',
              textAlign: 'center',
              color: '#64748B',
            }}
          >
            <p style={{ margin: 0, fontSize: '14px' }}>
              Ready for local dispatch telemetry. Start backend API on <code>http://localhost:8000</code> to view
              live scan events and audit trails.
            </p>
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer
        style={{
          borderTop: '1px solid rgba(255, 255, 255, 0.08)',
          padding: '20px 32px',
          textAlign: 'center',
          fontSize: '12px',
          color: '#64748B',
        }}
      >
        © 2026 Golden Hour Safety Platform. Universal Emergency QR & ICE System.
      </footer>
    </div>
  );
}
