# NotiFlex

A Flutter iOS app for creating customizable fake notifications from popular platforms. Supports AI-generated content, scheduled delivery, dynamic app icons, and fake incoming calls.

## Features

- **Platform Notifications** — Generate realistic notifications for WhatsApp, Instagram, Stripe, Revolut, and Shopify (more platforms coming soon)
- **AI-Powered Content** — Toggle AI mode to auto-generate notification text and images using Together AI (Llama Vision + FLUX)
- **Dynamic App Icons** — App icon automatically changes to match the selected platform
- **Notification Scheduling** — Set delivery time, repeat interval, and notification count
- **Fake Incoming Calls** — Simulate CallKit incoming calls with custom caller info
- **Firebase Auth** — Email/password and phone number authentication

## Screenshots

_Coming soon_

## Getting Started

### Prerequisites

- Flutter SDK `>=3.1.0 <4.0.0`
- Xcode (iOS only)
- CocoaPods
- A Firebase project
- A [Together AI](https://api.together.xyz/) API key

### Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/albert-mr/notiflex.git
   cd NotiFlex
   ```

2. **Set up environment variables**

   ```bash
   cp .env.example .env
   ```

   Edit `.env` and add your Together AI API key.

3. **Set up Firebase**

   Install the [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup) and configure your Firebase project:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   This generates `lib/firebase_options.dart` and `ios/Runner/GoogleService-Info.plist`.

   Enable **Authentication** (Email/Password + Phone) and **Storage** in your Firebase console.

4. **Install dependencies**

   ```bash
   flutter pub get
   cd ios && pod install && cd ..
   ```

5. **Configure dynamic app icons**

   Place the `AppIcons` directory inside `ios/Runner/` via Xcode (drag-and-drop, choose "Create groups"). See [flutter_dynamic_icon docs](https://pub.dev/packages/flutter_dynamic_icon) for details.

6. **Run the app**

   ```bash
   flutter run
   ```

## Project Structure

```
lib/
  main.dart                          # App entry point, Firebase init, auth gate
  firebase_options.dart              # Generated Firebase config (gitignored)
  components/
    platform_card.dart               # Platform display card widget
    section_title.dart               # Reusable section title
    text_field_widget.dart           # Styled text field
  screens/
    platform_selection_screen.dart   # Main screen — platform grid picker
    notification_settings_screen.dart # Notification creation form
    auth/
      login_screen.dart              # Email/password + phone auth
      phone_verification_screen.dart # OTP verification
  services/
    api_service.dart                 # Together AI API (image description, generation, notification content)
    auth_service.dart                # Firebase Auth wrapper
    icon_service.dart                # Dynamic app icon management
    notifications_service.dart       # Notification scheduling + CallKit
  utils/
    platform_helpers.dart            # Platform name/asset/validation helpers
  widgets/
    auth/
      auth_button.dart               # Auth screen button
      custom_text_field.dart         # Auth screen text field
    notifications/
      ai_notifications.dart          # AI prompt input widget
      notification_scheduler.dart    # Schedule/interval/count picker
    platforms/
      whatsapp_form.dart             # WhatsApp notification form
      stripe_form.dart               # Stripe notification form
      revolut_form.dart              # Revolut notification form
      instagram_form.dart            # Instagram notification form
      shopify_form.dart              # Shopify notification form
```

## Supported Platforms

| Platform   | Notifications | AI Content | Fake Calls | Status |
|------------|:---:|:---:|:---:|--------|
| WhatsApp   | x | x | x | Available |
| Instagram  | x | x | x | Available |
| Stripe     | x | x | x | Available |
| Revolut    | x | x | x | Available |
| Shopify    | x | x | x | Coming Soon |
| Gmail      | — | — | — | Coming Soon |
| LinkedIn   | — | — | — | Coming Soon |
| OpenAI     | — | — | — | Coming Soon |
| Uber       | — | — | — | Coming Soon |
| Binance    | — | — | — | Coming Soon |
| Spotify    | — | — | — | Coming Soon |
| Telegram   | — | — | — | Coming Soon |
| Reddit     | — | — | — | Coming Soon |
| McDonald's | — | — | — | Coming Soon |

## Tech Stack

- **Flutter** — Cross-platform UI framework
- **Firebase** — Auth (email + phone) and Storage
- **Together AI** — LLM (Llama Vision) and image generation (FLUX.1-schnell)
- **awesome_notifications** — Local notification scheduling
- **flutter_callkit_incoming** — Fake incoming call UI
- **flutter_dynamic_icon** — Runtime app icon switching

## License

MIT License. See [LICENSE](LICENSE) for details.
