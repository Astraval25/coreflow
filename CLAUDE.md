# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.
# Library Use 
- `flutter_svg` use for alternative for icon/svg for good UI.
- `share_plus` & `receive_sharing_intent` for sharing files and documents from outside app.
- `video_player` for demo view show.
- `image_picker` & `file_picker` to pick image/files.
- `pdf` for pdf generate.
- `shared_preferences` for storing data locally.
## Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run the app (requires connected device/emulator)
flutter analyze          # Static analysis / lint
flutter test             # Run all tests
flutter test test/path/to/test_file.dart  # Run a single test
flutter build apk        # Build Android APK
flutter build ios        # Build iOS (macOS only)
```

**Environment setup**: A `.env` file must exist at the project root with at least `BASE_URL=<api_base_url>`. This is loaded via `flutter_dotenv` at startup and listed as a Flutter asset.

## Architecture

This is a Flutter app using **MVVM + Provider** for state management and **go_router** for navigation.

### Routing Structure 
check the file: lib\routing\ROUTING-STRUCTURE.md

### Layer structure

```
lib/
  core/           # Shared infrastructure
    config/       # AppConfig — all API endpoint constants and URL builders
    storage/      # TokenStorage — SharedPreferences wrapper for auth data
    theme/        # ThemeProvider (ChangeNotifier), color constants
    widgets/      # Reusable UI components (skeleton, drawer, search app bar, etc.)
  data/
    repositories/ # AuthRepository — single repository handling ALL API calls
    services/     # ApiService — HTTP client with JWT auth and auto token refresh
  domain/
    model/        # Data models (request/response POJOs with fromJson/toJson)
    repositories/ # Repository interfaces/types
  features/       # Feature modules (MVVM per feature)
  routing/        # GoRouter config (app_routinf.dart — note the typo)
```

### Feature module structure

Each feature follows this pattern:
```
features/<feature>/
  view/            # Pages/screens (StatelessWidget or StatefulWidget)
  view_model/      # ChangeNotifier ViewModels
  widget/          # Feature-specific widgets, broken into subfolders
```

### Key architectural decisions

**Single repository**: `AuthRepository` (`lib/data/repositories/auth_repository.dart`) handles every API domain — auth, customers, vendors, items, sales, purchases, payments. It delegates HTTP to `ApiService`.

**ApiService auto-refresh**: `ApiService` (`lib/data/services/api_services.dart`) automatically retries requests on HTTP 401 by refreshing the JWT. The refresh is mutex-guarded to prevent concurrent refresh attempts.

**AppConfig URL builders**: All endpoints are defined as constants in `AppConfig` (`lib/core/config/app_config.dart`). URL construction uses string `replaceAll` with `{companyId}`, `{customerId}`, etc. placeholders.

**API response envelope**: All backend responses follow `{ responseStatus: bool, responseData: ..., responseMessage: string, responseCode: ... }`. HTTP 420 means the entity is inactive/deactivated.

**companyId scoping**: Nearly every API endpoint is scoped under `/api/companies/{companyId}/...`. The `companyId` is stored in `TokenStorage` after login and threaded through every repository call and route.

**Provider wiring**: ViewModels are provided at the widget tree level using `ChangeNotifierProvider`. The two global providers in `main.dart` are `ThemeProvider` and `DashboardViewModel`. Feature-scoped ViewModels are provided closer to their subtrees.

**Routing**: GoRouter (`lib/routing/app_routinf.dart`) uses a `ShellRoute` wrapping authenticated pages with `MainLayout`. A `redirect` guard checks `TokenStorage` for a valid token on every navigation. After login, the backend returns a `landingUrl` that determines where the user lands.

### Authentication flow

1. Login → `AuthRepository.login()` → save `LoginData` (token, refreshToken, companyId, landingUrl, roleCode, etc.) via `TokenStorage.saveFullAuthData()`
2. Each API request: `ApiService._makeRequest()` reads token from `SharedPreferences`, sends it as `Authorization: Bearer <token>`
3. On 401: `ApiService._performTokenRefresh()` calls `AuthRepository.refreshToken()`, saves new tokens, retries original request
4. On logout: `TokenStorage.clearAllData()` wipes all `SharedPreferences`

### Navigation routes

| Path | Page |
|------|------|
| `/login` | LoginScreen |
| `/register` | RegisterScreen |
| `/verify/:userPath` | VerifyOtpScreen |
| `/dashboard` or `/:role/dashboard` | DashboardPage (inside shell) |
| `/customers/:companyId` | ActiveCustomersPage |
| `/customers/:companyId/:customerId/edit` | CustomerEditPage |
| `/vendors/:companyId` | ActiveVendorsPage |
| `/items/:companyId` | ItemsPage |
| `/sales`, `/purchase` | Sales/Purchase order list pages |
| `/payment`, `/pay-received` | Payment sent/received pages |
| `/profile` | ProfilePage |
