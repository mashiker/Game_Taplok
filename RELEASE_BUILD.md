# PlayTap - Release Build Guide

## Prerequisites

1. **Godot 4.2+** with Android export templates installed
2. **Java JDK** (for keytool and apksigner)
3. **Android SDK** with build tools
4. **Physical Android device** for testing

---

## Step 1: Generate Release Keystore

### Using keytool (command line)

```bash
keytool -genkey -v -keystore release/playtap-release.keystore \
  -alias playtap \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass YOUR_STRONG_PASSWORD \
  -keypass YOUR_STRONG_PASSWORD
```

### Keystore Information
- **Alias**: playtap
- **Key Size**: 2048-bit RSA
- **Validity**: 10000 days (~27 years)
- **Location**: `release/playtap-release.keystore`

### Security Notes
- **NEVER** commit the keystore to version control
- **NEVER** share the keystore password
- **BACKUP** the keystore in a secure location
- **Store password** in a secure password manager

---

## Step 2: Configure Export Preset

### In Godot Editor:
1. Open **Project → Export**
2. Select **Android** preset
3. Under **Options → Sign**:
   - **Release**: Enabled
   - **Keystore**: `res://release/playtap-release.keystore`
   - **Keystore Password**: (enter password)
   - **Key Alias**: `playtap`
   - **Key Password**: (enter password)

### In export_presets.cfg (already configured):
```ini
[preset.0.options]
application/package/signature=true
application/keystore/release="res://release/playtap-release.keystore"
application/keystore/release_password="YOUR_PASSWORD"
application/keystore/release_alias="playtap"
application/keystore/release_alias_password="YOUR_PASSWORD"
```

---

## Step 3: Update Version Information

### Current Version (project.godot):
```
config/version="1.0.0"
```

### Version Code (Android):
- **Version Code**: 1 (integer, must increment with each release)
- **Version Name**: 1.0.0 (user-facing)

### To increment version:
Edit `export_presets.cfg`:
```ini
application/version/code=1
application/version/name="1.0.0"
```

---

## Step 4: Export Release Build

### Option A: Export APK (for direct distribution)
1. **Project → Export → Android**
2. **Export Path**: `./release/android/PlayTap-1.0.0.apk`
3. Click **Export Project**

### Option B: Export AAB (for Google Play Store)
1. **Project → Export → Android**
2. **Export Path**: `./release/android/PlayTap-1.0.0.aab`
3. Click **Export Project**

### Expected File Size
- **Lite Version**: ~30-50MB
- **Full Version**: ~50-80MB

---

## Step 5: Verify Build

### Check APK Size
```bash
ls -lh release/android/PlayTap-1.0.0.apk
```

Expected: **<50MB** for lite version

### Check APK Contents
```bash
unzip -l release/android/PlayTap-1.0.0.apk | head -20
```

Verify:
- Native libraries for arm64-v8a
- Compressed textures (ETC2/ASTC)
- No debug symbols
- No unnecessary assets

---

## Step 6: Install and Test on Device

### Install via ADB
```bash
adb install -r release/android/PlayTap-1.0.0.apk
```

### Test Checklist
- [ ] App installs successfully on Android 8.0+
- [ ] All 8 games load without crashes
- [ ] Audio plays correctly (SFX, music, voice)
- [ ] Touch input works on all games
- [ ] Database operations work
- [ ] Paintings save to gallery
- [ ] Parent dashboard accessible via PIN (1234)
- [ ] Settings persist across restarts
- [ ] App performs well (no lag)
- [ ] No memory leaks after 10 minutes

### Manual Testing Steps

#### Main Menu
1. Verify all 8 game buttons are visible
2. Tap count displays correctly
3. Parent button opens PIN dialog

#### Games (Test Each)
1. **Tap Pop**: Balloons spawn and pop correctly
2. **Drag Match**: Shapes drag and snap to slots
3. **Memory Flip**: Cards flip and match
4. **Piano Hewan**: Sounds play on touch
5. **Finger Paint**: Drawing works, saves to gallery
6. **Shape Silhouette**: Shapes match silhouettes
7. **Coloring Book**: Flood fill works, undo works
8. **Music Rhythm**: Beat detection works

