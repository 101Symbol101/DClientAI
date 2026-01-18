# Developer Module

This module is password-protected and restricted to developers only.

## Security

The password is stored as a **SHA-256 hash**, not in plain text. This means:
- ✅ The actual password is never visible in the code
- ✅ Even if someone reads the source code, they cannot see your password directly
- ✅ Prevents accidental exposure in logs, screenshots, or version control
- ✅ Only someone who knows the password can access the module

### Security Limitations

**Important**: This is **local application protection**, not military-grade security:

- ⚠️ **Hash is visible in code** - Someone with code access can see the hash
- ⚠️ **Can be brute-forced** - Weak passwords can be cracked by trying common passwords
- ⚠️ **Rainbow tables** - Common passwords can be looked up instantly
- ⚠️ **Not reversible** - SHA-256 is one-way, but attackers can try passwords until one matches

**What this protects against:**
- Casual users who don't know how to extract/use the hash
- Accidental password exposure in code reviews
- Plaintext passwords in version control

**What this DOESN'T protect against:**
- Determined attackers with code access
- Brute force attacks on weak passwords
- Rainbow table lookups for common passwords

**For stronger security**, consider:
- Using a **strong, unique password** (12+ characters, mixed case, numbers, symbols)
- Using **PBKDF2** or **Argon2** (slower, harder to brute force)
- **Code obfuscation** (makes it harder but not impossible)
- **External authentication** (Windows user account check, etc.)

## Setting Up Your Password

### Step 1: Generate a Password Hash

1. Run `GeneratePasswordHash.ahk` (double-click it)
2. Enter your desired password in the password field
3. Click "Generate Hash"
4. Click "Copy Hash to Clipboard"

### Step 2: Set the Hash in DeveloperModule.ahk

1. Open `DeveloperModule.ahk` in a text editor
2. Find the line that says:
   ```ahk
   PASSWORD_HASH := "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
   ```
3. Replace the hash value (the long string in quotes) with the hash you copied
4. Save the file

### Step 3: Test It

1. Launch the DClient Hub
2. Click the "Developer Module" button
3. Enter your password when prompted
4. If correct, you'll gain access to the developer module

## Default Password

The default password hash is for an **empty string** (no password). This means:
- If you haven't set a password yet, you can access the module by leaving the password field empty
- **Important**: Change this immediately after first use!

## How It Works

1. When you enter a password, it's hashed using SHA-256
2. The hash is compared to the stored hash in the code
3. If they match, access is granted
4. The actual password is never stored or compared directly

## Changing Your Password

To change your password:
1. Generate a new hash using `GeneratePasswordHash.ahk` with your new password
2. Replace the `PASSWORD_HASH` value in `DeveloperModule.ahk` with the new hash
3. Save the file

## Files

- **DeveloperModule.ahk** - The main developer module (password-protected)
- **GeneratePasswordHash.ahk** - Helper tool to generate password hashes
- **README.md** - This file

