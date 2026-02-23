# Web Authentication Flow - Quick Guide

## 🎯 What You Implemented

Your Vientri web app now supports authenticated access to protected pages via URLs like:
```
https://vientri.netlify.app/#/web/tiquet/750007
```

## 🔄 Complete Flow

### 1. **User accesses URL without session**
```
https://vientri.netlify.app/#/web/tiquet/750007
↓
App starts → main.dart captures Uri.fragment
↓
Stores: pending_route = "/web/tiquet/750007" ✓ (WITH ID)
↓
App continues → BootPage
↓
No session found
↓
User redirected to LoginPage (pending_route preserved)
```

### 2. **User logs in**
```
LoginPage (user enters credentials)
↓
LoginController.iniciarSesion()
  ├─ Validates credentials
  ├─ Saves user to GetStorage
  ├─ Retrieves pending_route = "/web/tiquet/750007" ✓
  └─ Navigates to pending_route
↓
DetalleTiqueWeb(idTique: 750007) ✓ CORRECT ID
```

### 3. **User already has session**
```
https://vientri.netlify.app/#/web/tiquet/750007
↓
App starts → BootPage checks session
↓
Session found ✓
↓
Navigates directly to:
DetalleTiqueWeb(idTique: 750007) ✓ CORRECT ID
```

## 📁 Key Files Modified

1. **`lib/main.dart`**
   - Added `_protectedWebPage()` middleware
   - Protects `/web/*` routes with session verification
   - Automatically saves pending routes

2. **`lib/services/boot_page.dart`**
   - Enhanced `_handleRouting()` method
   - Handles both web and mobile routing
   - Preserves route parameters

3. **`lib/services/auth_service.dart`** (New)
   - Centralized authentication utilities
   - Manages pending routes
   - Provides `isAuthenticated()` check

4. **`lib/pages/comunes/login/login_controller.dart`**
   - Simplified login success handling
   - Automatic redirect to pending routes

## 🚀 Adding More Protected Web Routes

To add a new protected web page:

```dart
// In main.dart getPages array:
_protectedWebPage(
  name: '/web/my-feature/:id',
  pageBuilder: () {
    final id = Get.parameters['id']!;
    return MyFeaturePage(id: id);
  },
),
```

## 🔐 How Authentication Works

1. **Session Storage**:
   - User data stored in `GetStorage` as JSON
   - Persists across app restarts
   - Available via: `GetStorage().read('user')`

2. **Protected Routes**:
   - Middleware checks `_protectedWebPage()`
   - Unauthenticated users see `LoginPage`
   - Pending route stored automatically

3. **Redirect After Login**:
   - LoginController checks for `pending_route`
   - Navigates using GetX route system
   - Route parameters preserved

## 🧪 Testing the Flow

### Test 1: No Session
1. Open: `https://vientri.netlify.app/#/web/tiquet/750007`
2. Expected: Redirects to login
3. Login with valid credentials
4. Expected: Auto-redirects to tiquet detail page

### Test 2: With Session
1. Login to app normally
2. Open: `https://vientri.netlify.app/#/web/tiquet/750007`
3. Expected: Direct access to tiquet page (no login needed)

### Test 3: Different Routes
```
https://vientri.netlify.app/#/web/tiquet/123456
https://vientri.netlify.app/#/web/tiquet/789012
```
(Add as many protected routes as needed following the same pattern)

## 💡 Common Issues & Solutions

**Issue**: Page shows login even with session
- **Solution**: Clear browser cache/storage and login again

**Issue**: Route parameters lost after login
- **Solution**: GetX automatically preserves them; check URL format is correct

**Issue**: Pending route not redirecting
- **Solution**: Verify route name matches exactly in getPages array

## 📝 Next Steps

- Add more protected web routes as needed
- Implement role-based access control in `_protectedWebPage()`
- Add deep linking support for mobile app
- Consider adding route guards for specific permissions
