# PlayTap: Development Specification Documents
## Ralph-Format Structured Technical Documentation

---

# 1. PRD.JSON (User Stories & Tasks)

```json
{
  "projectName": "PlayTap - Game Edukasi Balita Indonesia",
  "version": "1.0",
  "branchName": "playtap-mvp-v1",
  "description": "Aplikasi game edukasi untuk anak balita usia 2-5 tahun dengan konten 100% Bahasa Indonesia dan budaya lokal",
  
  "userStories": [
    {
      "id": "US-001",
      "title": "Tap Pop Gameplay Core - Baloons",
      "description": "Implementasi core gameplay Tap Pop dengan spawn balon warna-warni, tap detection, dan audio feedback",
      "priority": "P0",
      "storyPoints": 8,
      "acceptanceCriteria": [
        "Baloon spawn di posisi random dalam safe zone",
        "3 balloons visible simultaneously",
        "Tap detection dengan CircleShape2D radius 40px",
        "Pop animation (scale 0 to 1 over 200ms) + particle burst",
        "Audio callout nama warna/buah dalam Bahasa Indonesia",
        "Haptic feedback (vibrate 50ms on success tap)",
        "Session track: tap count, success rate, duration",
        "No timer, no failure state"
      ],
      "passes": false,
      "status": "todo",
      "blockedBy": [],
      "dependencies": ["ARCH-001"]
    },
    
    {
      "id": "US-002",
      "title": "Drag Match Gameplay - Shape Matching",
      "description": "Shape drag-to-slot matching dengan feedback visual dan audio",
      "priority": "P0",
      "storyPoints": 8,
      "acceptanceCriteria": [
        "2-4 shape pairs displayed (Circle, Square, Triangle, Star, Heart)",
        "Drag detection on InputEvent.MOUSE_MOTION",
        "Drop zone detection dengan Area2D overlap",
        "Correct match: play success SFX + word callout + animate + character dance",
        "Wrong drop: gentle bounce back, no penalty sound",
        "No timer pressure",
        "Age-based difficulty progression (2shapes→3shapes→4shapes)"
      ],
      "passes": false,
      "status": "todo",
      "blockedBy": [],
      "dependencies": ["ARCH-001"]
    },
    
    {
      "id": "US-003",
      "title": "Memory Flip Gameplay - 4 Card Version",
      "description": "Simple 2x2 memory game dengan flip animation dan match logic",
      "priority": "P0",
      "storyPoints": 6,
      "acceptanceCriteria": [
        "2x2 card grid (4 cards, 2 pairs)",
        "Flip animation: rotate Y 180° over 0.3s",
        "Correct match: glow effect + success SFX + word callout",
        "Incorrect match: gentle bounce + flip back",
        "Win condition: all pairs matched",
        "No timer, no score display to child"
      ],
      "passes": false,
      "status": "todo",
      "blockedBy": [],
      "dependencies": ["ARCH-001"]
    },
    
    {
      "id": "US-004",
      "title": "Piano Hewan Exploration",
      "description": "Interactive piano dengan 5 tombol, setiap tombol play suara hewan nusantara",
      "priority": "P0",
      "storyPoints": 5,
      "acceptanceCriteria": [
        "5 piano keys (white keys, no black keys)",
        "Key mapping: Komodo, Orangutan, Burung, Ikan, Belalang",
        "Press = play sound once, Hold = loop sound (max 3s)",
        "Haptic feedback on press/release",
        "Polyphonic audio (max 3 simultaneous sounds)",
        "Key visual highlight on press",
        "No time limit, pure exploration",
        "Wayang character dances to rhythm"
      ],
      "passes": false,
      "status": "todo",
      "blockedBy": [],
      "dependencies": ["ARCH-001", "AUDIO-001"]
    },
    
    {
      "id": "US-005",
      "title": "Finger Paint Canvas",
      "description": "Freeform drawing dengan 8 warna pilihan, save functionality",
      "priority": "P1",
      "storyPoints": 7,
      "acceptanceCriteria": [
        "800x600 canvas, white/gradient background",
        "Brush size: 20px diameter (adjustable small/medium/large)",
        "8 color palette selector at bottom",
        "Draw on InputEvent.MOUSE_MOTION + button pressed",
        "Line anti-aliasing, smooth rendering at 30FPS",
        "Clear All button dengan gentle confirmation dialog",
        "Save button exports PNG ke /data/paintings/",
        "Max 500 strokes (memory management)",
        "Haptic feedback during draw"
      ],
      "passes": false,
      "status": "todo",
      "blockedBy": [],
      "dependencies": ["ARCH-001"]
    },
    
    {
      "id": "US-006",
      "title": "Shape Silhouette Match Puzzle",
      "description": "Match shadow hewan/rumah adat ke bentuk cocok (puzzle learning)",
      "priority": "P1",
      "storyPoints": 6,
      "acceptanceCriteria": [
        "Large silhouette placeholder di center",
        "3-4 draggable shape options",
        "Drag to match silhouette",
        "Correct match: fill color + success SFX + character reaction",
        "Wrong shape: bounce back, no penalty",
        "Content rotation: Rumah Adat → Hewan → Mix",
        "5-7 puzzles per session"
      ],
      "passes": false,
      "status": "todo",
      "blockedBy": [],
      "dependencies": ["ARCH-001"]
    },
    
    {
      "id": "US-007",
      "title": "Coloring Book - Template Guided",
      "description": "Pre-drawn template (batik, hewan, bunga) dengan flood-fill coloring",
      "priority": "P1",
      "storyPoints": 8,
      "acceptanceCriteria": [
        "Load SVG/PNG templates (batik, hewan lokal, bunga)",
        "Tap region = flood fill dengan current color",
        "8 color palette + undo (max 20 undo stack)",
        "Save completed coloring as PNG",
        "Zoom/pan optional (mobile-friendly defaults)",
        "Auto-save after every color",
        "Gallery integration in parent section",
        "Print-ready export (1200x900)"
      ],
      "passes": false,
      "status": "todo",
      "blockedBy": [],
      "dependencies": ["ARCH-001"]
    },
    
    {
      "id": "US-008",
      "title": "Music Rhythm - Beat Tapping",
      "description": "Simple rhythm game dengan lagu anak Indonesia, tap sesuai beat",
      "priority": "P2",
      "storyPoints": 7,
      "acceptanceCriteria": [
        "4 beat circles arranged horizontally",
        "Lagu anak Indonesia (Twinkle Twinkle, Cicak-cicak di Dinding)",
        "Visual beat cue (circle flash on beat)",
        "Tap within ±0.3s window = correct",
        "Correct tap: bright visual + ding sound",
        "Missed beat: circle fade (no error sound)",
        "30-60s duration per song",
        "No score pressure to child (score optional)",
        "Session: 1 song = 1 session"
      ],
      "passes": false,
      "status": "todo",
      "blockedBy": [],
      "dependencies": ["ARCH-001", "AUDIO-001"]
    },
    
    {
      "id": "ARCH-001",
      "title": "Godot Project Setup & Core Architecture",
      "description": "Initialize Godot 4.2 project dengan base scene structure, signal system, data persistence",
      "priority": "P0",
      "storyPoints": 5,
      "acceptanceCriteria": [
        "Godot 4.2 LTS project initialized",
        "Scene structure: Main.tscn → Menu → GameScenes (10 mini-games)",
        "Signal system for game transitions (game_started, game_ended, reward_trigger)",
        "SQLite database connection via GDScript",
        "Session logging system (SessionManager.gd)",
        "Audio bus architecture (Background, SFX, Voice)",
        "Localization system setup (English + Bahasa Indonesia)",
        "Build optimization for Android (30MB target)"
      ],
      "passes": false,
      "status": "todo",
      "blockedBy": [],
      "dependencies": []
    },
    
    {
      "id": "AUDIO-001",
      "title": "Audio Asset Generation & Integration",
      "description": "Generate/record all audio files: SFX, music, voice callouts dalam Bahasa Indonesia",
      "priority": "P0",
      "storyPoints": 5,
      "acceptanceCriteria": [
        "Record native Indonesian voice talent (100+ words: warna, buah, hewan, angka)",
        "Generate SFX library: pop, success, wrong, tap, ui_transitions",
        "Lagu anak background tracks (3 songs minimum)",
        "Piano/hewan sounds (5 animals, clear recording)",
        "Format: OGG Vorbis 48kHz mono, <30KB per file",
        "Audio mixing: -6dB peak, no clipping",
        "Store in /assets/sounds/ organized by category",
        "Godot audio bus routing configured"
      ],
      "passes": false,
      "status": "todo",
      "blockedBy": [],
      "dependencies": []
    },
    
    {
      "id": "UI-001",
      "title": "Main Menu & Game Selection Screen",
      "description": "Interactive menu dengan 10 game icons, character mascot, parent button",
      "priority": "P0",
      "storyPoints": 5,
      "acceptanceCriteria": [
        "PlayTap logo (120x60px) at top",
        "Wayang mascot character (120x120px, reactive)",
        "Grid layout: 10 game icons (2 cols, 5 rows, 120x120px each)",
        "Game name labels below icons",
        "Lock visual for games not unlocked (age-gated)",
        "Parent Settings button (gear icon, PIN protected)",
        "Tap Count badge showing today's plays",
        "Back button support (Android nav)",
        "Smooth transitions, no loading delays"
      ],
      "passes": false,
      "status": "todo",
      "blockedBy": ["ARCH-001"],
      "dependencies": ["ARCH-001"]
    },
    
    {
      "id": "PARENT-001",
      "title": "Parental Dashboard - Stats & Settings",
      "description": "PIN-protected parent control panel dengan playtime tracking, gallery, settings",
      "priority": "P1",
      "storyPoints": 8,
      "acceptanceCriteria": [
        "4-digit PIN login (default 1234)",
        "Child profile: age slider (2-5), name, content preferences",
        "7-day playtime chart (bar graph, hours)",
        "Game list dengan play count",
        "Notification settings (3+ hours warning)",
        "Gallery: all paintings/colorings with download",
        "Settings: Language, Audio volume, Subtitles, Screen timeout, App size (lite/full)",
        "Privacy policy & terms display",
        "Cloud sync toggle (future feature)"
      ],
      "passes": false,
      "status": "todo",
      "blockedBy": ["ARCH-001"],
      "dependencies": ["ARCH-001", "UI-001"]
    },
    
    {
      "id": "PERSIST-001",
      "title": "Session Data Persistence & Gallery",
      "description": "SQLite database untuk session logging, painting storage, progress tracking",
      "priority": "P1",
      "storyPoints": 6,
      "acceptanceCriteria": [
        "SQLite DB schema: sessions, paintings, game_progress",
        "Session logging: game_type, duration, timestamp, metrics",
        "Painting storage: PNG export to /data/paintings/, metadata (date, game_type)",
        "Max 100 sessions stored (auto-delete oldest)",
        "Offline-first: all data stored locally",
        "Cloud sync when wifi available (parent opt-in, future feature)",
        "Parent dashboard reads from DB",
        "No PII stored (zero child identifier)"
      ],
      "passes": false,
      "status": "todo",
      "blockedBy": ["ARCH-001"],
      "dependencies": ["ARCH-001", "PARENT-001"]
    },
    
    {
      "id": "TEST-001",
      "title": "QA Testing - Android Devices",
      "description": "Testing pada 5 Android devices (2GB to 6GB RAM), crash reporting, performance",
      "priority": "P0",
      "storyPoints": 5,
      "acceptanceCriteria": [
        "Test on Samsung A10 (2GB RAM, SD 439) - baseline low-end",
        "Test on Samsung A50 (4GB RAM, SD 665) - mid-range",
        "Test on Samsung S21 (6GB+ RAM, SD 888) - high-end",
        "All 10 games playable without crashes",
        "Tap latency <100ms (perceived responsiveness)",
        "No ANR (Application Not Responding) errors",
        "Memory usage <150MB during gameplay",
        "FPS stable at 30FPS",
        "Audio sync (no lag between visual + sound)",
        "Generate crash report for any failures"
      ],
      "passes": false,
      "status": "todo",
      "blockedBy": ["US-001", "US-002", "US-003", "US-004", "US-005", "US-006", "US-007", "US-008"],
      "dependencies": ["ARCH-001", "AUDIO-001"]
    },
    
    {
      "id": "GDPR-001",
      "title": "Privacy & Compliance Setup",
      "description": "Google Play Families Program certification, privacy policy, GDPR compliance",
      "priority": "P0",
      "storyPoints": 4,
      "acceptanceCriteria": [
        "Privacy policy drafted (no child PII collection)",
        "Terms of service reviewed by lawyer",
        "Google Play Family Program questionnaire completed",
        "Ads network configured (AdMob family-safe filters only)",
        "No behavioral targeting enabled",
        "Data retention policy: 90 days max",
        "Parental consent workflow for any future data features",
        "GDPR clause: right to deletion, data access",
        "Indonesian privacy law compliance check"
      ],
      "passes": false,
      "status": "todo",
      "blockedBy": [],
      "dependencies": []
    },
    
    {
      "id": "RELEASE-001",
      "title": "Google Play Store Submission & Launch",
      "description": "App submission, store listing optimization, marketing assets",
      "priority": "P0",
      "storyPoints": 3,
      "acceptanceCriteria": [
        "APK build signed with release certificate",
        "Store listing: icon, screenshots (5), description, keywords",
        "ASO keywords: game balita, edukasi anak, game anak Indonesia",
        "App size verified <50MB (lite)",
        "Testing link shared with beta testers",
        "Release notes translated to Bahasa Indonesia",
        "Media/press kit prepared",
        "Influencer outreach list compiled",
        "Launch date scheduled + countdown"
      ],
      "passes": false,
      "status": "todo",
      "blockedBy": ["TEST-001", "GDPR-001"],
      "dependencies": ["TEST-001", "GDPR-001", "PARENT-001", "PERSIST-001"]
    }
  ],
  
  "completionPercentage": 0,
  "estimatedHours": 320,
  "teamSize": 1,
  "timeline": "8 weeks (MVP Phase 1)"
}
```

