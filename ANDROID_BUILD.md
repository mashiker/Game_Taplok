# PlayTap Android Build Configuration

## Export Preset Location
The Android export preset is configured in `export_presets.cfg`.

## Configuration Summary

### Basic Settings
- **Platform**: Android
- **Minimum SDK**: API 26 (Android 8.0+)
- **Package Name**: `com.playtap.game`
- **Application Name**: PlayTap

### Build Settings
- **Architecture**: arm64-v88a (primary)
- **Binary Format**: Gradle
- **Strip Binaries**: Enabled (for smaller APK size)
- **Debug Format**: LTO (Link Time Optimization)

### Display Settings
- **Viewport**: 540x960 (portrait mode)
- **Stretch Mode**: Canvas Items
- **Window Mode**: Fullscreen

### Graphics Settings
- **Rendering Method**: Forward Plus
- **Driver**: Vulkan (default), GLES2 (mobile fallback)
- **2D Texture Compression**: VRAM Compression enabled
- **3D Texture Compression**: VRAM Compression enabled

### Audio Settings
- **Bus Layout**: `default_bus_layout.tres`
- **Audio Format**: OGG Vorbis (all audio files)

### Permissions
- **WRITE_EXTERNAL_STORAGE**: Enabled (for gallery functionality)
- **READ_EXTERNAL_STORAGE**: Disabled (not needed)

### Export Settings
- **Export Path**: `./release/android/PlayTap.apk`
- **Export Filter**: All Resources

## Release Build Instructions

### 1. Generate Release Keystore
```bash
# Using keytool (JDK)
keytool -genkey -v -keystore playtap-release.keystore \
  -alias playtap \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass YOUR_STRONG_PASSWORD \
  -keypass YOUR_STRONG_PASSWORD
```

### 2. Configure Export Preset in Godot Editor
1. Open Project → Export → Android (Preset.0)
2. Enable "Export With Debug" (for testing) or disable for release
3. Set Keystore path to the generated keystore file
4. Set Keystore password
5. Set Key Alias: `playtap`
6. Set Key Password

### 3. Export Options
- **Export Format**: AAB (Android App Bundle) recommended for Play Store
- **Or export APK** for direct installation

### 4. Export Build
In Godot Editor: Project → Export → Android → Export Project

## Verification Checklist
- [ ] App installs successfully on Android 8.0+ device
- [ ] All game scenes load without errors
- [ ] Audio plays correctly (SFX, music, voice)
- [ ] Touch input works correctly
- [ ] Database operations work (if gdsqlite installed)
- [ ] Paintings save correctly to gallery
- [ ] Parent dashboard accessible via PIN
- [ ] APK size < 50MB (lite version target)

## Optimizations Already Applied
- VRAM compression on textures
- LTO enabled for release builds
- Binaries stripped
- Only essential permissions requested
- Audio files in OGG Vorbis format (compressed)

## Troubleshooting

### APK Size Too Large
- Check texture import settings
- Ensure audio files are compressed
- Enable strip binaries
- Check for unused assets

### Touch Not Working
- Ensure buttons have minimum size 120x120px
- Check collision layers and input settings
- Verify InputEventMouseButton is connected

### Audio Not Playing
- Verify bus layout matches default_bus_layout.tres
- Check AudioManager volume settings
- Ensure audio files are OGG format
- Check if audio files exist in assets/sounds/

## Godot 4.2 Export Notes
- Android export requires Godot 4.2+ Android export templates
- Tested with Android 8.0 (API 26) through Android 14
- Requires Android Build Tools installed
- Gradle wrapper included in export
