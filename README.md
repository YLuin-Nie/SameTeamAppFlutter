# SameTeamAppFlutter

A modern Flutter-based version of the original SameTeamApp (previously built in React), designed to help families manage chores, track rewards, and foster teamwork across devices.

## 📱 Description

SameTeamAppFlutter is a cross-platform productivity and parenting tool that connects to a secure ASP.NET Core Web API backend hosted on Azure. Parents can create teams, assign chores and rewards, and monitor progress, while children can complete chores and redeem points — all through a seamless mobile, web, or desktop experience.

---

## 🚀 Technologies Used

| Frontend              | Backend                  | Other Tools & Services         |
|-----------------------|--------------------------|--------------------------------|
| Flutter + Dart        | ASP.NET Core Web API     | Azure App Service              |
| Android Studio        | Azure SQL Database       | GitHub                         |
| Provider (state mgmt) | Entity Framework Core    | Vercel (for React frontend)    |
| Shared Preferences    | JWT Authentication       | http-server (local web test)   |

---

## 🔐 Key Features

- ✅ **Role-Based Authentication** – Parent and Child modes
- 🧑‍🎓 **Team Management** – Create/join teams with secure codes
- ✅ **Parent Dashboard** – Assign chores, add rewards, view progress
- 🎯 **Child Dashboard** – Complete chores, track points, redeem rewards
- 🎁 **Reward System** – Earn and redeem points
- 🌙 **Theme Toggle** – Light/Dark mode support
- 🖥️ **Responsive UI** – Works on Android, iOS, Web, and Desktop
- 🔗 **Live Backend** – Hosted on Azure with persistent cloud data

---

## 🌐 API Endpoints

| Endpoint                  | Description                  |
|---------------------------|------------------------------|
| `POST /Auth/register`     | User Registration            |
| `POST /Auth/login`        | User Login                   |
| `GET /Users`              | User/Team management         |
| `GET /Chores` / `POST`    | Chore retrieval/assignment   |
| `GET /Rewards` / `POST`   | Reward management            |
| `GET /RedeemedRewards`    | Reward redemption history    |

---

## 🧪 Platforms Tested

| Platform                  | Status    |
|---------------------------|-----------|
| Chrome                    | ✅ Working |
| Edge                      | ✅ Working |
| Android Emulator (API 36) | ✅ Working |
| Windows Desktop           | ✅ Working |
| iPhone (LAN test)         | ✅ Working |
| iPad Pro (LAN test)       | ✅ Working |
| Vercel-hosted Frontend    | ✅ Working |

---

## 📦 Deployment

Backend: Azure App Service
Frontend (React version): same-team-app-full-stack.vercel.app

---

## 📈 Roadmap / TODO

- Firebase push notifications
- Offline mode support
- Child-specific avatars or profile icons
- Admin panel for team moderation