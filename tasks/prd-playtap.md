# PRD: PlayTap (Taplok) - Educational Game for Indonesian Toddlers

## Introduction

PlayTap is a mobile educational game application designed specifically for Indonesian toddlers ages 2-5 years. The app addresses a critical gap in the Indonesian market: high-quality, fully localized educational content in Bahasa Indonesia with cultural elements that resonate with local families. Unlike competitors (Khan Academy Kids, Toca Boca) that focus on English content, PlayTap delivers 100% Indonesian language with local culture integration (wayang, batik, nusantara animals, traditional music).

**Problem:** Indonesian parents have limited access to quality educational apps in their native language. Existing options are either English-dominant, poorly localized, or contain predatory monetization.

**Solution:** A psychology-backed, zero-pressure educational game with 8-10 mini-games that develop cognitive and motor skills while introducing Indonesian culture.

## Goals

- Launch MVP with 8 core mini-games on Google Play Store within 8 weeks
- Achieve 10,000 downloads in the first month
- Target 4.5+ star rating from beta testers
- Ensure 100% offline functionality for all core gameplay
- Maintain app size under 50MB (lite version)
- Zero child PII collection (GDPR/Google Play Families compliant)

## User Stories

### US-001: Project Architecture Setup
**Description:** As a developer, I need a properly configured Godot 4.2 project with core architecture so that all mini-games can share common systems.

**Acceptance Criteria:**
- [ ] Godot 4.2 LTS project initialized with Android 8.0+ export preset
- [ ] Scene structure: Main.tscn → MenuScene → GameScenes (10 mini-games) → ParentDashboard
- [ ] Signal system for transitions: game_started, game_ended, reward_trigger
- [ ] SQLite database connection via GDScript
- [ ] SessionManager.gd singleton for tracking gameplay metrics
- [ ] Audio bus architecture (Master, Background, SFX, Voice) configured in project settings
- [ ] Localization system with JSON files for Bahasa Indonesia and English
- [ ] Build optimization settings enabled (texture compression, OGG audio)

### US-002: Audio Asset Production
**Description:** As a developer, I need all audio files recorded and organized so that every game has appropriate feedback in Indonesian.

**Acceptance Criteria:**
- [ ] 100+ Indonesian word recordings (colors, fruits, animals, numbers, praise)
- [ ] SFX library generated: pop, success, wrong, tap, UI transitions
- [ ] 3 Indonesian children's song backing tracks (Twinkle Twinkle, Cicak-cicak di Dinding, Lihat Lihat Penyu)
- [ ] 5 animal sounds: Komodo growl, Orangutan laugh, Burung tweet, Paus whale song, Belalang chirp
- [ ] All files in OGG Vorbis format, 48kHz mono, <30KB per file
- [ ] Organized in /assets/sounds/ by category (sfx, words, music, animals)
- [ ] Audio mixed to -6dB peak, no clipping
- [ ] Voice talent: Native Indonesian female, 18-25 years old, friendly tone

### US-003: Tap Pop Gameplay
**Description:** As a 2-year-old child, I want to tap colorful balloons and hear their names so that I can learn colors while enjoying sensory stimulation.

**Acceptance Criteria:**
- [ ] Balloons spawn at random positions within safe zone (200px margins from edges)
- [ ] Exactly 3 balloons visible simultaneously
- [ ] Touch detection using CircleShape2D with 40px radius
- [ ] Tap triggers: pop animation (scale 1→0 over 200ms), particle burst (8 particles), haptic feedback (50ms vibrate)
- [ ] Audio plays on tap: pop_success.ogg + word callout (e.g., "merah!" for red balloon)
- [ ] Balloon respawn after 1 second
- [ ] Session tracking: tap_count, success_rate, session_duration logged to SQLite
- [ ] No timer, no failure states, no score display to child
- [ ] Exit condition: 60 successful taps OR 10 minutes elapsed
- [ ] Age-gating: ages 2-3 see 2 balloons + simple colors only; ages 4-5 see 3 balloons

### US-004: Drag Match Shape Gameplay
**Description:** As a 3-year-old child, I want to drag shapes to matching slots so that I can learn geometric forms and develop hand-eye coordination.

