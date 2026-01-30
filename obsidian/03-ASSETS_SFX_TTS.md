# 03 — ASSETS (SFX/TTS) + Lisensi

## TTS
Engine: Piper (local)
- Binary: `tools/tts/piper/`
- Model: `rhasspy/piper-voices` → `id_ID/news_tts/medium`
- Output: `assets/sounds/words/id/transport/*.wav`

## SFX (CC0)
Folder: `assets/sounds/sfx/transport/`
- Car pack (CC0): https://opengameart.org/content/car-sound-effects-pack-low-quality
- Steam whistle (CC0): https://opengameart.org/content/steam-whistle
- Swishes pack (CC0): https://opengameart.org/content/swishes-sound-pack
- 100 CC0 SFX (CC0): https://opengameart.org/content/100-cc0-sfx
- Pleasing bell (CC0): https://opengameart.org/content/pleasing-bell-sound-effect

Detail mapping ada di: `assets/sounds/sfx/transport/CREDITS.txt`

## Konvensi file
- SFX: `assets/sounds/sfx/<theme>/<name>.(ogg|wav)`
- Voice: `assets/sounds/words/<lang>/<theme>/<slug>.wav`

## Note Godot compatibility
- WAV yang aman: PCM 16-bit (mono/stereo), 44.1kHz.
- Hindari PCM 24-bit.
