# Jevi Checklist + Nightly Test Plan (Game_Taplok)

## Scope / Goals
- Keep changes incremental and smoke-testable (headless).
- Kid-friendly visuals (flat pastel textures), clear objectives, HUD progress, and consistent feedback loops (RewardSystem sparkle + pop).

---

## Quick Checklist (per mini-game)

### Visuals
- [ ] No placeholder `ColorRect` as primary gameplay visual (ok for subtle overlays like highlight/glow).
- [ ] Background uses a texture (soft pastel).
- [ ] Main interactables use textures sized for mobile (>=256px source).
- [ ] UI text readable (HeaderSmall/Medium) and safe margins.

### Objective + HUD
- [ ] Objective text shown at top (1 sentence, kid/parent friendly).
- [ ] Progress shown (e.g., `2/4` pairs).
- [ ] Win condition matches the HUD goal.

### Feedback loop
- [ ] Success → `RewardSystem.reward_success(pos)` + happy SFX.
- [ ] Error/invalid action → `RewardSystem.reward_error(pos)` + gentle SFX.
- [ ] Win → celebration SFX + short message + return to menu.

### Input / UX
- [ ] No hard fail when tapping fast.
- [ ] Drag targets highlight when valid.
- [ ] Matched items become non-interactive.

---

## Nightly Headless Smoke Test (recommended)

> Run from repo root: `Game_Taplok/`

1) Asset import (ensures new PNGs get `.import` generated)
```bash
godot --headless --path . --import
```

2) Parse/load project + editor init then quit (catches scene/script parse errors)
```bash
godot --headless --path . --editor --quit
```

3) Optional: run a short boot to main menu (if main scene is configured to exit via CI)
- If you add an auto-quit flag later, run it here.

### What to watch for
- Any `Parse Error` in `.tscn` / `.gd`.
- Missing texture imports.
- Script errors about nodes not found (usually scene changes).

---

## Manual 2-minute Sanity Pass (DragMatch + MemoryFlip)

### DragMatch
- [ ] Objective at top shows (description).
- [ ] Progress updates each match.
- [ ] Shapes use textures and feel tappable.
- [ ] Wrong drop → shape bounces back + red sparkle.
- [ ] Correct drop → sparkle + confetti + slot success pulse.
- [ ] Game ends after matching all current pairs.

### MemoryFlip
- [ ] Objective + progress shown.
- [ ] Card front/back are textured.
- [ ] Match → glow + RewardSystem success.
- [ ] No-match → RewardSystem error.
- [ ] Win label shows and returns to menu.

---

## Manual 2-minute Sanity Pass (Piano / Creative / Rhythm / ShapeMatch)

### PianoGame (Piano Hewan)
- [ ] Background uses `assets/textures/games/piano/bg_piano_1080x1920.png`.
- [ ] Keys use textured base (`key_piano_256x512.png`) + animal icon.
- [ ] Objective shows: “Coba semua hewan”.
- [ ] Progress counts unique keys (`0/5` → `5/5`).
- [ ] New animal key → `RewardSystem.reward_success`.
- [ ] Repeat key tap → `RewardSystem.reward_tap` (small sparkle).

### ColoringGame
- [ ] Background uses `assets/textures/games/creative/bg_creative_1080x1920.png`.
- [ ] Objective shows: “Warnai gambar”.
- [ ] Progress increments on meaningful fills (`0/10` → `10/10`).
- [ ] Fill action changes pixels → `RewardSystem.reward_success`.
- [ ] Tap on outline/already-filled → `RewardSystem.reward_error` + gentle SFX.

### FingerPaintGame
- [ ] Background uses `assets/textures/games/creative/bg_creative_1080x1920.png`.
- [ ] Objective shows: “Buat coretan”.
- [ ] Progress counts strokes (`0/5` → `5/5`).
- [ ] Stroke end → `RewardSystem.reward_success`.
- [ ] Save painting → big `RewardSystem.reward_success`.

### RhythmGame
- [ ] Background uses `assets/textures/games/rhythm/bg_rhythm_1080x1920.png`.
- [ ] Beat circles use textured sprites (`circle_1..4_256.png`).
- [ ] Objective shows: “Ikuti irama”.
- [ ] Progress shows correct/total beats.
- [ ] Correct tap → success sparkle.
- [ ] Miss tap → soft error sparkle.

### ShapeMatchGame (Shape Silhouette)
- [ ] Background uses `assets/textures/games/shape_match/bg_shape_match_1080x1920.png`.
- [ ] Silhouette + options use textured tiles and icons.
- [ ] Objective shows: “Cocokkan bayangan”.
- [ ] Progress shows puzzles completed / puzzles in session.
- [ ] Correct drop → `RewardSystem.reward_success` + silhouette tint fills.
- [ ] Wrong drop → `RewardSystem.reward_error` + gentle bounce-back.