**Acceptance Criteria:**
- [ ] 2-4 shape pairs displayed (Circle, Square, Triangle, Star, Heart)
- [ ] Drag detection on InputEvent.MOUSE_MOTION with 10px deadzone
- [ ] Visual feedback during drag: shape opacity 0.7, scale 1.1
- [ ] Drop zone detection using Area2D overlap
- [ ] Correct match triggers: success SFX, word callout ("lingkaran!"), slot highlight, character dance animation
- [ ] Incorrect drop: gentle bounce-back animation (0.3s), no penalty sound
- [ ] Snap-to-grid: matched shapes auto-center with 0.2s easing
- [ ] Session duration: 8 successful matches OR 10 minutes
- [ ] Progression: Session 1-3 has 2 shapes; Session 4-7 has 3 shapes; Session 8+ has 4 shapes (transparent to user)

### US-005: Memory Flip Gameplay
**Description:** As a 4-year-old child, I want to flip cards and find matching pairs so that I can exercise my memory.

**Acceptance Criteria:**
- [ ] 2x2 card grid (4 cards, 2 pairs) for ages 2-3
- [ ] 2x3 card grid (6 cards, 3 pairs) for ages 4+
- [ ] Card size: 60x60px, 10px spacing between cards
- [ ] Flip animation: Y-axis rotation 180° over 0.3s with EASE_IN_OUT
- [ ] Max 2 cards can be flipped simultaneously
- [ ] Match detection: compare content_id after 0.5s delay
- [ ] Correct match: glow effect, success SFX, word callout, cards marked with 0.5 opacity
- [ ] No match: gentle SFX, both cards flip back after 0.5s
- [ ] Win condition: all pairs matched → celebration SFX + "Wah hebat!" message
- [ ] Content categories: Animals (Komodo, Orangutan, Burung, Kura-kura, Kepiting), Fruits, Numbers

### US-006: Piano Hewan Exploration
**Description:** As a 2-year-old child, I want to tap piano keys and hear animal sounds so that I can explore cause-and-effect relationships.

**Acceptance Criteria:**
- [ ] 5 white piano keys (no black keys), 50-70px wide, 150px height
- [ ] Key mapping: Komodo (C4), Orangutan (D4), Burung (E4), Paus (F4), Belalang (G4)
- [ ] Tap triggers: play sound once, key highlight (30% brightness increase)
- [ ] Hold triggers: loop sound for max 3 seconds, continuous haptic vibration
- [ ] Multi-touch support: up to 3 simultaneous sounds (polyphonic)
- [ ] Animal icon above each key
- [ ] Wayang mascot character dances while sound plays
- [ ] No time limit, pure exploration mode
- [ ] Exit after 15 minutes of inactivity

### US-007: Finger Paint Canvas
**Description:** As a 3-year-old child, I want to draw freely with my finger so that I can express creativity and develop fine motor skills.

**Acceptance Criteria:**
- [ ] Canvas size: 800x600px, fills 90% of screen
- [ ] Brush: 20px diameter default, adjustable (small/medium/large)
- [ ] 8 color palette at bottom: red, blue, yellow, green, pink, orange, purple, black
- [ ] Drawing on InputEvent.MOUSE_MOTION while pressed
- [ ] Anti-aliased lines with smoothing (every 2 points averaged)
- [ ] Max 500 strokes stored in memory
- [ ] Clear All button with gentle confirmation dialog
- [ ] Save button exports PNG to /data/paintings/painting_{timestamp}.png
- [ ] "Gambar Tersimpan!" notification shows for 2 seconds after save
- [ ] Haptic feedback during draw (~20Hz subtle)
- [ ] Canvas renders at 30FPS (not 60) to reduce CPU usage

### US-008: Shape Silhouette Match
**Description:** As a 4-year-old child, I want to match animal/building shadows to their shapes so that I can learn pattern recognition.

**Acceptance Criteria:**
- [ ] Large silhouette placeholder (100x100px) at center screen
- [ ] 3-4 draggable shape options at bottom (60x60px each)
- [ ] Drag-and-drop detection: shape position overlaps placeholder
- [ ] Correct match: shape animates into silhouette (0.5s slide + scale), color fills (0.3s fade), success SFX plays
- [ ] Incorrect match: shape bounces back to original position, gentle SFX only
- [ ] Content rotation: Rumah Adat (sessions 1-2), Hewan Nusantara (sessions 3-4), Mix (sessions 5+)
- [ ] 5-7 puzzles per session, 5-10 minutes total duration
- [ ] Character (Wayang) celebrates on each correct match

