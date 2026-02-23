# Testing Guide - Web Authentication

## 🧪 Pre-Deployment Testing

Run through these tests to verify the web authentication system is working correctly.

---

## Test Suite 1: No Session (Cold Start)

### Test 1.1: Direct URL Access Without Session

**Steps:**
1. Clear browser storage (DevTools → Application → LocalStorage → Clear All)
2. Open: `https://vientri.netlify.app/#/web/tiquet/750007`

**Expected Result:**
- ✓ Page shows LoginPage
- ✓ No error messages
- ✓ Login form is visible

**Verify in Browser Console:**
```javascript
console.log(localStorage.getItem('pending_route'));
// Output: /web/tiquet/750007
```

---

### Test 1.2: Login Redirects to Pending Route

**Steps:**
1. From LoginPage (previous test)
2. Enter valid credentials
3. Click Login

**Expected Result:**
- ✓ Loading spinner appears
- ✓ After successful login, auto-redirects
- ✓ Lands on DetalleTiqueWeb page (tiquet detail)
- ✓ Tiquet ID 750007 is displayed

**Verify:**
```javascript
console.log(localStorage.getItem('user'));
// Should show user object (not null)
console.log(localStorage.getItem('pending_route'));
// Should be null or empty (cleared after navigation)
```

---

## Test Suite 2: Session Exists (Warm Start)

### Test 2.1: Direct Access With Session

**Steps:**
1. Stay logged in from previous test
2. Open new URL: `https://vientri.netlify.app/#/web/tiquet/123456`

**Expected Result:**
- ✓ No LoginPage shown
- ✓ Direct access to DetalleTiqueWeb
- ✓ Tiquet ID 123456 is displayed
- ✓ No redirect delay

**Verify:**
```javascript
console.log(localStorage.getItem('user'));
// Should show user object
```

---

### Test 2.2: Multiple Different URLs

**Steps:**
1. While still logged in
2. Access multiple URLs in sequence:
   - `https://vientri.netlify.app/#/web/tiquet/111111`
   - `https://vientri.netlify.app/#/web/tiquet/222222`
   - `https://vientri.netlify.app/#/web/tiquet/333333`

**Expected Result:**
- ✓ Each URL loads directly without login
- ✓ Each tiquet ID displays correctly
- ✓ No errors in console

---

## Test Suite 3: Route Parameters

### Test 3.1: Parameter Extraction

**Steps:**
1. Access URL: `https://vientri.netlify.app/#/web/tiquet/999999`

**Expected Result:**
- ✓ Tiquet ID 999999 is parsed correctly
- ✓ Component receives correct ID
- ✓ Data loads for that specific ID

**Verify in Browser Console (Flutter Web Inspector):**
```javascript
// Check GetX parameters
console.log('GetX should extract: id = "999999"');
```

---

## Test Suite 4: Session Logout & Re-login

### Test 4.1: Logout Clears Session

**Steps:**
1. While logged in and viewing a page
2. Logout (usually in app menu)

**Expected Result:**
- ✓ User data cleared from storage
- ✓ Redirects to LoginPage
- ✓ localStorage shows no 'user' key

**Verify:**
```javascript
console.log(localStorage.getItem('user'));
// Should output: null
```

---

### Test 4.2: Re-login After Logout

**Steps:**
1. From LogoutPage
2. Login again with different URL: `https://vientri.netlify.app/#/web/tiquet/555555`

**Expected Result:**
- ✓ LoginPage appears (no session yet)
- ✓ After login, auto-redirects to 555555
- ✓ Session restored

---

## Test Suite 5: Error Handling

### Test 5.1: Invalid Credentials

**Steps:**
1. Clear localStorage (logout)
2. Access: `https://vientri.netlify.app/#/web/tiquet/750007`
3. Enter invalid credentials
4. Click Login

**Expected Result:**
- ✓ Error message appears ("Usuario/contraseña inválidos")
- ✓ Stays on LoginPage
- ✓ No redirect occurs

**Verify:**
```javascript
console.log(localStorage.getItem('user'));
// Should still be null (not saved)
```

---

### Test 5.2: Network Error During Login

**Steps:**
1. Clear localStorage
2. Open DevTools → Network tab
3. Set throttling to "Offline"
4. Try to login