#### Parent Dashboard
1. Enter PIN (1234)
2. Change child profile settings
3. View statistics
4. View gallery
5. Change settings (language, audio)
6. View legal documents

---

## Step 7: Prepare for Google Play Store

### Store Listing (see `store_assets/play_store/`)
- [ ] App icon (512x512 PNG) - **TO BE CREATED**
- [ ] Feature graphic (1024x500 PNG) - **TO BE CREATED**
- [ ] 5 screenshots (480x360 or 1024x500) - **TO BE CAPTURED**
- [ ] Short description (80 chars) - ✓ DONE
- [ ] Full description (4000 chars) - ✓ DONE
- [ ] Privacy policy URL - ✓ In-app document

### Content Rating
- **ESRB**: Early Childhood (EC)
- **PEGI**: 3
- **CERO**: A

### Store Categories
- **Primary**: Education
- **Secondary**: Educational Games

### Pricing
- **Free** (no in-app purchases)

---

## Step 8: Upload to Google Play Console

### Pre-upload Checklist
- [ ] Google Play Developer account ($25 one-time fee)
- [ ] App name: "PlayTap - Game Edukasi Balita"
- [ ] Package name: `com.playtap.game`
- [ ] App signing key uploaded
- [ ] Store listing complete
- [ ] Screenshots uploaded
- [ ] Privacy policy URL set (or in-app)

### Upload Steps
1. **Create app** in Google Play Console
2. **Upload AAB** (Android App Bundle)
3. **Complete store listing**
4. **Set pricing** (Free)
5. **Submit for review**
6. **Wait for approval** (typically 1-3 days)

---

## Troubleshooting

### APK Size Too Large
- Check texture import settings (should be compressed)
- Remove unused assets
- Enable "Strip Binaries" in export preset
- Check for duplicate audio files

### Build Fails
- Verify Android export templates are installed
- Check Java JDK version (Java 11+ recommended)
- Verify keystore path and password
- Check Godot output log for errors

### App Crashes on Device
- Check minimum SDK version (API 26)
- Verify all scenes are included in export
- Check for missing autoload scripts
- Test on multiple devices if possible

### Signing Errors
- Verify keystore password is correct
- Check key alias matches
- Ensure keystore file exists and is readable

---

## Release Checklist (Final)

### Pre-Release
- [ ] All 43 user stories complete
- [ ] Code committed to main branch
- [ ] Version updated in project.godot
- [ ] Changelog/update notes written
- [ ] Legal documents reviewed
- [ ] Store assets prepared

### Build
- [ ] Keystore generated securely
- [ ] Export preset configured
- [ ] Release build (AAB/APK) exported
- [ ] File size verified <50MB
- [ ] Build tested on physical device

### Store
- [ ] Play Console app created
- [ ] Store listing complete
- [ ] Screenshots uploaded
- [ ] Privacy policy linked
- [ ] Content rating set

### Post-Release
- [ ] Monitor crash reports (Firebase Crashlytics recommended)
- [ ] Review user feedback
- [ ] Plan version 1.0.1 if needed
- [ ] Update documentation

---

## Version History

| Version | Code | Date | Notes |
|---------|------|------|-------|
| 1.0.0 | 1 | 2026-01-23 | Initial MVP release |

---

## Quick Commands

```bash
# Generate keystore
keytool -genkey -v -keystore release/playtap-release.keystore -alias playtap -keyalg RSA -keysize 2048 -validity 10000

# Install APK on connected device
adb install -r release/android/PlayTap-1.0.0.apk

# Check APK info
aapt dump badging release/android/PlayTap-1.0.0.apk

# Verify signature
jarsigner -verify -verbose -certs release/android/PlayTap-1.0.0.apk

# Logcat for debugging
adb logcat -s Godot
```

---

**Good luck with the release!** 🚀

For questions: support@playtap.id
