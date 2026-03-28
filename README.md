<div align="center">

<img src="https://readme-typing-svg.demolab.com?font=Cinzel+Decorative&size=42&pause=1000&color=C9A84C&center=true&vCenter=true&width=700&height=80&lines=%E2%9A%96%EF%B8%8F+LawyerBano" alt="LawyerBano" />

### *The Future of Digital Legal Intelligence in India*

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Groq AI](https://img.shields.io/badge/Groq-Llama_3.3_70B-F55036?style=for-the-badge&logo=meta&logoColor=white)](https://groq.com)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-C9A84C?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-black?style=for-the-badge&logo=android&logoColor=white)](https://flutter.dev)

<br/>

> **"Democratizing Legal Access Across India — One Query at a Time."**

<br/>

[🚀 Features](#-features) · [🧠 AI Engine](#-ai-legal-counsel) · [🛠 Tech Stack](#%EF%B8%8F-tech-stack) · [📦 Setup](#-installation--setup) · [🗺 Roadmap](#%EF%B8%8F-roadmap) · [🤝 Contributing](#-contributing)

---

</div>

## 📌 What is LawyerBano?

**LawyerBano** is a production-grade, dual-sided legal marketplace and AI intelligence platform built for the Indian legal ecosystem. Think of it as the **"Flipkart for Legal Services"** — connecting verified advocates with citizens through real-time networking, AI-powered counsel, and a premium case management suite.

Legal information in India is fragmented, expensive, and largely inaccessible to the average citizen. LawyerBano dismantles this barrier through technology — placing a full-service legal command center in the palm of every Indian's hand.

```
  CLIENT                         LAWYERBANO PLATFORM                      LAWYER
    │                                    │                                    │
    │  ── Search by Location ──►         │         ◄── Find Clients ──        │
    │  ── AI Legal Query ──────►         │         ◄── Manage Trials ──       │
    │  ── Hire Elite Counsel ──►         │         ◄── Analytics Dashboard ── │
    │  ── Track Court Dates ──►          │                                    │
```

---

## 🚀 Features

### 🔍 Bidirectional Discovery Engine
The heart of LawyerBano is its intelligent, role-aware networking system:

| User Role | Experience |
|-----------|------------|
| **Client** | Browse verified lawyers filtered by State → District → Sub-district |
| **Lawyer** | View active clients seeking legal help in their area |
| **Both** | Integrated **Message** and **Call** buttons for instant professional communication |

Powered by **Cloud Firestore** for real-time updates — profiles go live the moment they're created.

---

### 🧠 AI Legal Counsel

The most powerful feature of the platform — an AI engine trained on Indian law:

- 🤖 **Model:** `Llama 3.3 (70B Versatile)` via Groq Cloud API
- ⚡ **Speed:** Sub-second LLM inference via Groq's custom silicon (LPU)
- 📜 **Scope:** IPC, BNS 2024, CrPC, Constitutional Law
- 🌐 **Languages:** English · Hindi · Hinglish (Roman script)

**What it delivers per query:**
```
✔ Crime Classification & Severity Assessment
✔ Statutory Citations (IPC / BNS Section references)
✔ Step-by-step Legal Action Plan
✔ Recommended Lawyer Specializations
✔ Real-time Supreme Court & High Court verdict feed
```

---

### 👑 Hire Luxury Counsel

An exclusive, curated directory of India's most prestigious advocates:

- 🏛 Criminal Law
- 📋 Constitutional Law  
- 🏢 Corporate & Commercial
- ⚖️ Civil Litigation

Each profile includes verified credentials, specialization tags, location, and direct contact options.

---

### 📊 Smart Case & Trial Management

A personal legal operations center:

- 📅 **Court-Date Manager** — upcoming hearing schedules with status tracking
- 📈 **Analytical Console** — total trials, active cases, today's priorities
- 📰 **Legal Updates Feed** — curated Supreme Court & High Court rulings

---

### 🔐 Authentication & Onboarding

| Method | Details |
|--------|---------|
| Email / Password | Secure registration with Firebase Auth |
| Google Sign-In | One-tap OAuth login |
| Guest Mode | Browse legal updates without an account |
| Role Selection | Lawyer or Client — dynamically reshapes the entire app |
| Data Sovereignty | Permanent account deletion wipes all Firebase records |

---

## 🛠️ Tech Stack

```
┌─────────────────────────────────────────────────────────────────┐
│                      LAWYERBANO ARCHITECTURE                    │
├─────────────────┬───────────────────────────────────────────────┤
│ Frontend        │ Flutter 3.19+ (Android & iOS)                 │
│ Backend         │ Firebase (Auth · Firestore · Storage)         │
│ AI Engine       │ Groq Cloud — Llama 3.3 70B Versatile          │
│ State Mgmt      │ Provider Pattern                              │
│ Localization    │ Custom Translation Service (EN/HI/Hinglish)   │
│ UI System       │ Obsidian & Gold — Glassmorphism Design System │
│ Security        │ .env API key management · Firebase Rules      │
└─────────────────┴───────────────────────────────────────────────┘
```

### 📁 Project Structure

```
lib/
├── core/
│   ├── theme/           # Obsidian & Gold design system
│   └── constants/       # App-wide constants
├── services/
│   ├── ai_service.dart  # Groq LLM integration
│   ├── auth_service.dart
│   └── database_service.dart
├── screens/
│   ├── dashboard/       # Analytical console & case management
│   ├── discovery/       # Bidirectional lawyer-client discovery
│   ├── ai_counsel/      # AI query interface
│   └── profile/         # User profile management
└── providers/
    ├── language_provider.dart
    └── theme_provider.dart
```

---

## 📦 Installation & Setup

### Prerequisites
- Flutter SDK `>=3.19.0`
- Dart SDK `>=3.0.0`
- Firebase project configured ([guide](https://firebase.google.com/docs/flutter/setup))
- Groq API key ([get one free](https://console.groq.com))

### Steps

```bash
# 1. Clone the Repository
git clone https://github.com/siddhart3000/LawyerBano-App.git
cd LawyerBano-App

# 2. Create Environment File
echo "GROQ_API_KEY=your_key_here" > .env

# 3. Install Flutter Dependencies
flutter pub get

# 4. Generate App Icons
dart run flutter_launcher_icons

# 5. Run the Application
flutter run

# 6. (Optional) Build Release APK
flutter build apk --release
```

> ⚠️ **Security Note:** Never commit your `.env` file. It is already included in `.gitignore`.

---

## 🗺️ Roadmap

```
2025 Q2   ████████████  ✅  Core Platform & AI Counsel (Live)
2025 Q3   ████████░░░░  🔄  iOS App Store Release
2025 Q4   ██████░░░░░░  📋  Indian Bar Council API Integration
2026 Q1   ████░░░░░░░░  📋  AI Contract Drafting Module
2026 Q2   ██░░░░░░░░░░  📋  Regional Languages (Punjabi · Bengali · Tamil)
2026 Q3   ░░░░░░░░░░░░  🔮  Court Filing Automation
```

---

## 🤝 Contributing

Contributions are what make open source extraordinary. Any contribution you make is **deeply appreciated**.

```bash
# Step 1 — Fork the repository on GitHub

# Step 2 — Clone your fork locally
git clone https://github.com/YOUR_USERNAME/LawyerBano-App.git

# Step 3 — Create a feature branch
git checkout -b feature/your-amazing-feature

# Step 4 — Make your changes and commit
git commit -m "feat: add your amazing feature"

# Step 5 — Push to your fork
git push origin feature/your-amazing-feature

# Step 6 — Open a Pull Request on GitHub
```

### Commit Convention
We use [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` — New feature
- `fix:` — Bug fix
- `docs:` — Documentation only
- `style:` — Formatting changes
- `refactor:` — Code restructure without feature change
- `test:` — Adding tests

---

## 📜 License

Distributed under the **MIT License**.  
See [`LICENSE`](LICENSE) for full details.

```
MIT License — Copyright (c) 2025 Siddharth Singh
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software to use, copy, modify, merge, publish, distribute, and/or
sell copies of the Software.
```

---

## 💬 Support & Community

Have a question or found a bug?

- 🐛 **Bug Reports:** [Open an Issue](https://github.com/siddhart3000/LawyerBano-App/issues)
- 💡 **Feature Requests:** [Start a Discussion](https://github.com/siddhart3000/LawyerBano-App/discussions)
- 📧 **Direct Contact:** Reach out via GitHub profile

---

<div align="center">

---

### Built with ❤️ and a mission to democratize legal access in India.

**Siddharth Singh**  
*Full-Stack Flutter Developer · AI Integration Engineer*

[![GitHub](https://img.shields.io/badge/GitHub-siddhart3000-181717?style=for-the-badge&logo=github)](https://github.com/siddhart3000)
[![Repository](https://img.shields.io/badge/Repo-LawyerBano--App-C9A84C?style=for-the-badge&logo=github)](https://github.com/siddhart3000/LawyerBano-App)

---

*If LawyerBano helped you or impressed you, drop a ⭐ on the repo — it means the world.*

</div>

