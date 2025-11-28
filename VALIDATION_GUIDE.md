# Email and Password Validation Guide

## Overview

This guide explains the validation system implemented in Vida com Cristo app for email and password fields.

## Features Implemented

### 1. Email Validation
- **Pattern**: Uses regex to match valid email format
- **Regex**: `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
- **Checks**:
  - Not empty
  - Valid email format
  - Must contain @ and a domain
  - Domain must have a top-level domain (.com, .br, etc)

### 2. Password Strength Validation
- **Minimum Length**: 6 characters
- **Requirements**:
  - At least one number (0-9)
  - At least one lowercase letter (a-z)
  - Cannot contain uppercase letters only (optional for future enhancement)

### 3. Password Confirmation
- **Signup Only**: Confirmation field only appears during signup
- **Match Check**: Both passwords must be identical
- **Real-time**: Validates as user types

## Files Modified/Created

### 1. `lib/providers/auth_provider.dart` (MODIFIED)

**New Methods:**
- `_isValidEmail(String email) -> bool`
  - Returns true if email matches regex pattern
  - Used before sending to Supabase

- `_validatePassword(String password) -> String?`
  - Returns error message or null if valid
  - Checks all strength requirements

**Modified Methods:**
- `signUp()` - Now validates 5 conditions before signup
- `signIn()` - Now validates 3 conditions before login

**Validation Flow:**
```
1. Check email is not empty
2. Check email format is valid
3. Check password is not empty
4. Check password meets strength requirements
5. Check password confirmation matches (signup only)
```

### 2. `lib/screens/auth_screen.dart` (NEW)

**Features:**
- Real-time validation as user types
- Show/hide password with eye icon
- Toggle between login and signup modes
- Display error messages below each field
- Disable submit button until all fields valid
- Consumer widget for provider integration

**Validation in UI:**
```dart
_validateEmail()     // Called on email input
_validatePassword()  // Called on password input
_validateConfirm()   // Called on confirmation input
```

**Button State:**
- Disabled until all fields are valid
- Also disabled while loading
- Shows CircularProgressIndicator during submission

## Implementation Steps

### Step 1: Update AuthProvider
1. Replace your current `lib/providers/auth_provider.dart` with the new version
2. Contains all validation logic
3. Returns user-friendly error messages

### Step 2: Create AuthScreen
1. Create new file `lib/screens/auth_screen.dart`
2. Paste the complete auth screen code
3. Contains UI with real-time validation

### Step 3: Update Main App
In `lib/main.dart`, make sure you're using `AuthScreen` for unauthenticated users:
```dart
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return authProvider.isAuthenticated ? const HomeScreen() : const AuthScreen();
  }
}
```

## Error Messages

### Email Errors
- "Email nao pode estar vazio" - User didn't enter email
- "Email invalido. Use um formato correto (ex: seu@email.com)" - Invalid format

### Password Errors
- "Senha nao pode estar vazia" - User didn't enter password
- "Senha deve ter no minimo 6 caracteres" - Too short
- "Senha deve conter pelo menos um numero" - Missing number
- "Senha deve conter pelo menos uma letra minuscula" - Missing lowercase

### Confirmation Errors
- "Confirme a senha" - Empty confirmation field
- "Senhas nao conferem" - Passwords don't match

### Auth Errors
- "Erro ao cadastrar: [error details]" - Signup failed
- "Email ou senha incorretos. Tente novamente." - Login failed
- "Erro ao sair: [error details]" - Logout failed

## Testing

### Test Case 1: Invalid Email
1. Enter: "notanemail"
2. Expected: "Email invalido" error shown
3. Button: Disabled

### Test Case 2: Short Password
1. Enter email: "test@email.com"
2. Enter password: "abc"
3. Expected: "Minimo 6 caracteres" error
4. Button: Disabled

### Test Case 3: Password Without Number
1. Enter password: "abcdef"
2. Expected: "Deve ter um numero" error

### Test Case 4: Password Without Lowercase
1. Enter password: "ABCD1234"
2. Expected: "Deve ter letra minuscula" error

### Test Case 5: Valid Signup
1. Email: "user@example.com"
2. Password: "Password123"
3. Confirm: "Password123"
4. Expected: All fields valid, button enabled

### Test Case 6: Password Mismatch
1. Password: "Password123"
2. Confirm: "Password456"
3. Expected: "Senhas nao conferem" error

## Security Best Practices

1. **Passwords are hashed by Supabase**: Never stored in plain text
2. **Validation happens on both sides**: Client-side (UX) and server-side (security)
3. **Error messages are user-friendly**: Don't expose sensitive info
4. **No password logging**: Errors don't include password values

## Future Enhancements

1. Add uppercase letter requirement
2. Add special character requirement
3. Add password strength meter
4. Add "Forgot Password" flow
5. Add email verification
6. Add Two-Factor Authentication (2FA)
7. Add rate limiting on login attempts
8. Add CAPTCHA for security

## Troubleshooting

### Issue: "Email invalido" for valid emails
**Solution**: The regex might not match your email format. Test at: https://regex101.com/

### Issue: Button stays disabled
**Solution**: Check that all validation methods return null (no error)

### Issue: Validation not working
**Solution**: Make sure you're using the latest AuthProvider with validation methods

## References

- Flutter Forms: https://flutter.dev/docs/cookbook/forms
- Provider Package: https://pub.dev/packages/provider
- Supabase Flutter: https://supabase.com/docs/reference/flutter/auth
- Email Regex: https://regex101.com/
