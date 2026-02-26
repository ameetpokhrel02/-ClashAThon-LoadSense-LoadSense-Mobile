# 📱 LoadSense Mobile
### Academic Overload Detection System – Mobile App

LoadSense Mobile is the Flutter-based companion application for the LoadSense platform.

It enables students to detect academic overload, receive AI study plans, and manage deadlines directly from their smartphones.

---

## 📌 Problem

Students often face clustered academic deadlines across assignments, vivas, and projects.

Desktop-only tools limit accessibility.

Students need:

✔ Real-time alerts  
✔ Mobile planning  
✔ On-the-go workload visibility  

---

## 💡 Solution

LoadSense Mobile provides:

- Deadline tracking
- Weekly workload visualization
- Overload alerts
- AI study planning

All accessible anytime from mobile.

Students can also:

✔ Convert AI suggestions into tasks  
✔ Execute study plans within the app  

---

## ⭐ USP

Unlike traditional LMS mobile apps that only display schedules,

LoadSense Mobile:

- Detects overload
- Generates AI study plans
- Enables in-app study execution

It transforms mobile usage into an active academic planning tool.

---

## ⚙️ Tech Stack

| Layer | Technology |
|------|------------|
| Mobile | Flutter |
| API | Node.js + Express |
| Database | MongoDB |
| AI | Gemini API |

---

## 🧩 Features

- Login & Authentication
- Course Tracking
- Deadline Management
- Workload Heatmap
- Overload Alerts
- AI Study Planner

---

## 🚀 Setup Instructions

### 1️⃣ Clone Repo

```bash
git clone https://github.com/your-username/LoadSense-Mobile
cd LoadSense-Mobile

2️⃣ Install Dependencies
flutter pub get
3️⃣ Run App
flutter run
🔑 Environment Variables

Create .env file:

API_URL=http://localhost:5000
📱 App Flow

User → Mobile UI → REST API → Backend Logic → MongoDB

🌐 Backend Connection

Mobile app connects to:

https://loadsense-backend.onrender.com
📊 Impact

Mobile access enables:

✔ Faster planning
✔ Instant overload alerts
✔ AI-guided preparation

👥 Team

Same as LoadSense Core Platform

🔮 Future Scope

Push Notifications

Offline Planning

Faculty Insights

⭐ Built for Clash-a-Thon 2026

---

# 📄 .env.example (Mobile)

Create:


.env.example


Add:


API_URL=https://your-render-backend-url.onrender.com


---

# 📄 MOBILE_ARCHITECTURE.md

Create:


docs/MOBILE_ARCHITECTURE.md


Paste:

```md
# 📱 Mobile Architecture

LoadSense Mobile follows:

UI Layer → API Layer → Backend → Database

Flutter handles:

- State management
- UI rendering
- API requests

Backend handles:

- Workload calculation
- AI generation
- Data persistence
🟢 Repo Creation Steps
