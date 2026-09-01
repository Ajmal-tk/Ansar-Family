# Ansar Family - Local Muslim Community Empowerment Platform (MVP)

A cross-platform (Web, Android, iOS, Windows) community management application built with **Flutter** and **Supabase**. The platform enables local Muslim communities to manage membership requests, family dependents, community assistance/service posts, and financial fee collections with automated PDF certificate and report generation.

---

## 📋 Existing Supabase Database Schema

This application integrates directly with your existing Supabase database instance without modifying table structures:

1. **`public.profiles`**: Links to `auth.users` (`id`, `username`, `full_name`, `avatar_url`, `updated_at`, `role`, `status`, `phone`, `address`).
2. **`public.posts`**: Community assistance requests & announcements (`id`, `user_id`, `content`, `created_at`).
3. **`public.membership_fees`**: Financial tracking & fee receipts (`id`, `user_id`, `amount`, `currency`, `period`, `status`, `payment_date`, `created_by`).
4. **`public.family_members`**: Registered household dependents (`id`, `user_id`, `name`, `relation`, `age`, `created_at`).

---

## ⚡ Quick Start & Local Setup

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0.0 or higher)
- [Dart SDK](https://dart.dev/)
- Chrome / Edge browser (for Web) or Visual Studio (for Windows Desktop)

### 2. Install Dependencies
Navigate to the project root directory and install dependencies:
```bash
cd ansar_family
flutter pub get
```

### 3. Connect Your Supabase Instance
Open `lib/config/supabase_config.dart` and paste your Supabase Project URL and Anon API Key:
```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://YOUR_SUPABASE_PROJECT_ID.supabase.co';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```
*Alternatively, pass credentials during launch via `--dart-define`:*
```bash
flutter run -d chrome --dart-define=SUPABASE_URL=https://xyz.supabase.co --dart-define=SUPABASE_ANON_KEY=ey...
```

### 4. Run SQL RLS & Triggers Migration
1. Log into your [Supabase Dashboard](https://supabase.com/dashboard).
2. Open **SQL Editor**.
3. Copy the contents of [`supabase_schema_rls.sql`](supabase_schema_rls.sql) and click **Run**.

This script sets up:
- Automated `auth.users` to `public.profiles` profile creation trigger.
- Strict Row-Level Security (RLS) policies for `profiles`, `posts`, `membership_fees`, and `family_members`.

---

## 🚀 Running the App Locally

### Web
```bash
flutter run -d chrome
```

### Windows Desktop
```bash
flutter run -d windows
```

### Android Emulator
```bash
flutter run -d android
```

---

## 🛠️ Feature Overview & User Roles

### Role-Based Access Control (RBAC)
- **Public / Member (`role: 'member'`)**:
  - Register community account (initial status: `pending`).
  - Add and manage family dependents (`family_members`).
  - Create community posts / assistance requests (`posts`).
  - Pay membership fees & donate via zero-cost Sandbox Checkout (`membership_fees`).
  - Download official printable **Membership Certificate PDF** upon approval.

- **Executive Management (`role: 'management'`)**:
  - User-friendly overview dashboard with real-time KPI metrics.
  - **1-Click Approvals**: Review and approve/reject pending member applications.
  - Track financial fee collections and record manual offline payments.
  - Export printable **Financial Summary PDF Reports**.

- **System Admin (`role: 'admin'`)**:
  - Full CRUD control over user roles (`admin`, `management`, `member`) and statuses.
  - Database profiles inspection panel.

---

## 🌐 Zero-Cost Hosting & Deployment

### 1. Free Web Hosting (Vercel or Netlify)
1. Build the production Flutter Web bundle:
   ```bash
   flutter build web --release
   ```
2. Upload or connect the generated `build/web` directory to **Vercel** or **Netlify** (both offer generous free tier static web hosting).

### 2. Free Android APK Build
Build a standalone Android APK:
```bash
flutter build apk --release
```
The compiled APK will be available in `build/app/outputs/flutter-apk/app-release.apk`.

### 3. Free Windows Desktop EXE Build
Build a native Windows executable:
```bash
flutter build windows --release
```
The executable will be generated in `build/windows/x64/runner/Release/`.

---

## 📄 License & Contact
Built for the **Ansar Family** local Muslim community empowerment initiative.