---

# 2. AGENTS.MD (Development Guidelines)

```markdown
# PlayTap Development Agents Guide

## Project Context
- **Codename:** PlayTap (Taplok)
- **Engine:** Godot 4.2 LTS (GDScript)
- **Target:** Android 8.0+
- **Scope:** MVP = 10 mini-games for balita 2-5 years

## Key Conventions

### Naming Conventions
- **Scene files:** PascalCase (e.g., TapPopGame.tscn, MainMenu.tscn)
- **Scripts:** snake_case (e.g., tap_pop_game.gd, session_manager.gd)
- **Signals:** snake_case, suffix with _triggered or _updated (e.g., game_started_triggered)
- **Variables:** snake_case, prefix type hint (e.g., player_name: String, spawn_rate: float)
- **Audio files:** lowercase_underscore (e.g., pop_success.ogg, komodo_growl.ogg)

### Scene Structure
```
Main.tscn (Root)
├── MenuScene.tscn
│   ├── Header (Logo, Mascot)
│   ├── GameGrid (10 game buttons)
│   └── BottomBar (Parent button, Settings)
├── GameScene_{GameName}.tscn (Per mini-game)
├── ParentDashboard.tscn (PIN-protected)
└── UI_Components/ (Reusable)
    ├── ColorPalette.tscn
    ├── RewardPopup.tscn
    └── LoadingScreen.tscn
