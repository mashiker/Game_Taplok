# Music Assets for Rhythm Game

This directory contains backing tracks for the Music Rhythm game.

## Required Files

The following OGG files are expected for the rhythm game:

- `twinkle_twinkle.ogg` - Twinkle Twinkle Little Star (Indonesian version)
- `cicak_cicak.ogg` - Cicak-cicak di Dinding
- `lihat_lihat_penyu.ogg` - Lihat Lihat Penyu

## Technical Specifications

- **Format**: OGG Vorbis (preferred for Godot)
- **Sample Rate**: 44.1kHz or 48kHz
- **Bitrate**: 128-192 kbps
- **Duration**: 12-18 seconds per song
- **Bus**: Background bus (-8dB)

## Beat Timing

Each song should have clear beats at 1-second intervals starting at 0.5s.
Beat count is configured in RhythmGame.gd SONGS constant:

- Twinkle Twinkle ID: 12 beats
- Cicak-cicak di Dinding: 16 beats
- Lihat Lihat Penyu: 14 beats

## Placeholder

Currently using placeholder paths. Replace with actual audio files for production.