### US-009: Coloring Book Templates
**Description:** As a 4-year-old child, I want to color pre-drawn templates so that I can learn about Indonesian culture.

**Acceptance Criteria:**
- [ ] Load SVG/PNG templates (batik patterns, local animals, flowers, rumah adat)
- [ ] Tap on region triggers flood-fill with current color
- [ ] 8 color palette (same as Finger Paint)
- [ ] Allow recoloring: tap + hold on colored region opens palette
- [ ] Undo button with max 20 undo stack
- [ ] Auto-save after every color change
- [ ] Export completed coloring as PNG to gallery
- [ ] Templates: 5 at launch, rotating monthly
- [ ] Age-based complexity: 2-3yo = 2-3 large regions; 3-4yo = 5-8 medium; 4-5yo = 10-15 small (batik-style)

### US-010: Music Rhythm Beat Tapping
**Description:** As a 4-year-old child, I want to tap along with Indonesian children's songs so that I can learn rhythm and beat.

**Acceptance Criteria:**
- [ ] 4 beat circles arranged horizontally at screen center
- [ ] Song plays for 30-60 seconds
- [ ] Visual cue: circle flashes on beat (1 second intervals)
- [ ] Tap within ±0.3s of beat = correct (generous window)
- [ ] Correct tap: circle brightens/shrinks, particle effect, ding sound
- [ ] Missed beat: circle fades (no error sound, no penalty)
- [ ] Songs: Twinkle Twinkle (Indonesian lyrics), Cicak-cicak di Dinding, Lihat Lihat Penyu
- [ ] At song end: friendly score display ("Kamu dapat 15/20 beat!") with celebration
- [ ] Replay or move to different activity option

### US-011: Main Menu & Game Selection
**Description:** As a child, I want a colorful menu to choose games so that I can play independently.

**Acceptance Criteria:**
- [ ] PlayTap logo (120x60px) at top
- [ ] Wayang mascot character (120x120px) reacts to user interaction (happy/excited animations)
- [ ] Grid layout: 10 game icons (2 columns × 5 rows), each 120x120px
- [ ] Game name label below each icon
- [ ] Lock icon overlay for age-gated content
- [ ] Tap Count badge showing today's total plays
- [ ] Parent Settings button (gear icon) at bottom-right
- [ ] Smooth scene transitions with fade animation (<1s)
- [ ] Back button support (Android navigation)

### US-012: Parental Dashboard
**Description:** As a parent, I want a PIN-protected dashboard so that I can monitor my child's playtime and manage settings.

**Acceptance Criteria:**
- [ ] 4-digit PIN login (default: 1234, changeable)
- [ ] Child Profile section: age slider (2-5 years), name input, content preferences toggles
- [ ] 7-day playtime chart: bar graph showing hours per day
- [ ] Game list: each game with play count
- [ ] Notification toggle for 3+ hours daily play warning
- [ ] Gallery section: thumbnails of all paintings/colorings with download button
- [ ] Settings tab: Language (id/en), Audio volume sliders, Subtitles toggle, Screen timeout, App size (lite/full 30MB/60MB)
- [ ] Privacy policy and Terms of Service links
- [ ] Cloud sync toggle (placeholder for future feature)

### US-013: Session Data Persistence
**Description:** As a parent, I want my child's progress and artworks saved locally so that they persist between sessions.

**Acceptance Criteria:**
- [ ] SQLite database with schema: sessions (id, game_type, start_time, duration, metrics), paintings (id, source, filepath, created_at), game_progress
- [ ] Session logging on every game end: game_type, duration_seconds, tap_count, content_category
- [ ] Auto-delete oldest session when limit reached (100 sessions max)
- [ ] All data stored in user:// directory (no external dependencies)
- [ ] Parent dashboard reads real-time stats from database
- [ ] No PII stored (child name optional, no location/device IDs)
- [ ] Gallery PNGs stored in user://paintings/ with metadata