```

### Audio Architecture
```
AudioServer Bus Hierarchy:
- Master (0dB)
  ├── Background (-8dB)
  │   └── (Menu music, gameplay ambience)
  ├── SFX (-3dB)
  │   ├── UI (button clicks, transitions)
  │   ├── Gameplay (pop, success, wrong)
  │   └── Character (dance, reaction sounds)
  └── Voice (-4dB)
      ├── Words (warna, buah, hewan, angka)
      └── Praise ("Hebat!", "Bagus!", "Pintar!")
```

### Localization (i18n) Strategy
- **Files:** /assets/locales/{language}.json
- **Supported languages:** id, en (future)
- **Usage:** Call TranslationManager.get_text("key") in all UI nodes
- **Key naming:** snake_case_descriptive (e.g., "game_tap_pop_name", "parent_settings_title")
- **Audio:** Separate OGG files per language (no text-to-speech for quality)

### Database Schema (SQLite)
```sql
-- Sessions table
CREATE TABLE sessions (
  id INTEGER PRIMARY KEY,
  game_type TEXT,
  start_time TIMESTAMP,
  duration_seconds INTEGER,
  tap_count INTEGER,
  content_category TEXT,
  metrics TEXT  -- JSON blob for extra data
);

-- Paintings table
CREATE TABLE paintings (
  id INTEGER PRIMARY KEY,
  game_source TEXT,  -- FingerPaint, Coloring, etc.
  filepath TEXT,
  created_at TIMESTAMP,
  size_bytes INTEGER
);

