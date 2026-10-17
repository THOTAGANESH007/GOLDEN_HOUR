import { useState, useEffect } from 'react';
import { updateScanEvent } from '../services/api';

/**
 * ClinicalActionsBar.jsx
 * Hands-free Voice Readout, Copy Medical Summary, Print Chart,
 * and False Alarm / Test Scan reporting.
 */
export default function ClinicalActionsBar({ profile }) {
  const [isSpeaking, setIsSpeaking] = useState(false);
  const [copied, setCopied] = useState(false);
  const [falseAlarmReported, setFalseAlarmReported] = useState(false);
  const [reportingFalseAlarm, setReportingFalseAlarm] = useState(false);

  useEffect(() => {
    return () => {
      if ('speechSynthesis' in window) {
        window.speechSynthesis.cancel();
      }
    };
  }, []);

  // ── 1. Voice Speech Synthesis ──────────────────────────────────────────────
  const toggleSpeech = () => {
    if (!('speechSynthesis' in window)) {
      alert('Speech synthesis is not supported on this browser.');
      return;
    }

    if (isSpeaking) {
      window.speechSynthesis.cancel();
      setIsSpeaking(false);
      return;
    }

    const parts = ['Attention emergency responder.'];
    if (profile.full_name) parts.push(`Patient name: ${profile.full_name}.`);
    if (profile.blood_group) parts.push(`Blood group is: ${profile.blood_group}.`);
    if (profile.is_organ_donor) parts.push('Patient is a registered organ donor.');

    if (profile.allergies && profile.allergies.length > 0) {
      parts.push(`Critical allergies: ${profile.allergies.join(', ')}.`);
    } else {
      parts.push('No known allergies recorded.');
    }

    if (profile.chronic_conditions && profile.chronic_conditions.length > 0) {
      parts.push(`Chronic conditions: ${profile.chronic_conditions.join(', ')}.`);
    }

    if (profile.medications && profile.medications.length > 0) {
      const medNames = profile.medications.map((m) => `${m.name} ${m.dosage || ''}`).join(', ');
      parts.push(`Current medications: ${medNames}.`);
    }

    if (profile.contacts && profile.contacts.length > 0) {
      const first = profile.contacts[0];
      parts.push(`Primary emergency contact is ${first.name}, ${first.relation}.`);
    }

    const utterance = new SpeechSynthesisUtterance(parts.join(' '));
    utterance.rate = 0.95;
    utterance.pitch = 1.0;
    utterance.onend = () => setIsSpeaking(false);
    utterance.onerror = () => setIsSpeaking(false);

    window.speechSynthesis.speak(utterance);
    setIsSpeaking(true);
  };

  // ── 2. Copy Clinical Summary to Clipboard ──────────────────────────────────
  const handleCopySummary = () => {
    const lines = [
      '========================================',
      '   GOLDEN HOUR — EMERGENCY MEDICAL ID   ',
      '========================================',
      `Patient Name:     ${profile.full_name || 'Not specified'}`,
      `Blood Group:      ${profile.blood_group || 'Unknown'}`,
      `Organ Donor:      ${profile.is_organ_donor ? 'YES (Registered)' : 'No'}`,
      `Allergies:        ${profile.allergies?.length ? profile.allergies.join(', ') : 'None recorded'}`,
      `Conditions:       ${profile.chronic_conditions?.length ? profile.chronic_conditions.join(', ') : 'None recorded'}`,
      '',
      'CURRENT MEDICATIONS:',
      ...(profile.medications?.length
        ? profile.medications.map((m) => ` - ${m.name} (${m.dosage || 'Standard'} ${m.frequency ? '— ' + m.frequency : ''})`)
        : [' - None recorded']),
      '',
      'EMERGENCY CONTACTS:',
      ...(profile.contacts?.length
        ? profile.contacts.map((c) => ` - ${c.name} (${c.relation}): ${c.phone}`)
        : [' - None recorded']),
      '',
      `Primary Physician: ${profile.doctor_name || 'N/A'} ${profile.doctor_phone ? '(' + profile.doctor_phone + ')' : ''}`,
      `Scan UID:         ${profile.qr_uid}`,
      `Generated At:     ${new Date().toLocaleString('en-IN')}`,
      '========================================',
    ];

    navigator.clipboard.writeText(lines.join('\n'));
    setCopied(true);
    setTimeout(() => setCopied(false), 2500);
  };

  // ── 3. Print Clinical Chart ────────────────────────────────────────────────
  const handlePrint = () => {
    window.print();
  };

  // ── 4. False Alarm / Test Scan Report ──────────────────────────────────────
  const handleFalseAlarm = async () => {
    if (!profile.scan_event_id) return;
    const confirm = window.confirm(
      'Mark this scan as a Test or False Alarm? This informs the patient and prevents unnecessary emergency dispatch.'
    );
    if (!confirm) return;

    setReportingFalseAlarm(true);
    try {
      await updateScanEvent(profile.scan_event_id, { isFalseAlarm: true });
      setFalseAlarmReported(true);
    } catch (e) {
      alert('Unable to mark false alarm. Please try again.');
    } finally {
      setReportingFalseAlarm(false);
    }
  };

  return (
    <div className="card clinical-tools-card">
      <div className="card-header">
        <span className="icon">⚡</span>
        Responder Quick Actions
      </div>
      <div className="card-body">
        <div className="clinical-actions-grid">
          <button
            id="read-aloud-btn"
            className={`btn ${isSpeaking ? 'btn-speaking' : 'btn-secondary'}`}
            onClick={toggleSpeech}
            aria-label="Read emergency info aloud"
          >
            {isSpeaking ? '⏹️ Stop Reading' : '🔊 Read Aloud'}
          </button>

          <button
            id="copy-summary-btn"
            className="btn btn-secondary"
            onClick={handleCopySummary}
            aria-label="Copy medical summary"
          >
            {copied ? '✓ Summary Copied!' : '📋 Copy Summary'}
          </button>

          <button
            id="print-chart-btn"
            className="btn btn-secondary"
            onClick={handlePrint}
            aria-label="Print clinical chart"
          >
            🖨️ Print / Save PDF
          </button>
        </div>

        {falseAlarmReported ? (
          <div className="false-alarm-confirmed">
            ✓ Logged as Test / False Alarm
          </div>
        ) : (
          <button
            id="false-alarm-btn"
            className="false-alarm-btn"
            onClick={handleFalseAlarm}
            disabled={reportingFalseAlarm}
          >
            {reportingFalseAlarm ? 'Marking…' : '⚠️ Was this a test scan or accidental tap? Report False Alarm'}
          </button>
        )}
      </div>
    </div>
  );
}
