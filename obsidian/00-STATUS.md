# 00 — STATUS (Latest)

## Ringkasan
Project: **PlayTap / Game_Taplok** (Godot 4.5)

## Fitur yang sudah beres
### Find & Tap
- Added popup selector scene: `scenes/FindTapThemeSelect.tscn` (+ `scripts/FindTapThemeSelect.gd`)
- MainMenu: tombol "Cari & Tap" sekarang masuk ke selector dulu
- GameManager: `findtap_theme_path` untuk membawa pilihan theme ke FindTapGame
- Theme data:
  - `assets/data/themes/animals_id.json` (ditambah background)
  - `assets/data/themes/transport_id.json` (baru)
- Asset transport (FLUX):
  - BG: `assets/textures/games/find_tap/bg_findtap_transport_1920x1080.png`
  - Icons: `assets/textures/games/find_tap/transport/*.png`
- FindTapGame:
  - Bisa load theme random dari list theme paths
  - Apply background per theme
  - Voice prompt & feedback (best-effort)

### Sound Match (Transport)
- Scene: `scenes/SoundMatchGame.tscn`
- Script: `scripts/SoundMatchGame.gd`
- Menu button baru: `SoundMatchButton` (judul: **Tebak Suara**)
- Prompt mode A: **SFX-first** (fallback ke TTS jika perlu)

## Audio
### TTS (Indonesia) — Piper
- Piper binary: `tools/tts/piper/`
- Model: `tools/tts/models/id_ID/news_tts/medium/`
- Generator: `tools/tts_generate_id_piper.py`
- Output transport words/phrases (WAV): `assets/sounds/words/id/transport/*.wav`

### SFX Transport (CC0)
Folder: `assets/sounds/sfx/transport/`
- mobil: `mobil_vroom.ogg`, `mobil_start.ogg`
- bus: `klakson.ogg`
- kereta: `kereta_whistle.wav`
- pesawat: `pesawat_whoosh.wav`
- kapal: `kapal_splash.ogg`
- sepeda: `sepeda_bell.wav`
Credits: `assets/sounds/sfx/transport/CREDITS.txt`

Catatan bug: `pesawat_whoosh.wav` awalnya 24-bit PCM → tidak bunyi di Godot. Sudah di-convert ke 16-bit mono.
Converter: `tools/convert_wav_pcm_to_16bit_mono.py`

## UI/Fix
- Fix MainMenu responsive layout error: tidak akses `theme_override_constants` langsung; pakai `set("theme_override_constants/...", value)`.

## Smoke test
- `godot --headless --import --path .`
- `godot --headless --quit --path .`
(OK)
