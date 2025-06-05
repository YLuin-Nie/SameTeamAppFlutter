# SameTeamAppFlutter

A Flutter-based mobile version of the SameTeamApp, originally built in React with an ASP.NET Core backend. This cross-platform app helps parents and children manage chores, track rewards, and promote teamwork at home.

## 📱 Description

SameTeamAppFlutter is a mobile productivity and parenting tool built with Flutter. Parents can assign chores, children can complete them, and everyone stays on the same page. It connects to a secure ASP.NET Core API hosted on Azure with an Azure SQL Database using JWT authentication. It replaces localStorage with scalable cloud-based storage.

## 🚀 Technologies Used

- **Flutter & Dart** – Cross-platform UI development
- **Android Studio** – Main IDE for development
- **Provider** – State management
- **HTTP / Shared Preferences** – For API communication and local session storage
- **ASP.NET Core Web API** – Backend service for user authentication, chores, rewards, and team management
- **Azure SQL Database** – Persistent data storage

## 🔒 Features

- User Authentication (Sign In / Sign Up with optional Team creation)
- Role-based access (Parent / Child)
- Parent Dashboard: Add, assign, and track chores and rewards
- Child Dashboard: View and complete assigned chores
- Reward System: Earn points and redeem them
- Theme toggle (light/dark mode) support
- Responsive UI for Android, iOS, web, and desktop

## 🌐 Backend API

SameTeamAppFlutter connects to a live ASP.NET Core backend hosted on Azure.

Key Endpoints:
- `POST /Auth/register` – User Registration
- `POST /Auth/login` – User Login
- `GET /Chores`, `POST /Chores` – Chore Management
- `GET /Rewards`, `POST /Rewards` – Reward System
- `GET /Users`, `GET /Teams`, etc. – Team/User Management