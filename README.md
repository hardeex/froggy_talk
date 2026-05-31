# FroggyTalk — Flutter Take-Home Assignment

A polished, production-structured Flutter app that enables African diaspora users to sign up, manage a currency-aware wallet, view transaction history, and top up — built as a take-home evaluation submission.

---

## Screenshots

| Sign Up                         | Wallet Home                  | Top Up                                 | Top-Up Result                   |
| ------------------------------- | ---------------------------- | -------------------------------------- | ------------------------------- |
| Country picker, full validation | Balance card + activity feed | Preset/custom amounts + payment method | Animated success/failure screen |

---

## Setup & Running

### Prerequisites

- Flutter SDK `>=3.0.0` (tested on 3.22.x)
- Dart SDK `>=3.0.0`
- Android emulator / iOS Simulator / physical device

### Steps

```bash
# 1. Clone the repo
git clone https://github.com/hardeex/froggytalk.git
cd froggytalk

# 2. Install dependencies
flutter pub get

# 3. Run on your device
flutter run

# 4. Run tests
flutter test
```

> **Note**: The app uses `assets/data/countries.json` for country/currency data — no network connection is required.

---

## Architecture

The project follows a **layered architecture** inspired by Clean Architecture, adapted for a focused mobile scope:

```
lib/
├── core/
│   ├── constants/       # AppTheme, AppRouter (go_router), AppConstants
│   └── errors/          # Sealed AppException types
├── data/
│   ├── datasources/     # MockApiDataSource — simulates all Laravel endpoints
│   ├── models/          # Country, AppUser, Wallet, WalletActivity, DTOs
│   └── repositories/    # AuthRepository, WalletRepository (interface + impl)
└── presentation/
    ├── providers/        # Riverpod: authStateProvider, walletProvider, coreProviders
    ├── screens/
    │   ├── auth/         # SignupScreen
    │   ├── wallet/       # WalletHomeScreen
    │   └── topup/        # TopupScreen
    └── widgets/
        └── common/       # WalletCard, ActivityListItem, AppButton, shimmer, states
```

### Key Architectural Decisions

**Separation of concerns via repository pattern**
`MockApiDataSource` simulates HTTP calls and acts as the in-memory "database". Repositories wrap it with typed interfaces. This means swapping the mock for a real `Dio`/`http` implementation requires only changing the datasource — zero changes to providers or UI.

**Mock → Real API path**
Every mock method maps 1:1 to a Laravel endpoint:

| Mock method           | Laravel endpoint           |
| --------------------- | -------------------------- |
| `register(req)`       | `POST /api/register`       |
| `getCountries()`      | `GET /api/countries`       |
| `getWallet()`         | `GET /api/wallet`          |
| `getWalletActivity()` | `GET /api/wallet/activity` |
| `topUp(req)`          | `POST /api/wallet/topup`   |

To switch to real APIs: replace `MockApiDataSource` with a `HttpApiDataSource` using `Dio`, point to `AppConstants.apiBaseUrl`, and inject a `BearerTokenInterceptor`.

---

## State Management: Riverpod

**Why Riverpod over Bloc/Provider?**

| Consideration              | Decision                                                                       |
| -------------------------- | ------------------------------------------------------------------------------ |
| Compile-time safety        | Riverpod's type-safe providers catch errors at compile time, not runtime       |
| Testability                | Providers are easily overridden in tests via `ProviderScope`                   |
| No `BuildContext` required | Business logic can call providers without widget tree access                   |
| Composability              | `ref.watch` / `ref.read` enable clean dependency injection without boilerplate |
| Code volume                | Significantly less boilerplate than BLoC for this scope                        |

**Provider structure:**

```
mockApiProvider (singleton datasource)
    └── authRepositoryProvider
    └── walletRepositoryProvider
            ├── authStateProvider (NotifierProvider<AuthNotifier, AuthState>)
            ├── countriesProvider (FutureProvider<List<Country>>)
            └── walletProvider (NotifierProvider<WalletNotifier, WalletState>)
```

`Notifier` is used over `StateNotifier` as it's the modern Riverpod 2.x pattern with direct `ref` access.

---

## Testing

```bash
# All tests
flutter test

# Unit tests only
flutter test test/unit/

# Widget tests only
flutter test test/widget/
```

### Unit Tests (`test/unit/business_logic_test.dart`)

- Country `fromJson` parsing and equality
- Country → currency code mapping for all 5 supported countries
- Wallet balance updates after top-up
- `copyWith` immutability
- `lastTopUpDate` update
- Activity list mutation (add top-up, add failed top-up)
- `ActivityType.isCredit` for all types
- `ActivityStatus` labels
- Currency symbol map completeness

### Widget Tests (`test/widget/widget_test.dart`)

- `WalletCard`: renders correct currency symbol, code, user name, last top-up date, "no top-ups" state, updated balance
- `ActivityListItem`: all type labels, all status badges, `+`/`-` prefix logic
- `AppButton`: label, loading state, tap callback, disabled state
- `EmptyStateWidget`: title + subtitle render
- `ErrorStateWidget`: message, retry button shown/hidden

---

## What I'd Improve With More Time

1. **Real API integration** — drop in `Dio` with a `BearerTokenInterceptor`, handle Laravel validation error shapes (`422` with `errors` object)
2. **Persistent auth** — store the user token with `flutter_secure_storage`, restore session on app launch via a startup provider
3. **Biometric authentication** — FaceID/fingerprint for wallet access (`local_auth`)
4. **Accessibility** — add `Semantics` wrappers and screen reader support throughout
5. **Internationalisation** — `intl` ARB files for English/French/Pidgin
6. **E2E testing** — `integration_test` package to cover the full sign-up → top-up flow
7. **Push notifications** — FCM integration for transaction confirmations
8. **Rate limiting UX** — back-off UI for failed payment retries
9. **Real payment flow** — Paystack or Stripe Flutter SDK for the top-up screen
10. **Deep linking** — `go_router` redirect rules for share links and notification taps

---

## Dependencies Summary

| Package                 | Purpose                                  |
| ----------------------- | ---------------------------------------- |
| `flutter_riverpod ^2.5` | State management                         |
| `go_router ^13`         | Declarative routing with redirect guards |
| `google_fonts ^6`       | `DM Sans` typography                     |
| `flutter_animate ^4`    | Entry animations & micro-interactions    |
| `shimmer ^3`            | Skeleton loading states                  |
| `intl ^0.19`            | Currency formatting, date formatting     |
| `equatable ^2`          | Value equality on models                 |
| `uuid ^4`               | ID generation in mock datasource         |
| `gap ^3`                | Readable spacing in layouts              |