-- Game progress (optional future)
CREATE TABLE game_progress (
  game_name TEXT PRIMARY KEY,
  times_played INTEGER,
  last_played TIMESTAMP,
  child_age INTEGER
);
```

### Performance Checklist

**Per Mini-Game:**
- [ ] FPS stable 30+ on Samsung A10 (2GB)
- [ ] Load time <3 seconds
- [ ] Memory footprint <50MB (including assets)
- [ ] No memory leaks (test with 20 sessions)
- [ ] Audio latency <50ms
- [ ] Touch latency <100ms

**Godot Optimization Tips:**
- Use `instancing` for repeated elements (balloons, cards)
- Preload audio in _ready(), don't load on-demand
- Use `VisibleOnScreenNotifier` to cull off-screen particles
- Compress textures: Enable VRAM compression in import settings
- Use Object pooling for particles/SFX instances

### Testing Strategy

**Unit Tests:**
- Session logging correctness (SessionManager.gd)
- Data persistence (SQLite reads/writes)
- Localization string keys (no missing translations)

**Integration Tests:**
- Game scene loads without errors
- Audio plays on correct bus, no clipping
- Parent dashboard displays correct stats
- Age-gating works (2yo vs 4yo sees different content)

**Manual QA Checklist (Before Release):**
- [ ] Play each game for 5 minutes
- [ ] Check for crashes (adb logcat | grep -i crash)
- [ ] Verify audio levels (not too loud, clear)
- [ ] Test on 2GB device (lag/freeze assessment)
- [ ] Check battery drain (30min play = <5% drain)
- [ ] Verify parent PIN lock works
- [ ] Test save/load paintings
- [ ] Confirm offline mode fully works
- [ ] Check GDPR privacy text displayed correctly

### Common Gotchas

1. **Audio Bus Not Persisting:**
   - Don't set bus in editor; set in code at runtime
   - Example: `audio_stream_player.bus = "SFX"`

2. **Godot 4.2 InputEvent Changes:**
   - Use `InputEvent.is_pressed()` not `.pressed` (deprecated)
   - Mouse clicks: Check `event is InputEventMouseButton` then `event.button_index == MOUSE_BUTTON_LEFT`

3. **Android Touch Multitouch:**
   - By default, multitouch disabled
   - Enable if needed: `Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)`
   - Handle with `InputEvent.get_action_strength()`

4. **Localization File Reloading:**
   - Changes to JSON don't auto-reload in editor
   - Restart game or manually call `TranslationManager.reload()`

5. **SQLite on Android:**
   - Database file location: `user://` (automatically mapped to app data dir)
   - Ensure write permissions in AndroidManifest.xml
   - Backup user:// files if needed (parental dashboard feature)

