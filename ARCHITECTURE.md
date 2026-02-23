# Web Authentication System - Architecture Diagram

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    VIENTRI WEB APPLICATION                      │
│                 https://vientri.netlify.app                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │  URL Interceptor    │
                    │  (main.dart)        │
                    │  ────────────────   │
                    │ Captures: Uri.base  │
                    │ Stores: pending_route
                    └────────┬────────────┘
                             │
                             ▼
                    ┌─────────────────────┐
                    │   App Startup       │
                    │  (BootPage)         │
                    └────────┬────────────┘
                             │
                    ┌────────┴────────┐
                    │                 │
                    ▼                 ▼
         ┌───────────────────┐  ┌──────────────────┐
         │ Session Found?    │  │ No Session       │
         │      YES ✓        │  │   REDIRECT →     │
         │                   │  │  LoginPage (/)   │
         │ Navigate to       │  │                  │
         │ pending_route     │  │ Save pending_route
         │ (direct access)   │  │ in GetStorage    │
         └─────────┬─────────┘  └────────┬─────────┘
                   │                     │
                   │                     ▼
                   │            ┌───────────────────┐
                   │            │  User Enters      │
                   │            │  Credentials      │
                   │            │                   │
                   │            │ LoginController   │
                   │            │.iniciarSesion()   │
                   │            └─────────┬─────────┘
                   │                      │
                   │            ┌─────────▼─────────┐
                   │            │ Validate via API  │
                   │            │ Save to GetStorage│
                   │            │ (user data)       │
                   │            └─────────┬─────────┘
                   │                      │
                   │            ┌─────────▼─────────┐
                   │            │ Retrieve          │
                   │            │ pending_route     │
                   │            └─────────┬─────────┘
                   │                      │
                   └──────────┬───────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │ Protected Page      │
                    │ (_protectedWebPage) │
                    │ ─────────────────── │
                    │ Check Session ✓     │
                    │ Render Component    │
                    └─────────────────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │ DetalleTiqueWeb     │
                    │ (idTique: 750007)   │
                    └─────────────────────┘
```

## Route Protection Mechanism

```
┌──────────────────────────────────────────────────────────────┐
│                   _protectedWebPage()                         │
│                   ─────────────────────                       │
│                                                                │
│  Input: Route name & PageBuilder                             │
│          ↓                                                     │
│  ┌───────────────────────────────────────────────────────┐   │
│  │ Check GetStorage().read('user')                       │   │
│  └─────────────────┬─────────────────────────────────────┘   │
│                    │                                           │
│         ┌──────────┴──────────┐                               │
│         │                     │                               │
│      User ✓                No User ✗                          │
│         │                     │                               │
│         ▼                     ▼                               │
│  Build Component      Save Pending Route                      │
│  Return PageBuilder   Redirect to LoginPage                   │
│         │                     │                               │
│         └──────────┬──────────┘                               │
│                    │                                           │
│                    ▼                                           │
│            Return GetPage                                     │
│         ─────────────────────                                 │
└──────────────────────────────────────────────────────────────┘
```

## Data Flow: GetStorage (Browser Storage)

```
┌─────────────────────────────────────────────────────────────┐
│            Browser Local Storage (GetStorage)                │
│  ─────────────────────────────────────────────────────────   │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ KEY: "user"                                         │    │
│  │ VALUE: Entidad.toJson()                             │    │
│  │ ─────────────────────────────────────────────────   │    │
│  │ {                                                   │    │
│  │   "id": 123,                                        │    │
│  │   "usuario": "jsmith",                              │    │
│  │   "nombre": "John Smith",                           │    │
│  │   "token": "abc123xyz...",                          │    │
│  │   "cliente": "Acme Corp",                           │    │
│  │   ...more fields...                                 │    │
│  │ }                                                   │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ KEY: "pending_route"                                │    │
│  │ VALUE: String (route path)                          │    │
│  │ ─────────────────────────────────────────────────   │    │
│  │ "/web/tiquet/750007"                                │    │
│  │                                                     │    │
│  │ (Cleared after navigation)                         │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ KEY: "admin"                                        │    │
│  │ VALUE: boolean                                      │    │
│  │ ─────────────────────────────────────────────────   │    │
│  │ true/false                                          │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## File Dependencies

```
main.dart
  ├─ imports: services/boot_page.dart
  ├─ imports: pages/tiquetera/detalle_tique_web.dart
  ├─ imports: pages/comunes/login/login_page.dart
  ├─ defines: _protectedWebPage() middleware
  └─ defines: getPages with protected routes

boot_page.dart
  ├─ imports: get_storage
  ├─ imports: get (GetX routing)
  └─ handles: session checking & routing logic

login_controller.dart
  ├─ imports: get_storage
  ├─ imports: get (GetX)
  ├─ imports: src/providers/credenciales_provider.dart
  └─ handles: login & post-login navigation

auth_service.dart (NEW)
  ├─ singleton pattern
  ├─ getUser() / isAuthenticated()
  ├─ pending route management
  └─ logout handling
```

## Route Parameter Flow

```
URL: https://vientri.netlify.app/#/web/tiquet/750007
  │
  ▼
Route Definition: '/web/tiquet/:id'
  │
  ▼
GetPage: _protectedWebPage(
  name: '/web/tiquet/:id',
  pageBuilder: () {
    final id = int.parse(Get.parameters['id']!);
    return DetalleTiqueWeb(entidad: entidad, idTique: id);
  }
)
  │
  ▼
Get.parameters['id'] = "750007"  ← Extracted by GetX
  │
  ▼
int.parse() → 750007
  │
  ▼
DetalleTiqueWeb(idTique: 750007)  ← Component receives ID
```

## Login Success Navigation

```
┌────────────────────────────────────────┐
│  LoginController.iniciarSesion()       │
│  ────────────────────────────────────  │
│                                        │
│  1. Validate credentials               │
│     ↓                                  │
│  2. Call credencialesProvider.        │
│     obtenerCredenciales()              │
│     ↓                                  │
│  3. Save Entidad to GetStorage         │
│     GetStorage().write('user', ...)    │
│     ↓                                  │
│  4. Get pending route                  │
│     String? route =                    │
│     GetStorage().read('pending_route') │
│     ↓                                  │
│  5. Clear pending route                │
│     GetStorage().remove('pending_route')
│     ↓                                  │
│  6. Navigate                           │
│     ├─ if (pending_route != null)      │
│     │  └─ Get.offAllNamed(route)       │
│     └─ else                            │
│        └─ Get.offAllNamed('/inicio')   │
│                                        │
└────────────────────────────────────────┘
```

## Session Lifecycle

```
┌──────────────────────────────────────────────────────────────┐
│              Session Lifecycle                               │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│ CREATED           ACTIVE            USED              CLEARED │
│   ↓                 ↓                 ↓                  ↓    │
│   │                 │                 │                  │    │
│ Login          Stored in      On Each              Logout or │
│ Success        GetStorage     Protected           Expiration │
│                              Route Access                    │
│                                                               │
│ GetStorage().write(      GetStorage().read(   GetStorage().  │
│   'user',                 'user') != null →   remove('user')  │
│   entidad.toJson()        Allow Access       or              │
│ )                                            Auto-Redirect   │
│                                              to Login        │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

---

**This architecture ensures**:
- ✅ Secure access to protected web pages
- ✅ Seamless session persistence
- ✅ Route parameter preservation
- ✅ Automatic authentication redirects
- ✅ Clean separation of concerns