**Expected Result:**
- ✓ Error message appears
- ✓ Stays on LoginPage
- ✓ User can retry after network restored

---

## Test Suite 6: Page Refresh

### Test 6.1: Refresh Preserves Session

**Steps:**
1. Login and view: `https://vientri.netlify.app/#/web/tiquet/750007`
2. Press F5 (refresh page)

**Expected Result:**
- ✓ Page reloads
- ✓ Still shows tiquet detail (no redirect to login)
- ✓ Session persisted

---

### Test 6.2: Refresh Shows Login If Session Expired

**Steps:**
1. Login and view a page
2. Clear localStorage in DevTools
3. Press F5 (refresh page)

**Expected Result:**
- ✓ Redirects to LoginPage
- ✓ Shows loading indicator briefly
- ✓ No errors

---

## Test Suite 7: Navigation Between Pages

### Test 7.1: From Login to Home

**Steps:**
1. Clear localStorage
2. Access: `https://vientri.netlify.app/#/web/tiquet/750007`
3. Login
4. From tiquet page, navigate to Home (if available)

**Expected Result:**
- ✓ Navigation works smoothly
- ✓ Session maintained
- ✓ Can return to tiquet page

---

### Test 7.2: Internal Navigation

**Steps:**
1. While viewing tiquet page
2. Click any internal links

**Expected Result:**
- ✓ Navigation works
- ✓ Session maintained
- ✓ Can navigate back

---

## Test Suite 8: Mobile Responsiveness

### Test 8.1: Mobile View

**Steps:**
1. Open DevTools → Device Toolbar (mobile view)
2. Access: `https://vientri.netlify.app/#/web/tiquet/750007` (without login)
3. Login in mobile view

**Expected Result:**
- ✓ LoginPage responsive on mobile
- ✓ Login works
- ✓ Auto-redirect works
- ✓ Tiquet page responsive

---

## Browser Console Inspection

### Useful Commands for Testing

```javascript
// Check if user is logged in
localStorage.getItem('user');

// Check pending route
localStorage.getItem('pending_route');

// Clear all storage (logout simulation)
localStorage.clear();

// Check specific user properties
const user = JSON.parse(localStorage.getItem('user') || '{}');
console.log(user.usuario); // username
console.log(user.token);   // auth token
console.log(user.rol);     // user role

// Check GetX routing
// (If Flutter DevTools available)
```

---

## Performance Testing

### Test 9.1: Load Time

**Steps:**
1. Using DevTools → Network tab
2. Access: `https://vientri.netlify.app/#/web/tiquet/750007`

**Measure:**
- Time to show LoginPage: Should be < 2 seconds
- Time to show tiquet page after login: Should be < 3 seconds

---

### Test 9.2: Session Persistence

**Steps:**
1. Login and view tiquet page
2. Close browser tab/window
3. Re-open URL: `https://vientri.netlify.app/#/web/tiquet/750007`

**Expected Result:**
- ✓ Session still exists (from storage)
- ✓ Direct access to page
- ✓ No login needed

---

## ✅ Test Completion Checklist

- [ ] Test 1.1: Direct URL without session shows login
- [ ] Test 1.2: Login redirects to pending URL
- [ ] Test 2.1: With session, direct access works
- [ ] Test 2.2: Multiple URLs work correctly
- [ ] Test 3.1: Route parameters extracted correctly
- [ ] Test 4.1: Logout clears session
- [ ] Test 4.2: Re-login works after logout
- [ ] Test 5.1: Invalid credentials show error
- [ ] Test 5.2: Network errors handled
- [ ] Test 6.1: Page refresh preserves session
- [ ] Test 6.2: Refresh after logout shows login
- [ ] Test 7.1: Navigation between pages works
- [ ] Test 7.2: Internal links work
- [ ] Test 8.1: Mobile responsive
- [ ] Test 9.1: Load times acceptable
- [ ] Test 9.2: Session persists across restart

---

## 🚀 Ready for Production?

When all tests pass:
1. Run: `flutter build web --release`
2. Deploy to Netlify
3. Perform final verification in production
4. Monitor error logs for 24-48 hours

---

**Test Date**: _______________  
**Tester**: _______________  
**Status**: ✅ PASS / ❌ FAIL  

---

For issues, check logs in Browser DevTools → Console tab
