# 📱 Google Play Store Listing Metadata — Golden Hour

---

## 1. App Title & Descriptions

### App Name (Max 50 characters)
```text
Golden Hour: Emergency Medical ID
```
*(33 / 50 characters)*

---

### Short Description (Max 80 characters)
```text
Instant emergency medical QR ID. Scan to view vital info & alert family fast.
```
*(77 / 80 characters)*

---

### Full Description (Max 4,000 characters)
```text
In a life-threatening medical emergency or road accident, the first 60 minutes — known in medicine as the "Golden Hour" — determine whether a patient survives. Golden Hour equips you with a universal emergency QR code that enables bystanders, Good Samaritans, and paramedics to access critical medical details in seconds and automatically notify your loved ones.

🚨 HOW IT WORKS
1. Complete Your Medical Profile: Add your blood group, severe drug allergies, chronic conditions (e.g. Asthma, Diabetes), current medications, and primary emergency contacts.
2. Generate Your Unique Emergency QR: Receive a personalized, secure QR code with an opaque identifier.
3. Save & Print: Place your emergency QR sticker on your motorcycle helmet, vehicle windshield, wristband, or carry it in your wallet.
4. Instant Emergency Scan: When someone scans your QR code using any smartphone camera, your emergency medical card opens instantly without needing an app.
5. Multi-Channel Family Alerts: Designated emergency contacts automatically receive real-time SMS, WhatsApp, and push alerts with the emergency location.

✨ KEY FEATURES
• Instant Emergency Profile: Prominently highlights blood group, severe allergies, chronic conditions, and emergency contacts.
• Hands-Free Voice Readout: Paramedics can listen to a spoken clinical summary while administering emergency care.
• Emergency Services Speed Dial: 1-tap direct calling to India’s emergency helplines: 108 (Ambulance), 112 (National Emergency), 100 (Police), 101 (Fire).
• Redundant Multi-Channel Alerting: Dispatches incident alerts via SMS, WhatsApp, and FCM Push notifications with approximate scene GPS.
• Real-Time Scan History: View a full audit log of every scan event with timestamps, locations, and attending responder information.
• 60-Second False Alarm Protection: Accidentally scanned your QR? Mark it as a false alarm within 60 seconds to notify family that you are safe.
• Offline Emergency Card: Save a printable emergency card or export high-resolution QR codes to your phone's photo gallery.
• Emergency Dark Mode & High-Contrast: Designed for high visibility in low-light accident scenes and direct sunlight.

🔒 PRIVACY & DPDPA 2023 COMPLIANCE
Your health data is sensitive and belongs to you. Golden Hour is built with privacy-by-design architecture:
• No Personal Identifiers in QR URLs: QR codes encode only a secure random 8-character token (e.g., /p/X7K2M9QP). No personal phone numbers or health data are exposed in the link.
• Granular Privacy Toggles: Choose which fields are visible to the public. Hide your full name or date of birth while keeping critical blood group and allergy data accessible.
• Instant QR Invalidation: Lost your helmet or sticker? Invalidate and regenerate a new QR code in one tap. Old links immediately become 404.
• Right to Erasure (DPDPA Section 12): In-app account deletion permanently wipes all medical records, contacts, and scan history from active servers.
• No Data Monetization: We never sell, rent, or trade your medical information for advertising.

🛡️ MEDICAL DISCLAIMER
Golden Hour is an emergency information dissemination utility, not a healthcare provider, ambulance dispatcher, or diagnostic medical device. In an acute emergency, always dial 108 or 112 immediately. Good Samaritan responders are protected under the Supreme Court of India guidelines.

Download Golden Hour today and protect yourself and your family when seconds count.
```

---

## 2. Store Listing Assets Checklist

| Asset | Specifications | Status / File Path |
|-------|---------------|-------------------|
| **App Icon** | 512x512 PNG, 32-bit color, no alpha | `apps/mobile/assets/images/app_icon_512.png` |
| **Feature Graphic** | 1024x500 PNG / JPEG, no alpha | `apps/mobile/assets/images/play_store_feature_graphic.png` |
| **Screenshot 1** | Emergency QR Medical ID Card (768x1376 PNG) | `docs/assets/screenshots/1_emergency_qr_card.png` |
| **Screenshot 2** | First Responder Public Emergency View (768x1376 PNG) | `docs/assets/screenshots/2_first_responder_view.png` |
| **Screenshot 3** | Instant SOS & Multi-Channel Alerting (768x1376 PNG) | `docs/assets/screenshots/3_instant_sos_alerts.png` |
| **Screenshot 4** | Offline Life-Saving First Aid & CPR (768x1376 PNG) | `docs/assets/screenshots/4_offline_first_aid_guides.png` |
| **Privacy Policy URL** | Publicly accessible URL | `https://goldenhr.ganeshthota656.workers.dev/privacy` |
| **Terms of Service URL**| Publicly accessible URL | `https://goldenhr.ganeshthota656.workers.dev/terms` |

---

## 3. Data Safety Form Answers (Google Play Console)

When completing the **Data Safety** questionnaire on the Play Console:

### Does your app collect or share any user data?
- **Answer:** Yes

### Data Types Collected:
1. **Health and Fitness → Health info:**
   - Collected: Yes
   - Shared: Yes (Displayed to bystanders/responders scanning the emergency QR)
   - Processed ephemerally: No
   - Required or Optional: Optional (User inputs only what they choose to share)
   - Purpose: App functionality, Emergency medical response

2. **Personal Info → Name & Phone number:**
   - Collected: Yes
   - Shared: Yes (Phone number used for OTP authentication; emergency contact numbers receive alert messages)
   - Purpose: Account management, Emergency notifications

3. **Location → Approximate location:**
   - Collected: Yes (During QR scan, if responder permits browser GPS)
   - Purpose: Incident notification to emergency family contacts

### Security Practices:
- **Data Encrypted in Transit:** Yes (TLS 1.3 across all endpoints)
- **Data Deletion Request Mechanism:** Yes (In-app "Delete Account" button under Settings provides immediate complete erasure)