### US-014: Android Build & Optimization
**Description:** As a developer, I need to build and optimize the APK for various Android devices so that the app runs smoothly on low-end hardware.

**Acceptance Criteria:**
- [ ] Target API 26 (Android 8.0) minimum
- [ ] App size <50MB for lite version
- [ ] Texture compression enabled (VRAM compression)
- [ ] Audio preloading in _ready() (no load-time hitches)
- [ ] Object pooling for balloon/card instances
- [ ] FPS capped at 30 (not 60) to reduce battery drain
- [ ] VisibleOnScreenNotifier for particle culling
- [ ] Memory usage <150MB during gameplay (test with profiler)
- [ ] Tap latency <100ms perceived responsiveness

### US-015: Quality Assurance Testing
**Description:** As a QA tester, I need to verify the app works across different Android devices so that users have a stable experience.

**Acceptance Criteria:**
- [ ] Test on Samsung A10 (2GB RAM, SD 439) - baseline low-end
- [ ] Test on Samsung A50 (4GB RAM, SD 665) - mid-range
- [ ] Test on Samsung S21 (6GB+ RAM, SD 888) - high-end
- [ ] All 8 games playable for 5 minutes without crashes
- [ ] No ANR (Application Not Responding) errors in logcat
- [ ] Audio sync verified (no lag between visual + sound)
- [ ] Battery drain test: <5% after 30 minutes play
- [ ] Offline mode verified: airplane mode, all games functional
- [ ] Crash report generated for any failures found

### US-016: Privacy & Compliance
**Description:** As a parent, I want assurance that my child's data is protected so that I can trust the app.

**Acceptance Criteria:**
- [ ] Privacy policy drafted: states zero child PII collection
- [ ] Terms of Service reviewed for Indonesian GDPR compliance
- [ ] Google Play Families Program questionnaire completed
- [ ] AdMob configured with family-safe filters only
- [ ] Behavioral targeting disabled in ad settings
- [ ] Data retention policy: 90 days max for session logs
- [ ] Parental consent workflow stub for future data features
- [ ] Right to data deletion mechanism documented

### US-017: Google Play Store Submission
**Description:** As the product owner, I need to submit the app to Google Play Store so that Indonesian parents can discover and download it.

**Acceptance Criteria:**
- [ ] APK/AAB signed with release certificate
- [ ] App icon finalized (512x512 PNG, high contrast)
- [ ] 5 screenshots prepared showing gameplay + parent features
- [ ] Store description in Bahasa Indonesia with SEO keywords
- [ ] ASO keywords configured: "game balita", "edukasi anak", "game anak Indonesia"
- [ ] Privacy policy link valid and accessible
- [ ] Content rating: Everyone (Google Play Families)
- [ ] Release notes translated to Indonesian
- [ ] Beta testing link shared with 100 testers
- [ ] Launch date scheduled

## Functional Requirements

### Core Gameplay
- FR-1: All 8 mini-games must be playable 100% offline
- FR-2: Every game must have audio feedback in Bahasa Indonesia
- FR-3: No game may contain timers, score pressure, or failure states
- FR-4: Haptic feedback on all successful interactions (50ms vibration)
- FR-5: Age-gating system adjusts content complexity based on child's age (2-3 vs 4-5 years)

