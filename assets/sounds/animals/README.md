# Animal Sounds for Piano Hewan

This directory contains animal sound files for the Piano Hewan game.

## Required Files

Place the following OGG audio files in this directory:

1. `komodo.ogg` - Komodo dragon sound (mapped to C4 key, red color)
2. `orangutan.ogg` - Orangutan sound (mapped to D4 key, blue color)
3. `burung.ogg` - Bird sound (mapped to E4 key, yellow color)
4. `paus.ogg` - Whale sound (mapped to F4 key, green color)
5. `belalang.ogg` - Grasshopper sound (mapped to G4 key, orange color)

## Audio Specifications

- **Format**: OGG Vorbis
- **Sample Rate**: 44100 Hz
- **Bitrate**: 128 kbps
- **Duration**: 2-5 seconds (loopable)
- **Volume**: Normalized to -3dB

## Implementation Notes

The sounds are loaded in `PianoKey.gd` using the `AudioStreamOggVorbis` class.
Each sound loops for up to 3 seconds when the key is held, then fades out.

To add sounds:
1. Place OGG files in this directory
2. Ensure filenames match the expected names above
3. The game will automatically load and play them
