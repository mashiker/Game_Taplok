# 01 — TODO / Backlog

## Next (Prioritas)
1) **Finalize Sound Match (Transport)**
   - Tuning volume SFX (supaya tidak kaget untuk balita)
   - Tambah cooldown agar prompt tidak spam
   - Optional: randomize variasi SFX per item (2-3 varian)

2) **Theme Selector (non-random)**
   - Pilih Animals / Transport sebelum masuk FindTap
   - Persist pilihan (user://settings.json atau DB)

3) **SFX library hygiene**
   - Normalize loudness (target -16 LUFS-ish / atau simple -10 dB)
   - Pastikan semua SFX format aman (ogg atau WAV 16-bit)

## Nice to have
- Tambah SFX khusus kapal (boat horn) yang cartoony
- Tambah SFX khusus pesawat (engine/propeller) yang lebih “pesawat”
- Tambah tutorial 1x (UI hint)
- Tambah difficulty: options 3 → 4

## Risks / Notes
- Godot AudioStreamWAV: hindari 24-bit PCM; gunakan 16-bit PCM.
- Untuk asset dari OpenGameArt: simpan credits/license per folder.
