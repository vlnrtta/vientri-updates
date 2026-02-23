# Quick Reference - Web Authentication

## 🎯 What This Does

Allows users to access protected web pages via URLs like:
```
https://vientri.netlify.app/#/web/tiquet/750007
```

If not logged in → Redirects to login → Auto-redirects to requested page after login  
If logged in → Direct access ✓

---

## 📍 Key Files

### `lib/main.dart`
```dart
// Middleware for protecting web routes
_protectedWebPage(
  name: '/web/tiquet/:id',
  pageBuilder: () => DetalleTiqueWeb(entidad: entidad, idTique: ...),
)
```

### `lib/services/boot_page.dart`
```dart
// Checks session on app startup
_handleRouting() {
  if (user == null) → redirect to login + save pending_route
  if (user != null) → navigate to pending_route
}
```

### `lib/pages/comunes/login/login_controller.dart`
```dart
// Auto-redirect after login
Get.offAllNamed(pendingRoute ?? '/inicio');
```

### `lib/services/auth_service.dart`
```dart
// Utility methods
AuthService().isAuthenticated()
AuthService().setPendingRoute(route)
AuthService().getPendingRoute()
```

---

## 🚀 Add a New Protected Web Page

```dart
// In main.dart getPages array:

_protectedWebPage(
  name: '/web/pedidos/:id',
  pageBuilder: () {
    final id = Get.parameters['id']!;
    return ListaPedidos(entidad: entidad);
  },
),
```

---

## 🧪 Test It

### Scenario 1: No Session
1. Open: `https://vientri.netlify.app/#/web/tiquet/750007`
2. See LoginPage
3. Login
4. Auto-redirects to tiquet page ✓

### Scenario 2: With Session
1. Already logged in
2. Open: `https://vientri.netlify.app/#/web/tiquet/750007`
3. Direct access to tiquet page ✓

---

## 🔍 How It Works (Simple Version)

```
URL → BootPage → Session Check → 
  → No? Save URL + Go to Login → User logs in → Get saved URL + Navigate ✓
  → Yes? Navigate to URL directly ✓
```

---

## 💾 Data Stored

**GetStorage (Browser Storage)**:
- `user`: Entidad object (user data + token)
- `pending_route`: Route to visit after login

---

## 🐛 Debugging

**Check if user is logged in**:
```dart
final user = GetStorage().read('user');
print('Logged in: ${user != null}');
```

**Check pending route**:
```dart
final route = GetStorage().read('pending_route');
print('Pending: $route');
```

**Clear storage** (browser DevTools):
```javascript
localStorage.clear(); // Clears everything
localStorage.removeItem('user'); // Clears just user
```

---

## ⚙️ Configuration

No additional configuration needed. The system works out of the box.

**Optional**: To add role-based access control, modify `_protectedWebPage()`:

```dart
_protectedWebPage({
  required String name,
  required GetPageBuilder pageBuilder,
  List<String>? requiredRoles, // NEW
}) {
  return GetPage(
    name: name,
    page: () {
      final user = GetStorage().read('user');
      if (user == null) {
        GetStorage().write('pending_route', name);
        return const LoginPage();
      }
      
      // NEW: Check roles
      if (requiredRoles != null) {
        final entidad = Entidad.fromJson(user);
        if (!requiredRoles.contains(entidad.rol)) {
          return const Scaffold(
            body: Center(child: Text('Access Denied')),
          );
        }
      }
      
      return pageBuilder();
    },
  );
}
```

---

## 📚 Full Documentation

- **`WEB_AUTH_FLOW.md`** - Complete flow with examples
- **`ARCHITECTURE.md`** - System architecture & diagrams
- **`IMPLEMENTATION_SUMMARY.md`** - What was changed
- **`.github/copilot-instructions.md`** - Copilot guidelines

---

## ✅ Status

- ✓ Web authentication implemented
- ✓ Protected routes working
- ✓ Session persistence enabled
- ✓ Auto-redirect on login implemented
- ✓ Build successful (Feb 10, 2026)

**Ready for production deployment! 🚀**