## Deployment Checklist

**Before Play Store Submission:**
- [ ] All user stories marked "passes: true"
- [ ] Crashes <0.1% in manual testing
- [ ] Rating 4.5+/5 in closed beta (20+ testers)
- [ ] App icon finalized (512x512 PNG)
- [ ] Screenshots in Indonesian + English (5 screenshots min)
- [ ] Store description SEO-optimized
- [ ] Privacy policy link valid
- [ ] Ads network approved (AdMob review pending)
- [ ] Build signed (APK/AAB with release certificate)
- [ ] Version code bumped (1 for first release)
- [ ] Strings marked as translatable (for future i18n)

## Continuous Improvement

**Post-Launch Monitoring:**
- Track crashes via Firebase Crashlytics (optional)
- Monitor Play Store rating trends
- Gather user feedback (comments, support emails)
- Monthly content updates (new cosmetics, 2-3 games)
- Respond to negative reviews (bug fixes, feature requests)
```

---

# 3. PRODUCT BACKLOG (Prioritized Tasks)

## MVP - Phase 1 (Weeks 1-8)

### Week 1-2: Foundation
- [ ] **ARCH-001:** Godot project setup (Base scenes, signals, structure)
- [ ] **AUDIO-001:** Audio asset generation (Voice recording, SFX synthesis)
- [ ] Localization system setup (JSON files for id/en)

### Week 3-4: Core Gameplay #1
- [ ] **US-001:** Tap Pop gameplay (all 3 content categories)
- [ ] **US-002:** Drag Match gameplay (4 variants)
- [ ] **US-003:** Memory Flip (4-card version)

### Week 5: Core Gameplay #2
- [ ] **US-004:** Piano Hewan (5 animals, polyphonic audio)
- [ ] **US-005:** Finger Paint (canvas, colors, save)
- [ ] **US-006:** Shape Match silhouette puzzle

### Week 6: Advanced Gameplay
- [ ] **US-007:** Coloring Book templates (batik, hewan, bunga)
- [ ] **US-008:** Music Rhythm beat tapping (3 songs)

### Week 7: UI & Parent Features
- [ ] **UI-001:** Main Menu (10 game grid, smooth transitions)
- [ ] **PARENT-001:** Parental Dashboard (stats, settings, gallery)
- [ ] **PERSIST-001:** SQLite persistence layer

### Week 8: QA & Release
- [ ] **TEST-001:** Android device testing (5 devices, all games)
- [ ] **GDPR-001:** Privacy compliance setup
- [ ] **RELEASE-001:** Play Store submission prep

---

## Post-MVP - Phase 2 (Weeks 9-12)

- [ ] Memory Flip 6-card version (age 4+)
- [ ] Tap Pop difficulty progression (transparent to user)
- [ ] Gallery improvements (sharing, print prep)
- [ ] Bug fixes based on beta feedback
- [ ] Performance optimization (if needed)

---

## Phase 3 (Month 4-6): Expansion

- [ ] 5 new mini-games (puzzle, sorting, matching variants)
- [ ] Cosmetics shop (character skins, background themes)
- [ ] Seasonal events (Lebaran, Tahun Baru)
- [ ] Subscription tier (ad-free + premium games)
- [ ] iOS release (build on top of Android MVP)

---

## Estimated Effort

| Component | Hours | Role |
|-----------|-------|------|
| Architecture & Setup | 40 | Dev |
| Audio (generation, recording) | 30 | Audio engineer + Dev |
| Core Gameplay (8 games × 15h avg) | 120 | Dev |
| UI & Menu | 40 | UI/Dev |
| Parent Dashboard | 35 | Dev |
| Data Persistence | 20 | Dev |
| QA & Testing | 25 | QA |
| **Total MVP** | **310 hours** | 1-2 devs |

---

## Resource Requirements

**Team Composition (MVP):**
- 1x Full-stack Developer (Godot, GDScript, UI)
- 1x Audio Engineer / Voice Talent (recording, mixing)
- 1x QA Tester (optional, can be done by dev)
- 1x Product Manager (you, oversight)

**Tools & Services:**
- Godot 4.2 LTS (free)
- GitHub (free)
- Android Studio SDK (free)
- Google Play Console ($25 one-time)
- Firebase Analytics (optional, free tier)
- Figma for UI mockups (free tier)
- Audacity for audio editing (free)

---

## Success Criteria (MVP Launch)

✅ **Functional:**
- All 8 core mini-games playable, zero crashes
- Parent dashboard tracking works
- Offline mode fully functional
- Audio clear, gameplay responsive

✅ **Quality:**
- Plays smoothly on 2GB Android devices
- Rating 4.5+ from beta testers
- Privacy compliant (GDPR + Google Play Families)

✅ **Market:**
- 1K+ downloads in first week
- 10K+ downloads by month 1
- <3% uninstall rate

```

