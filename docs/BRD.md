# Business Requirements Document (BRD)
## Golden Hour — Universal Medical Emergency QR System

**Version**: 1.0  
**Date**: October 11, 2026  
**Status**: Draft  
**Owner**: Product Team  

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Problem Statement](#2-problem-statement)
3. [Goals & Objectives](#3-goals--objectives)
4. [Stakeholders](#4-stakeholders)
5. [User Personas](#5-user-personas)
6. [Functional Requirements](#6-functional-requirements)
7. [Non-Functional Requirements](#7-non-functional-requirements)
8. [System Architecture Overview](#8-system-architecture-overview)
9. [Data Model](#9-data-model)
10. [Feature Breakdown by Module](#10-feature-breakdown-by-module)
11. [User Flows](#11-user-flows)
12. [Security & Privacy](#12-security--privacy)
13. [Integrations](#13-integrations)
14. [Tech Stack Recommendation](#14-tech-stack-recommendation)
15. [MVP vs Full Product Scope](#15-mvp-vs-full-product-scope)
16. [Risk Register](#16-risk-register)
17. [Success Metrics (KPIs)](#17-success-metrics-kpis)
18. [Release Roadmap](#18-release-roadmap)

---

## 1. Executive Summary

**Golden Hour** is a mobile-first, cross-platform digital health platform that generates a **Universal Medical QR Code** linked to a secure patient health profile. In the event of an emergency, any first responder — paramedic, doctor, or bystander — can scan the code to instantly retrieve critical medical information and trigger real-time family notifications, all **without requiring app installation or user authentication on the responder's end**.

The system bridges the information vacuum that exists when a patient is unconscious or unable to communicate, directly targeting the 60-minute window known as the "Golden Hour" in emergency medicine — the period during which rapid intervention most significantly improves survival outcomes.

---

## 2. Problem Statement

### 2.1 The Golden Hour Gap
In medical emergencies (road accidents, cardiac events, strokes, seizures), the first 60 minutes are clinically critical. Yet first responders routinely encounter an **Information Vacuum**:

| Unknown Information | Clinical Impact |
|---|---|
| Blood Group | Cannot perform emergency transfusions |
| Drug Allergies | Risk of fatal allergic reactions from administered medication |
| Chronic Conditions | Incorrect treatment protocols (e.g., insulin overdose in diabetic patients) |
| Current Medications | Dangerous drug interactions |
| Emergency Contacts | Family unreachable; surgical consent delayed by hours |
| Primary Physician | No continuity of care |

### 2.2 Failure of Existing Solutions

| Solution | Why It Fails |
|---|---|
| Medical Bracelets | 2-3 words only; cannot be updated; easily missed |
| Wallet ID Cards | Lost or damaged in accidents; overlooked in chaos |
| Phone Lock Screen Emergency Info | <5% of users configure it; phone may be damaged or locked |
| Hospital EHR Systems | Siloed across hospitals; inaccessible without patient identity |
| Aarogya Setu / Similar Apps | Requires app install by responder; not emergency-optimized |

### 2.3 Opportunity
A single, scannable QR code — printed on a sticker, keychain, or embedded in a physical card — that links to a **publicly accessible (but privacy-protected) medical summary** can eliminate this gap at near-zero friction.

---

## 3. Goals & Objectives

### 3.1 Primary Goal
Enable any first responder to retrieve critical patient medical data within **under 10 seconds** of scanning a QR code, with zero app installation required.

### 3.2 Business Objectives

| # | Objective | Metric |
|---|---|---|
| B1 | Become the standard emergency medical ID in India | 1M registered users in 24 months |
| B2 | Reduce drug-allergy incidents in ICUs | Measurable reduction tracked via hospital partnerships |
| B3 | Monetize via premium subscriptions and B2B hospital APIs | ₹5 Cr ARR by Year 2 |
| B4 | Establish trust through data security certifications | ISO 27001, HIPAA-aligned compliance |

### 3.3 Product Objectives
- Zero-friction QR scan → patient data in < 10 seconds
- Patient data always up-to-date via mobile app
- Real-time SMS/WhatsApp notification to emergency contacts upon scan
- Physical QR artifacts (printable card, sticker, NFC tag option)
- Works offline (QR encodes minimal critical data as fallback)

---

## 4. Stakeholders

| Role | Name/Team | Interest |
|---|---|---|
| Product Owner | Founder / PM | Feature scope & roadmap |
| Engineering Lead | CTO | Architecture & delivery |
| Medical Advisor | Consulting Physician / Cardiologist | Clinical accuracy of data fields |
| Legal / Compliance | Legal Counsel | PDPB (India), HIPAA alignment |
| UX Designer | Design Lead | Patient & responder experience |
| B2B Partners | Hospitals, Ambulance Services | API integration, adoption |
| End Users | General Public | Security, ease of use |
| First Responders | Paramedics, ER Doctors | Speed of access, reliability |

---

## 5. User Personas

### Persona 1: Ravi — The Patient (Primary User)
- **Age**: 45, Software Engineer, Hyderabad
- **Condition**: Type 2 Diabetes, Hypertension
- **Pain Point**: "I'm always worried about what happens if I collapse at work and no one knows I'm diabetic."
- **Goal**: Set up once, carry QR sticker on phone case, and never worry again.
- **Tech Literacy**: Moderate (uses UPI, WhatsApp daily)

### Persona 2: Dr. Anjali — The Emergency Physician (Responder)
- **Age**: 32, ER Doctor, Apollo Hospital
- **Pain Point**: "Unconscious patients arrive with no family. We guess blood type and hope for the best."
- **Goal**: Scan QR, see critical vitals and allergies instantly, start treatment confidently.
- **Tech Literacy**: High, but zero tolerance for friction in an emergency

### Persona 3: Suresh — The Paramedic (Responder)
- **Age**: 28, 108 Ambulance Service
- **Pain Point**: "By the time family calls back, we've already made treatment decisions."
- **Goal**: Scan code at accident site, see blood group and contacts, notify family automatically.
- **Tech Literacy**: Moderate

### Persona 4: Priya — The Family Member (Notified Party)
- **Age**: 40, Homemaker
- **Pain Point**: "I found out my husband was in an accident 3 hours after it happened."
- **Goal**: Get an instant notification when her husband's QR is scanned, with hospital location.
- **Tech Literacy**: Low-Moderate (WhatsApp user)

---

## 6. Functional Requirements

### Module 1: Patient Registration & Profile
| ID | Requirement | Priority |
|---|---|---|
| FR-01 | User can register via mobile number (OTP) or email | Must Have |
| FR-02 | User can enter/edit medical profile fields (see Data Model) | Must Have |
| FR-03 | System generates a unique, permanent QR code per user | Must Have |
| FR-04 | User can add up to 5 emergency contacts with name, relation, phone | Must Have |
| FR-05 | User can upload/link scanned documents (prescriptions, lab reports) | Should Have |
| FR-06 | User can set profile to "Active" or "Inactive" (pausing QR access) | Should Have |
| FR-07 | Profile supports multiple languages (English, Hindi, Telugu, Tamil) | Should Have |
| FR-08 | User can add a profile photo (aids ID in emergencies) | Nice to Have |

### Module 2: QR Code Generation & Distribution
| ID | Requirement | Priority |
|---|---|---|
| FR-09 | QR encodes a unique short URL (e.g., goldenhr.in/p/X7K2) | Must Have |
| FR-10 | QR is downloadable as PNG/SVG for printing | Must Have |
| FR-11 | App generates a print-ready medical ID card (credit card format, PDF) | Must Have |
| FR-12 | QR data includes minimal offline fallback (blood group, critical allergy) | Should Have |
| FR-13 | NFC tag programming support (premium feature) | Nice to Have |
| FR-14 | User can order a physical QR sticker or card via in-app (fulfillment partner) | Nice to Have |

### Module 3: Emergency Responder View (Public Web Page)
| ID | Requirement | Priority |
|---|---|---|
| FR-15 | QR scan opens a mobile-optimized web page — NO app install required | Must Have |
| FR-16 | Page displays: Name, Age, Blood Group, Allergies, Conditions, Medications | Must Have |
| FR-17 | Page shows emergency contacts with one-tap call and WhatsApp buttons | Must Have |
| FR-18 | Page records a scan event (timestamp, GPS if permitted, device type) | Must Have |
| FR-19 | Upon scan, system auto-sends SMS + WhatsApp to all emergency contacts | Must Have |
| FR-20 | Notification message includes patient name, scan time, and GPS link | Must Have |
| FR-21 | Responder can optionally enter their name/hospital to include in alert | Should Have |
| FR-22 | Page supports a "Share Location" button to attach responder GPS to alert | Should Have |
| FR-23 | Page is accessible even with slow 2G connections (< 50KB load) | Must Have |
| FR-24 | Page available in English + regional languages | Should Have |

### Module 4: Notifications & Alerting
| ID | Requirement | Priority |
|---|---|---|
| FR-25 | SMS notification sent to emergency contacts within 5 seconds of scan | Must Have |
| FR-26 | WhatsApp notification via WhatsApp Business API | Must Have |
| FR-27 | Push notification to patient's app (scan event log) | Should Have |
| FR-28 | Patient can review scan history (who scanned, when, where) | Should Have |
| FR-29 | False scan alerts can be dismissed by patient within 60 seconds | Should Have |

### Module 5: Admin & Analytics Dashboard
| ID | Requirement | Priority |
|---|---|---|
| FR-30 | Super admin can view user registrations, scan events | Must Have |
| FR-31 | Hospital admin portal for bulk QR issuance (B2B) | Should Have |
| FR-32 | Analytics: scans per day, regions, peak hours | Should Have |
| FR-33 | Audit logs for all data access events | Must Have |

---

## 7. Non-Functional Requirements

| Category | Requirement |
|---|---|
| **Performance** | Responder page must load in < 2 seconds on 3G; < 1 second on 4G |
| **Availability** | 99.9% uptime SLA — system must work 24/7/365 |
| **Scalability** | Must handle 10,000 concurrent scans without degradation |
| **Security** | End-to-end encryption for PII; data encrypted at rest (AES-256) |
| **Privacy** | Patient controls what is visible on the public page; PDPB compliant |
| **Accessibility** | WCAG 2.1 AA compliance on the responder web page |
| **Reliability** | Notification delivery > 99% within 10 seconds |
| **Data Residency** | Patient data stored in India (AWS Mumbai / GCP Mumbai region) |
| **Disaster Recovery** | RTO < 30 min, RPO < 5 min |
| **Offline Fallback** | QR code encodes critical 4-field data in the QR itself as plain text fallback |

---

## 8. System Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     PATIENT MOBILE APP                       │
│              (React Native / Flutter - iOS & Android)        │
└───────────────────────────┬─────────────────────────────────┘
                            │ HTTPS API
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      API GATEWAY                             │
│              (AWS API Gateway / Kong)                        │
└──────┬──────────────────────────┬───────────────────────────┘
       │                          │
       ▼                          ▼
┌──────────────┐        ┌──────────────────────┐
│  Auth Service│        │   Core Medical API    │
│  (OTP/JWT)   │        │   (Node.js / FastAPI) │
└──────────────┘        └──────────┬───────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              ▼                    ▼                    ▼
    ┌──────────────┐    ┌───────────────────┐  ┌───────────────┐
    │  PostgreSQL  │    │  Notification Svc │  │  QR Generator │
    │  (Patient DB)│    │  (SMS/WhatsApp)   │  │  (short URL)  │
    └──────────────┘    └───────────────────┘  └───────────────┘
              │
              ▼
    ┌──────────────────────────────────────────┐
    │         RESPONDER WEB PAGE               │
    │   (Static Next.js, CDN-hosted)           │
    │   goldenhr.in/p/{uid}                    │
    │   - No login, instant load               │
    │   - Triggers notification on load        │
    └──────────────────────────────────────────┘
```

---

## 9. Data Model

### 9.1 Patient Profile Schema

```
Patient {
  id:               UUID (Primary Key)
  qr_code_id:       String (short, unique — e.g., "X7K2M9")
  
  // Identity
  full_name:        String
  date_of_birth:    Date
  gender:           Enum [Male, Female, Other]
  profile_photo:    URL (optional)
  
  // Critical Medical (shown on public responder page)
  blood_group:      Enum [A+, A-, B+, B-, O+, O-, AB+, AB-]
  allergies:        String[] (drug names, substances)
  chronic_conditions: String[] (Diabetes, Hypertension, Epilepsy, etc.)
  current_medications: Medication[]
  organ_donor:      Boolean
  
  // Extended Medical (shown on responder page, toggleable)
  past_surgeries:   String[]
  implants:         String[] (pacemaker, stent, etc.)
  primary_physician: Contact
  
  // Emergency Contacts
  emergency_contacts: EmergencyContact[] (max 5)
  
  // Documents
  documents:        Document[] (prescription scans, reports)
  
  // Privacy Controls
  show_name:        Boolean (default: true)
  show_photo:       Boolean (default: false)
  show_dob:         Boolean (default: true)
  is_active:        Boolean (default: true)
  
  // Meta
  created_at:       Timestamp
  updated_at:       Timestamp
}

EmergencyContact {
  name:             String
  relation:         String
  phone:            String (E.164 format)
  whatsapp_enabled: Boolean
  notify_on_scan:   Boolean
}

Medication {
  name:             String
  dosage:           String
  frequency:        String
}

ScanEvent {
  id:               UUID
  patient_id:       UUID (FK)
  scanned_at:       Timestamp
  location_lat:     Float (optional)
  location_lng:     Float (optional)
  responder_name:   String (optional, self-reported)
  device_type:      String
  notifications_sent: Boolean
}
```

---

## 10. Feature Breakdown by Module

### 10.1 Patient Mobile App Screens

| Screen | Description |
|---|---|
| **Onboarding** | App intro + signup via OTP |
| **Profile Setup Wizard** | Step-by-step: Blood group → Allergies → Conditions → Contacts |
| **My QR Code** | Full-screen QR + download + print card + share |
| **Edit Profile** | Update any field; changes reflect on responder page instantly |
| **Scan History** | Log of when/where/by whom QR was scanned |
| **Documents** | Upload and manage medical documents |
| **Notifications** | In-app alerts for scans |
| **Settings** | Privacy controls, language, account management |
| **Premium** | Upgrade screen (NFC tags, family plan, hospital integration) |

### 10.2 Responder Emergency Web Page Sections

| Section | Content |
|---|---|
| **Header Banner** | ⚠️ "MEDICAL EMERGENCY" in red, patient name, age |
| **Critical Info Card** | Blood Group (large), Allergies (red badges), Conditions |
| **Medications** | Current medications list with dosages |
| **Emergency Contacts** | Cards with ☎️ Call + 💬 WhatsApp buttons |
| **Doctor Contact** | Primary physician details |
| **Implants & Notes** | Pacemaker, stent warnings |
| **Location Share** | Button to share responder GPS with family |
| **Footer** | "Data provided by patient. Verify clinically." Disclaimer |

---

## 11. User Flows

### 11.1 Patient Registration Flow

```
Download App → OTP Login → Profile Wizard (Blood Group, Allergies,
Conditions, Medications, Contacts) → QR Generated → Download/Print QR
→ Attach to Phone Case / Keychain / Wallet
```

### 11.2 Emergency Scan Flow (Zero Friction)

```
Accident/Emergency
      │
      ▼
First Responder spots QR on patient's phone/card
      │
      ▼
Scans QR with any phone camera (no app needed)
      │
      ▼
Browser opens: goldenhr.in/p/X7K2M9 (< 2 seconds)
      │
      ├──→ Patient profile displayed immediately
      │
      └──→ [Background] SMS + WhatsApp sent to all emergency contacts:
               "EMERGENCY: [Patient Name]'s medical QR was scanned at 
                [Time]. Location: [GPS Link]. Please call 108 immediately."
```

### 11.3 Patient Scan Alert Flow (Post-Incident)

```
Patient (if conscious later) receives push notification:
"Your medical QR was scanned at [Hospital Area], [Time].
Responder: Dr. Anjali (Apollo ER). [View Details] [False Alarm]"
```

---

## 12. Security & Privacy

### 12.1 Data Access Model

| Data Layer | Who Can Access |
|---|---|
| Full Profile (all fields) | Patient only (via authenticated app) |
| Emergency View (critical fields) | Anyone with QR code URL |
| Scan Event Logs | Patient + Super Admin |
| Raw PII (phone, DOB) | Patient + encrypted storage only |

### 12.2 Security Measures

| Control | Implementation |
|---|---|
| **Authentication** | OTP-based (SMS), JWT tokens, refresh token rotation |
| **QR URL Obfuscation** | Random 6-char alphanumeric ID, not sequential |
| **Rate Limiting** | Max 20 scans/hour per QR to prevent enumeration attacks |
| **Data Encryption** | AES-256 at rest, TLS 1.3 in transit |
| **GDPR/PDPB Compliance** | Right to delete, data portability, consent logging |
| **Audit Logging** | Every data access event logged immutably |
| **Abuse Reporting** | Patient can report a scan as suspicious |
| **No PII in QR** | QR contains only the opaque short URL — no medical data embedded |

### 12.3 Privacy Controls (Patient-Controlled)
- Toggle: Show/hide name on responder page
- Toggle: Show/hide date of birth
- Toggle: Show/hide profile photo
- Toggle: Activate/deactivate QR entirely
- "Ghost Mode": Deactivate QR temporarily (e.g., during travel)

---

## 13. Integrations

| Integration | Purpose | Priority |
|---|---|---|
| **Twilio / MSG91** | SMS notifications to emergency contacts | Must Have |
| **WhatsApp Business API** | WhatsApp alerts with formatted medical card | Must Have |
| **Google Maps API** | Location links in notifications | Must Have |
| **AWS S3** | Medical document storage | Must Have |
| **Firebase / OneSignal** | Push notifications to patient app | Must Have |
| **Razorpay / Stripe** | Premium subscription billing | Should Have |
| **HL7 / FHIR API** | Hospital EHR integration (B2B) | Nice to Have |
| **DigiLocker API** | Link Aadhaar health records | Nice to Have |
| **NFC Write SDK** | Program NFC tags with QR URL | Nice to Have |
| **Google/Apple Health** | Import basic health data | Nice to Have |

---

## 14. Tech Stack Recommendation

### 14.1 Frontend (Patient App)
| Layer | Technology | Rationale |
|---|---|---|
| Mobile App | **React Native** (Expo) | Single codebase for iOS + Android; large talent pool |
| QR Generation | `react-native-qrcode-svg` | Lightweight, offline capable |
| State Management | Zustand + React Query | Simple, performant |

### 14.2 Backend
| Layer | Technology | Rationale |
|---|---|---|
| API Server | **Node.js (NestJS)** or **FastAPI (Python)** | Typed, scalable, great ecosystem |
| Database | **PostgreSQL** (Primary) + **Redis** (Cache/Sessions) | Relational for medical data; Redis for speed |
| File Storage | **AWS S3** | Industry standard for medical documents |
| Notification Queue | **BullMQ** on Redis | Reliable, retryable job queue for alerts |
| Short URL Service | Custom microservice or **Rebrandly API** | Branded short links (goldenhr.in/p/X7K2) |

### 14.3 Responder Web Page
| Layer | Technology | Rationale |
|---|---|---|
| Framework | **Next.js** (SSR) | Fast TTFB; SEO-ready; CDN-deployable |
| Hosting | **Vercel** or **AWS CloudFront** | Global CDN, < 50ms latency |
| CSS | Vanilla CSS / Tailwind | Minimal bundle, fast load |

### 14.4 Infrastructure
| Component | Technology |
|---|---|
| Cloud | AWS (Mumbai region) |
| Container Orchestration | ECS Fargate or Kubernetes (EKS) |
| CI/CD | GitHub Actions |
| Monitoring | Datadog / Grafana + Prometheus |
| Secret Management | AWS Secrets Manager |
| CDN | AWS CloudFront |

---

## 15. MVP vs Full Product Scope

### Phase 1 — MVP (Month 1–3)
> **Goal**: Prove core value. Ship and validate with 10,000 users.

- ✅ Patient registration (OTP + basic profile)
- ✅ QR Code generation + download
- ✅ Responder web page (blood group, allergies, conditions, contacts)
- ✅ SMS notification on scan (Twilio/MSG91)
- ✅ Emergency contact call buttons
- ✅ Printable medical ID card (PDF)
- ✅ Basic scan history

### Phase 2 — Growth (Month 4–6)
> **Goal**: Retention, virality, and monetization foundation.

- WhatsApp notification via WA Business API
- Document upload (prescriptions, reports)
- Privacy controls (toggle fields)
- Push notifications + false-alarm dismissal
- Multi-language support (Hindi, Telugu, Tamil)
- Premium subscription tier (NFC, family plan)
- Physical card/sticker ordering integration

### Phase 3 — Scale (Month 7–12)
> **Goal**: B2B adoption and ecosystem expansion.

- Hospital admin portal (bulk QR issuance)
- HL7/FHIR integration for EHR pull
- DigiLocker / Aadhaar health record link
- NFC tag programming
- Responder app (hospital-grade view with full history)
- Analytics dashboard for hospital partners
- API for third-party integrations (insurance, ambulance fleets)

---

## 16. Risk Register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| QR code not visible (damaged phone/card) | High | High | Offline QR with embedded basic data; physical backup card |
| Privacy concern: "anyone can access my medical data" | High | High | Clear consent flows; privacy toggles; no PII in QR itself |
| Notification delivery failure (no SMS coverage) | Medium | High | Multi-channel (SMS + WhatsApp + email fallback); retry logic |
| Low user adoption (setup friction) | High | High | 5-minute onboarding wizard; templated defaults; QR on Day 1 |
| Medical data accuracy (outdated profile) | Medium | Critical | Periodic "Is your info up to date?" nudges; easy edit flow |
| Legal liability for clinical decisions | Low | Critical | Prominent disclaimer: "For reference only. Verify clinically." |
| Data breach | Low | Critical | SOC 2 / ISO 27001; penetration testing quarterly |
| Notification spam (accidental scans) | Medium | Medium | Scan confirmation page; false alarm button; rate limiting |
| PDPB non-compliance | Low | High | Legal counsel review; DPA appointment; consent logging |

---

## 17. Success Metrics (KPIs)

### Adoption Metrics
| KPI | MVP Target (Month 3) | Year 1 Target |
|---|---|---|
| Registered Users | 10,000 | 500,000 |
| QR Downloads | 8,000 | 400,000 |
| DAU/MAU Ratio | 5% | 15% |
| Profile Completion Rate | > 70% | > 85% |

### Engagement & Trust Metrics
| KPI | Target |
|---|---|
| Avg. onboarding time | < 5 minutes |
| Responder page load time | < 2 seconds (3G) |
| Notification delivery rate | > 99% |
| Scan → Notification latency | < 5 seconds |
| False alarm rate | < 2% of scans |

### Business Metrics
| KPI | Year 1 Target |
|---|---|
| Premium subscribers | 50,000 |
| MRR | ₹25 Lakhs |
| Hospital B2B contracts | 10 |
| NPS Score | > 70 |

---

## 18. Release Roadmap

```
Q1 (Month 1–3): MVP
├── Week 1-2:  Architecture setup, DB schema, Auth service
├── Week 3-4:  Patient profile API + mobile app (profile wizard)
├── Week 5-6:  QR generation + responder web page
├── Week 7-8:  SMS notification service + scan event logging
├── Week 9-10: Printable ID card + scan history screen
└── Week 11-12: Beta launch (1,000 users), bug fixes, performance

Q2 (Month 4–6): Growth
├── WhatsApp integration
├── Document upload
├── Privacy controls
├── Multi-language (Hindi + 2 regional)
├── Premium subscription (Razorpay)
└── Physical card ordering

Q3–Q4 (Month 7–12): Scale & B2B
├── Hospital portal
├── HL7/FHIR integration
├── NFC tag support
├── Responder Pro app
├── Analytics dashboard
└── DigiLocker integration
```

---

## Appendix A: Regulatory References

| Regulation | Relevance |
|---|---|
| **Digital Personal Data Protection Act (DPDPA) 2023** | India's primary data privacy law; requires consent, data minimization, breach notification |
| **IT Act 2000 (Section 43A)** | Liability for sensitive personal data handling |
| **HIPAA** (if US expansion) | Health data privacy for US market |
| **HL7 FHIR R4** | Standard for health data interoperability |
| **MoHFW Guidelines** | Ministry of Health guidelines for digital health records |

---

## Appendix B: Competitor Analysis

| Competitor | Type | Weakness vs Golden Hour |
|---|---|---|
| ICE (In Case of Emergency) contacts | Native phone feature | No medical data; not visible when phone is locked |
| Road iD | US-based wearable | Hardware-dependent; subscription; US-only; no notifications |
| Lifequard Health Vault | India | App install required by responder; poor UX |
| Aarogya Setu | India | COVID-specific; not emergency-optimized; requires app |
| MedicAlert | Global | Bracelet-only; expensive; no real-time notification |
| **Golden Hour** | **QR + Web** | **Zero friction; real-time alerts; India-first; no app for responder** |

---

*Document Owner: Product Team | Last Updated: October 11, 2026 | Version: 1.0*  
*Next Review: After MVP Beta (End of Q1)*
