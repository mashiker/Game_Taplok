# PlayTap - Screenshot Reference Guide

## Screenshot Specifications

### Format Requirements
- **Phone screenshots**: 480x360 pixels (portrait or landscape)
- **Tablet screenshots**: 1024x500 pixels (landscape recommended)
- **Format**: PNG (high quality)
- **Total needed**: 5 screenshots

### Screenshot Order (For Play Store)

#### Screenshot 1: Main Menu (480x360 or 1024x500)
**Shows**: The main menu with 8 game buttons and wayang mascot
**Highlights**:
- Clean, colorful game grid
- Indonesian game names visible
- Wayang mascot character
- "Dimainkan X kali hari ini" text (tap count)
- Parent dashboard button (gear icon)

**How to capture**:
1. Run the game in Godot
2. Navigate to MainMenu scene
3. Take screenshot when all 8 games are visible
4. Ensure good contrast and vibrant colors

---

#### Screenshot 2: Tap Pop Gameplay (480x360 or 1024x500)
**Shows**: Child tapping balloons in Tap Pop game
**Highlights**:
- Colorful balloons (red, blue, yellow)
- Tap animation/particle effect
- Wayang celebrating in corner
- Clean, simple interface

**How to capture**:
1. Start Tap Pop game
2. Wait for balloons to spawn
3. Capture moment when balloon is being tapped
4. Show particle effect if possible

---

#### Screenshot 3: Piano Hewan Gameplay (480x360 or 1024x500)
**Shows**: Piano keys with animal icons
**Highlights**:
- Piano keyboard layout
- Animal names in Indonesian (Komodo, Orangutan, Burung, Paus, Belalang)
- Multiple keys pressed (multi-touch)
- Wayang mascot celebrating

**How to capture**:
1. Start Piano Hewan game
2. Press 2-3 keys simultaneously to show multi-touch
3. Ensure animal names are clearly visible

---

#### Screenshot 4: Finger Paint / Coloring (480x360 or 1024x500)
**Shows**: Child's artwork with color palette
**Highlights**:
- Colorful drawing/canvas
- 8-color palette visible
- Save button
- Creative expression showcase

**How to capture**:
1. Start Finger Paint game
2. Draw something colorful and fun
3. Capture with color palette and tools visible

---

#### Screenshot 5: Parent Dashboard (480x360 or 1024x500)
**Shows**: PIN login or statistics screen
**Highlights**:
- PIN entry screen (shows security/parent control)
- OR 7-day statistics chart
- Shows app is parent-friendly
- Indonesian labels

**How to capture**:
1. Open Parent Dashboard
2. Either: Capture PIN screen (shows 1234 default)
3. Or: Capture statistics page showing playtime chart

---

## General Screenshot Guidelines

### Visual Style
- **Bright, colorful, child-friendly**
- **High contrast** for visibility on small screens
- **Clear, readable Indonesian text**
- **No UI clutter** - hide debug elements if visible

### Do's
✓ Use actual game screenshots (no mockups if possible)
✓ Show colorful, engaging moments
✓ Ensure Indonesian text is readable
✓ Include wayang mascot where appropriate
✓ Show variety of game types

### Don'ts
✗ Don't use English-only screenshots
✗ Don't show empty/boring screens
✗ Don't include debug info or frame rate counters
✗ Don't use low-resolution screenshots

---

## Alternative Screenshot Options

If any of the above don't work, consider:

1. **Memory Flip Game**: Show card matching gameplay
2. **Music Rhythm**: Show beat circles and tap detection
3. **Drag Match**: Show shape dragging with cursor/touch indicator
4. **Shape Silhouette**: Show shape-to-silhouette matching
5. **Gallery**: Show parent dashboard gallery with artwork thumbnails

---

## Screenshot Capture in Godot

### Method 1: Using Godot Editor
1. Press F6 to run the game
2. Navigate to desired scene
3. Press F12 to take screenshot
4. Find screenshots in: `AppData/Roaming/Godot/app_userdata/PlayTap/screenshots/`

### Method 2: Using Screenshot Key
- Add screenshot functionality to a debug key (e.g., F10)
- Save to `user://screenshots/` directory
- Export from device if needed

### Method 3: From Android Device
1. Install debug APK on device
2. Navigate to scene
3. Use device screenshot (Power + Volume Down)
4. Transfer via USB or ADB: `adb shell screencap -p /sdcard/screenshot.png`

---

## Screenshot Localization

All screenshots should show **Indonesian** text:
- Game titles: Tap Pop, Drag Match, Memory Flip, etc.
- UI labels: "Kembali", "Simpan", "Hapus", etc.
- Color names: Merah, Biru, Kuning, Hijau
- Animal names: Komodo, Orangutan, Burung, Paus, Belalang

---

## Icon Specifications

### App Icon (512x512 PNG)
- **PlayTap branding** with playful, child-friendly design
- **High contrast** for visibility on various backgrounds
- **Elements to include**:
  - Balloon or game controller icon
  - Wayang silhouette hint (Indonesian culture)
  - Bright colors (red, blue, yellow, green from game palette)
  - "Play" text or playful typography

### Icon Layers (for Android Adaptive Icon)
- **Foreground**: PlayTap logo/character
- **Background**: One of the game colors (safe area: 66x66 diameter circle)
- **Design should work** on light and dark backgrounds

---

## Feature Graphic (1024x500 PNG)
**For Play Store featured listing**
- Shows multiple game scenes in collage
- "Game Edukasi Balita Indonesia" tagline
- Colorful, engaging, child-friendly
- App icon and name prominent

---

## ASO Keywords (Indonesian)

**Primary Keywords:**
- game balita
- edukasi anak
- game anak Indonesia
- belajar anak

**Secondary Keywords:**
- game edukasi
- game anak 2 tahun
- game anak 3 tahun
- game anak 4 tahun
- game anak 5 tahun
- belajar warna
- belajar bentuk
- belajar angka
- game offline
- game tanpa iklan
- game balita Indonesia
- permainan anak
- mainan edukatif

**Long-tail Keywords:**
- game edukasi anak Indonesia
- permainan balita offline
- belajar membaca anak
- game mengenal warna
- game mengenal bentuk
- piano hewan Indonesia
- game mewarnai anak
- game memori anak
