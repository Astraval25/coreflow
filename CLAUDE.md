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

## Employee Module (modemp) — Upcoming Implementation

API documentation: `docs/employee/api.md`

### Overview

The employee module (`modemp`) adds workforce management to CoreFlow — employees, salary configs, work definitions, work logs, leave logs, salary calculation, and an employee self-service portal.

### API base prefix

- **Admin APIs**: `/api/companies/{companyId}/modemp/...`
- **Employee self-service APIs**: `/api/emp/...` (scoped by JWT, no companyId/employeeId in URL)
- **Employee auth**: `POST /api/auth/employee/company/{companyId}` (public, returns `role: "EMP"` JWT)

### Enum values

| Enum | Values |
|------|--------|
| SalaryType | `MONTHLY`, `WORK_BASED` |
| WorkUnit | `KG`, `PC`, `BOX`, `LITER`, `METER`, `GRAM`, `HOUR` |
| WorkLogStatus | `PENDING`, `APPROVED`, `REJECTED` |
| LeaveType | `FULL_DAY`, `HALF_DAY` |
| LeaveCategory | `CASUAL`, `SICK`, `UNPAID`, `LOP` |
| LeaveStatus | `PENDING`, `APPROVED`, `REJECTED` |
| SalaryPeriodStatus | `DRAFT`, `APPROVED`, `PAID` |
| SalaryLineType | `FIXED`, `WORK_EARNING`, `DEDUCTION`, `BONUS` |

### Planned file structure

```
lib/
  core/config/app_config.dart          # Add modemp endpoint constants + URL builders
  core/storage/token_storage.dart      # Add employee auth data (employeeId, role=EMP)
  data/repositories/employee_repository/
    employee_repository.dart           # All modemp API calls (mirrors AuthRepository pattern)
  domain/model/employee_model/
    employee.dart                      # Employee, EmployeeDetail, SalaryConfigHistory
    work_definition.dart               # WorkDefinition, RateHistory
    work_log.dart                      # WorkLog
    leave_log.dart                     # LeaveLog
    salary.dart                        # SalaryPeriod, SalaryPeriodDetail, SalaryLine, SalaryReport
    portal_user.dart                   # PortalUser
    employee_login.dart                # EmployeeLoginRequest/Response
  features/employee_feature/
    employees/                         # CRUD + list employees (admin)
      view/
      view_model/
      widget/
    work_definitions/                  # CRUD + list work definitions (admin)
      view/
      view_model/
      widget/
    work_logs/                         # Create/list/review work logs (admin + employee)
      view/
      view_model/
      widget/
    leave_logs/                        # Create/list/review leave logs (admin + employee)
      view/
      view_model/
      widget/
    salary/                            # Calculate/approve/pay salary, reports (admin)
      view/
      view_model/
      widget/
    portal/                            # Employee self-service (my profile, my salary, my logs)
      view/
      view_model/
      widget/
  routing/app_routinf.dart             # Add employee module routes
```

### Planned routes

```
cf/company/:companyId/employees                          # Employee list
cf/company/:companyId/employees/create                   # Create employee
cf/company/:companyId/employees/:employeeId/detail       # Employee detail
cf/company/:companyId/employees/:employeeId/update       # Update employee
cf/company/:companyId/work-definitions                   # Work definitions list
cf/company/:companyId/work-definitions/create            # Create work definition
cf/company/:companyId/work-definitions/:workDefId/detail # Work definition detail
cf/company/:companyId/work-logs                          # Work logs (admin)
cf/company/:companyId/leave-logs                         # Leave logs (admin)
cf/company/:companyId/salary                             # Salary periods list
cf/company/:companyId/salary/:salaryPeriodId/detail      # Salary period detail
cf/emp/login                                             # Employee login
cf/emp/dashboard                                         # Employee self-service home
cf/emp/work-logs                                         # My work logs
cf/emp/leave-logs                                        # My leave logs
cf/emp/salary                                            # My salary periods
cf/emp/salary/:salaryPeriodId/detail                     # My salary detail
cf/emp/profile                                           # My profile
```

### Key implementation notes

- **Separate repository**: Use `EmployeeRepository` (already has empty directory at `data/repositories/employee_repository/`) — do NOT add to `AuthRepository`.
- **Employee auth is separate**: Employee login returns a different JWT with `role: "EMP"`. Token refresh uses `/api/auth/employee/refresh-token`. Store employee auth data alongside (or separate from) admin auth in `TokenStorage`.
- **Locked-date validation**: Work log and leave log creation is blocked when salary is already calculated for that date (HTTP 406). Show the error message to the user.
- **Salary calculation overlap**: Date ranges must not overlap existing salary periods. DRAFT periods with same dates get replaced on recalculate.
- **PDF salary slip**: APIs #34 and #40 return binary PDF — use `ApiService` to download and display/share via `pdf` / `share_plus`.
- **Self-service APIs** (`/api/emp/*`) auto-scope to the logged-in employee via JWT — no need to pass companyId or employeeId.
