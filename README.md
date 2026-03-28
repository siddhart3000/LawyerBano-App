<<<<<<< HEAD
# ⚖️ Lawyer Bano – AI Legal Awareness App

🚧 **Status: Under Active Development**  
📅 Target Completion: **May 2026**

Lawyer Bano is an AI-powered legal awareness mobile application designed to simplify access to Indian legal information. The platform aims to help users search, understand, and explore crime-related laws using structured filtering and intelligent query mechanisms.

---

## 🎯 Vision

Legal information is often complex and inaccessible to common citizens.  
Lawyer Bano aims to:

- Simplify legal search
- Provide structured crime-based classification
- Enable intelligent filtering
- Deliver clear, user-friendly explanations

---

## 🛠️ Current Development Stage

The application is currently under development with:

- Core UI structure setup
- Modular architecture implementation
- Structured crime database integration (in progress)
- REST API-based query handling
- Dynamic search filtering logic

---

## 🧠 Planned Features

- AI-assisted legal query interpretation
- Structured IPC crime categorization
- Smart filtering by category, severity, and section
- Clean, intuitive mobile UI
- Scalable backend integration
- Multi-language support (future scope)

---

## 🏗️ Tech Stack

- Flutter
- Dart
- REST API
- JSON-based structured data
- Modular architecture pattern

---

## 🚀 Roadmap

| Phase | Feature | Status |
|-------|---------|--------|
| Phase 1 | Core UI & Navigation | In Progress |
| Phase 2 | Crime Database Integration | In Progress |
| Phase 3 | AI-based Query Processing | Planned |
| Phase 4 | Testing & Optimization | Planned |
| Phase 5 | Beta Release | May 2026 |

---

## 📌 Why This Project Matters

Lawyer Bano is designed to bridge the gap between citizens and legal awareness through structured, searchable, and simplified legal information.

---

## 👨‍💻 Author

Siddharth Singh  
GitHub: https://github.com/siddhart3000
=======
# LawyerBano - The Professional Legal Companion ⚖️

**LawyerBano** is a comprehensive, state-of-the-art legal ecosystem designed to bridge the gap between legal experts and clients. It integrates advanced AI capabilities, real-time database connectivity, and localized discovery to provide a seamless legal experience.

## 🚀 Key Features

### 1. **AI Legal Counsel (Grok-powered)**
*   **Intelligent Analysis:** Powered by Llama-3.3-70b-versatile via Groq API, providing point-wise legal insights based on Indian Law (including BNS 2024 and IPC).
*   **Multi-Language Support:** Legal advice is available in **English, Hindi, and Hinglish**, making it accessible to a wider audience.
*   **Expert Recommendations:** Automatically generates lawyer suggestions based on the legal query.

### 2. **Professional Discovery System**
*   **Bidirectional Networking:** Automatically detects user roles. Clients see a list of Lawyers; Lawyers see a list of potential Clients.
*   **Location-Based Filtering:** Search for legal counsel or clients nearby using **State, District, and Sub-District** filters.
*   **Real-time Updates:** Powered by Cloud Firestore for instant profile updates and discovery.

### 3. **Unified Case & Trial Management**
*   **Upcoming Trials:** Track court dates and trial status with an intuitive dashboard.
*   **Legal Updates:** A dedicated feed for the latest Supreme Court and High Court verdicts.

### 4. **User Experience & Security**
*   **Secure Authentication:** Support for Email/Password and **Google Sign-In**.
*   **Guest Mode:** Allows users to explore legal information and updates while restricting premium features until login.
*   **Luxury Theme:** A premium "Obsidian Black & Golden Dawn" UI for a professional, high-end feel.
*   **Full Data Privacy:** Users can permanently delete their accounts and all associated data directly from the app.

## 🛠 Tech Stack
*   **Framework:** [Flutter](https://flutter.dev/)
*   **Backend:** [Firebase](https://firebase.google.com/) (Auth, Firestore)
*   **AI Engine:** [Groq Cloud](https://groq.com/) (Llama-3.3-70b-versatile)
*   **State Management:** Provider
*   **Storage:** Shared Preferences, .env for API security

## 📦 Installation & Setup

1. **Clone the project:**
   ```sh
   git clone https://github.com/siddhart3000/LawyerBano-App.git
   cd LawyerBano-App
   ```

2. **Setup Environment Variables:**
   Create a `.env` file in the root directory and add your Groq API Key:
   ```env
   GROQ_API_KEY=your_api_key_here
   ```

3. **Install Dependencies:**
   ```sh
   flutter pub get
   ```

4. **Generate App Icons:**
   ```sh
   dart run flutter_launcher_icons
   ```

5. **Run the App:**
   ```sh
   flutter run
   ```

## 📸 Project Architecture
*   `lib/core/`: Contains the premium theme and styling.
*   `lib/services/`: Core logic for AI (GrokService), Auth, and Database.
*   `lib/screens/`: Feature-rich screens for Profile, Dashboard, and Discovery.
*   `lib/providers/`: State management for Language and Theme.

---
Developed by [Siddhart](https://github.com/siddhart3000)
>>>>>>> 77805ae (Initial commit - Secure setup with proper gitignore)
