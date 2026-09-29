# SpentWhat — Personal Expense Tracker

A Flutter mobile app to track, categorize, and analyze personal expenses with real-time Firebase sync.

## Features

- 📊 **Dashboard** — Monthly spending overview with month navigation
- 📋 **Expense History** — Filterable list by category and date range
- 📈 **Reports** — Category-wise spending breakdown with progress bars
- ➕ **Add / Edit / Delete** — Full CRUD with Firestore persistence
- 🌙 **Dark / Light / System Theme** — Instant theme switching
- 💱 **Multi-currency support** — LKR, USD, EUR, GBP, INR, JPY, AUD
- 🌐 **Language settings** — UI locale switching (Material widgets)
- ♿ **Accessibility** — Semantics labels for screen readers (ADA compliant)

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x |
| State Management | Provider + ChangeNotifier |
| Backend / DB | Cloud Firestore (Firebase) |
| Auth | None (single-user, demo_user_1) |
| Localization | flutter_localizations |

## Setup

### 1. Prerequisites

- Flutter SDK >= 3.0.0
- A Firebase project with Firestore enabled

### 2. Firebase Configuration

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Register your Android app and download `google-services.json` → place in `android/app/`
3. Enable Firestore in **Test mode**
4. Copy `.env.example` → `.env` and fill in your credentials:

```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_MESSAGING_SENDER_ID=your-sender-id
FIREBASE_STORAGE_BUCKET=your-project.firebasestorage.app
FIREBASE_ANDROID_API_KEY=AIzaSy...
FIREBASE_ANDROID_APP_ID=1:xxx:android:yyy
```

### 3. Run

```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── main.dart                  # App entry, providers, MaterialApp
├── firebase_options.dart      # Firebase config from .env (gitignored)
├── models/
│   └── expense.dart           # Expense data model + Firestore serialization
├── providers/
│   ├── expense_provider.dart  # CRUD state management
│   └── app_settings_provider.dart # Theme / currency / language settings
├── repositories/
│   └── expense_repository.dart # Firestore CRUD operations
├── screens/
│   ├── main_navigation_screen.dart
│   ├── dashboard_screen.dart
│   ├── expense_history_screen.dart
│   ├── expense_form_screen.dart
│   ├── reports_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── expense_card.dart
│   ├── expense_form.dart
│   ├── gradient_app_bar.dart
│   ├── monthly_summary.dart
│   ├── category_selector.dart
│   ├── empty_view.dart
│   ├── error_view.dart
│   └── loading_view.dart
├── theme/
│   ├── app_theme.dart
│   └── app_colors.dart
└── utils/
    ├── app_constants.dart
    ├── currency_formatter.dart
    └── date_utils.dart
```

## Security

- `.env` and `google-services.json` are in `.gitignore` — never committed
- Firestore rules enforce per-user isolation (see `firestore.rules`)

## Testing

```bash
flutter test        # Run all 22 unit + widget tests
flutter analyze     # Static analysis
```
