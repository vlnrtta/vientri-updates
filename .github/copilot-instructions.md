# Copilot Instructions for the Vientri Codebase

## Overview
Vientri is a Flutter-based management system with both mobile and web interfaces. This guide provides essential context for AI agents working with the codebase.

## Core Architecture

### Multi-Platform Structure
- **Web Build**: Hosted at `https://vientri.netlify.app` with hash routing (`/#/...`)
- **Mobile Apps**: Native Android/iOS implementations using Flutter
- **Shared Logic**: Core business logic in `lib/services`, UI in `lib/pages`

### Key Services
Services in `lib/services/` manage API interactions and data:
- `boot_page.dart` - Initial routing and session verification
- `auth_service.dart` - Authentication state management
- `credenciales_provider.dart` - API credential handling

### Session Management
- User data stored in `GetStorage` via `storage.write('user', entidad.toJson())`
- Login check happens in `BootPage` on app startup
- Unauthenticated users always redirected to `LoginPage` (`/`)

## Web Routing & Authentication Flow

### URL Structure
Web routes use hash routing: `https://vientri.netlify.app/#/web/tiquet/750007`

### Authentication Flow for Web
1. User accesses `https://vientri.netlify.app/#/web/tiquet/750007`
2. `main.dart` captures URL in `Uri.base` and stores as `pending_route`
3. App starts at `BootPage` (`/boot`)
4. `BootPage._handleRouting()` checks authentication:
   - **No session**: Stores pending route, redirects to `/` (LoginPage)
   - **Has session**: Navigates to pending route with params intact
5. User logs in via `LoginController.iniciarSesion()`
6. After successful login, retrieves `pending_route` and navigates
7. **Protected web pages** use `_MyAppState._protectedWebPage()` middleware

### Example: Accessing Tiquet Details
```
URL: https://vientri.netlify.app/#/web/tiquet/750007
↓ (No session)
LoginPage (user logs in)
↓
DetalleTiqueWeb(idTique: 750007)
```

## Developer Workflows

### Building
- **Android APK**: `flutter build apk`
- **Web**: `flutter build web` (deployed to Netlify)
- **Dependencies**: `flutter pub get`

### Testing
- **Run Tests**: `flutter test`
- **Test Files**: `test/` directory
- **Debug**: Use IDE breakpoints or Flutter DevTools

### Local Development
- **Hot Reload**: `flutter run` with `r` key
- **Web Dev**: `flutter run -d chrome` for Chrome testing

## Project-Specific Conventions

### Naming & Structure
- **Files**: snake_case (e.g., `detalle_tique_web.dart`)
- **Classes**: PascalCase (e.g., `DetalleTiqueWeb`, `LoginController`)
- **Methods/Variables**: camelCase (e.g., `handleRouting()`, `entidad`)
- **Pages Directory**: `lib/pages/` with feature-based subdirectories
- **Services Directory**: `lib/services/` for business logic

### State Management
- Uses **GetX** (`get: ^4.7.2`) for routing and state
- Navigation: `Get.offAllNamed(route)` or `Get.toNamed(route)`
- Storage: `GetStorage` for persistent data

### Authentication & Authorization
- Check session in `GetStorage().read('user')`
- Entidad model contains user data, permissions, roles
- Protected routes must verify session before rendering

## Integration Points

### External Dependencies
- **Firebase**: Backend services (`firebase_core`, `firebase_messaging`)
- **HTTP**: API calls via `http` package
- **State**: GetX for routing and state management
- **Persistence**: GetStorage for local data
- **Voice**: `flutter_sound`, `speech_to_text` (tiquetera module)

### Cross-Component Communication
- **Event Bus**: Services communicate via GetX event system
- **SharedData**: Entidad object passed between pages
- **API Integration**: CredencialesProvider handles auth, other providers handle domain data

## Key Files Reference

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry, GetMaterialApp config, route definitions |
| `lib/services/boot_page.dart` | Initial routing & session check |
| `lib/services/auth_service.dart` | Authentication utilities |
| `lib/pages/comunes/login/login_controller.dart` | Login logic |
| `lib/pages/tiquetera/detalle_tique_web.dart` | Web tiquet detail view |
| `pubspec.yaml` | Dependencies (Firebase, GetX, audio, scanner, etc.) |

## Important Context

### Tiquetera Module
The tiquet system is a core feature with:
- `DetalleTique` - Mobile view
- `DetalleTiqueWeb` - Web view (requires session)
- `AudioDetalleTique` - Voice-enabled variant
- Audio support via `flutter_sound` and `just_audio`

### Web-Specific Considerations
- Hash routing required for URL handling
- Session stored in browser storage via GetStorage
- Protected pages redirect unauthenticated users to login
- Netlify deployment handles static file serving

### Mobile Deep Linking
- App can receive `vientri://tiquet/...` deep links
- BootPage attempts to launch native app from web for Android
- Fallback to web experience if app not installed

## Common Tasks

**Add New Protected Web Route**:
Use `_protectedWebPage()` in `main.dart`:
```dart
_protectedWebPage(
  name: '/web/newpage/:id',
  pageBuilder: () => MyPage(id: int.parse(Get.parameters['id']!)),
)
```

**Handle Pending Navigation**:
`LoginController.iniciarSesion()` automatically handles redirects via `pending_route`.

**Check User Session**:
```dart
final user = GetStorage().read('user');
if (user != null) {
  final entidad = Entidad.fromJson(user);
}
```