---

# 4. DEVELOPMENT PROMPTS FOR CLAUDE CODE

### Prompt 1: Tap Pop Game Implementation
```
Create a GDScript implementation of Tap Pop game for Godot 4.2.

Specifications:
- Scene: TapPopGame.tscn with Node2D root
- 3 balloons visible simultaneously
- Random spawn within safe zone (200px margins)
- Touch detection: CircleShape2D radius 40px
- Pop animation: Scale 0 → 1 over 0.2s, particle burst 8 particles
- Audio: Success sound + word callout (color/fruit/animal name)
- Session tracking: tap_count, success_rate, duration
- Age-gating: ages 2-3 show 2 balloons + simple colors, ages 4-5 show 3 balloons
- Haptic feedback: os.vibrate_msec(50) on successful tap
- Exit condition: 60 taps OR 10 minutes

Localization:
- Color names in Bahasa Indonesia
- Audio callouts from /assets/sounds/words/{lang}/{category}_{item}.ogg

Return GDScript code with proper structure, signal emissions, and performance optimizations.
```

### Prompt 2: Audio Bus & Audio Stream Player Setup
```
Set up Godot 4.2 audio architecture for PlayTap.

Audio Bus Hierarchy:
- Master (0dB)
  ├── Background (-8dB)
  ├── SFX (-3dB)
  ├── UI (-3dB)
  └── Voice (-4dB)

Create:
1. AudioManager.gd singleton (autoload)
2. Functions: play_sfx(path), play_voice(word), set_music_volume(level), get_bus(name)
3. Music player for background (loop-able, fade-in/out)
4. SFX player pool (max 4 simultaneous SFX instances)
5. Voice player (priority over SFX if overlap)

Ensure low-end device compatibility (30MB app size limit).
```

### Prompt 3: Parent Dashboard UI Implementation
```
Build Parental Dashboard UI (Control node) with:

Sections:
1. Child Profile (age slider, name input)
2. 7-day playtime chart (BarChart: hours per day)
3. Game list (ItemList: game name + play count)
4. Gallery (GridContainer: thumbnail paintings)
5. Settings (tabs: Language, Audio, Notifications, Screen timeout)

Features:
- PIN login (4-digit code, default 1234)
- Data binding to SessionManager (real-time stats)
- Export paintings (button → PNG file)
- Notification toggle for 3+ hours warning

Return complete .tscn scene + controller script.
```