### Data & Privacy
- FR-6: Zero personally identifiable information (PII) collected from children
- FR-7: Session data stored locally only (SQLite in user:// directory)
- FR-8: Max 100 sessions stored, oldest auto-deleted
- FR-9: Parent PIN required to access dashboard (4-digit, default 1234)

### Performance
- FR-10: App size must be <50MB (lite version)
- FR-11: Target device: 2GB RAM, Android 8.0+ (API 26)
- FR-12: Memory usage <150MB during gameplay
- FR-13: Stable 30 FPS during all mini-games
- FR-14: Load time <3 seconds between scenes

### Audio
- FR-15: All audio files in OGG Vorbis format, 48kHz mono
- FR-16: Audio bus hierarchy: Master → Background (-8dB), SFX (-3dB), Voice (-4dB)
- FR-17: Voice talent must be native Indonesian speaker
- FR-18: Max audio latency 50ms

### Parent Features
- FR-19: Parent dashboard shows 7-day playtime chart
- FR-20: Gallery stores all paintings/colorings locally
- FR-21: Notification when child plays >3 hours in a day
- FR-22: Settings for language, audio volume, subtitles, screen timeout

### Localization
- FR-23: Primary language: Bahasa Indonesia (100% UI and audio)
- FR-24: Secondary language: English (optional toggle)
- FR-25: Cultural content: wayang, batik, rumah adat, hewan nusantara

## Non-Goals (Out of Scope)

- No multiplayer/online gameplay (Phase 1)
- No subscription tier at launch (freemium with ads only)
- No iOS version in MVP (Android first, iOS future)
- No behavioral advertising or child tracking
- No social features or sharing from child account
- No in-app purchases for gameplay advantages (cosmetics only)
- No cloud sync in MVP (local storage only)
- No AI/adaptive learning algorithms (fixed progression only)
- No AR/VR features
- No voice recognition (playback only)

## Design Considerations

### UI/UX
- Target audience attention span: 5-10 minutes for ages 2-3, 10-15 minutes for ages 4-5
- Color palette: Primary colors (red, blue, yellow, green) with pastel variants to reduce eye strain
- Touch targets: Minimum 50x50px for toddler fingers
- Font: Rounded sans-serif (Outfit or Poppins), sizes 24px (body), 32px (headers)
- Safe zone: 20px margins from screen edges

### Character Design
- Wayang mascot as guide character
- 4 emotion states: happy, excited, surprised, calm
- Positioned at bottom-right of most screens
- Animations: 200-300ms transitions, smooth easing

### Accessibility
- WCAG AAA contrast ratio (7:1 minimum)
- No flashing/strobing effects (<3Hz limit)
- Audio + visual feedback for all interactions
- Left-handed play support (controls reachable from either side)

## Technical Considerations

### Engine & Platform
- Godot 4.2 LTS
- GDScript for all game logic
- Android export preset configured
- Minimum SDK: API 26 (Android 8.0)

### Dependencies
- No external SDKs required for MVP
- Future: AdMob for ads (optional in Phase 2)
- Future: Firebase Analytics (optional, parent opt-in)

### Asset Pipeline
- Graphics: PNG with indexed color for memory efficiency
- Max texture size: 1024x1024
- Audio: Preload all SFX in _ready(), music streamed

### Known Constraints
- Single developer team (320 hours estimated)
- 8-week timeline for MVP
- Budget for voice talent and audio production
- Must pass Google Play Families Program certification

## Success Metrics

### Launch Month
- 10,000 downloads
- 4.5+ star rating on Play Store
- <3% uninstall rate (Day 1-30)
- <0.5% crash rate

### 6-Month Targets
- 100,000 downloads
- 30,000 monthly active users (MAU)
- 25% 7-day retention
- 10% 30-day retention
- 2x average sessions per day
- 15-minute average session length

### Quality Metrics
- Tap latency <100ms (perceived)
- Load time <3s per scene
- Memory usage <150MB
- Zero ANR errors on 2GB devices

### Monetization (Phase 2)
- 1-2% conversion rate on cosmetics
- $300-500/day gross at 100K users

## Open Questions

1. **Voice Talent Recruitment:** Should we use Fiverr/local studio for Indonesian voice recording? Budget allocation needed.

2. **Ad Implementation:** Should rewarded ads be included in MVP or deferred to Phase 2? Impact on user experience?

3. **Music Licensing:** Are the Indonesian children's songs (Twinkle Twinkle, Cicak-cicak) public domain or do we need licensing?

4. **Beta Testing Distribution:** Should we use Google Play Early Access or direct APK distribution for 100 beta testers?

5. **Age Verification:** Should we add a simple "select your age" screen on first launch, or rely solely on parent settings?

6. **Gallery Cloud Backup:** Is there high demand for cloud-based gallery backup, or is local storage sufficient for MVP?

---

**Document Version:** 1.0
**Date:** January 23, 2026
**Project:** PlayTap (Taplok)
**Status:** Ready for Development Sprint
**Estimated Timeline:** 8 weeks (MVP Phase 1)
**Team Size:** 1 developer + 1 audio engineer
