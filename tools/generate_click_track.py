#!/usr/bin/env python3
"""Generate simple metronome click WAV tracks for RhythmGame.

Creates WAV 16-bit mono 44100Hz with clicks on beats.
"""

from __future__ import annotations

import argparse
import math
import pathlib
import struct

SR = 44100


def synth_click_track(duration_s: float, beats: int, beat_interval: float, start_offset: float = 0.5):
    n = int(duration_s * SR)
    buf = [0.0] * n

    # click: short 1.5kHz burst
    click_len = int(0.035 * SR)
    freq = 1500.0
    amp = 0.6

    for i in range(beats):
        t0 = start_offset + i * beat_interval
        p0 = int(t0 * SR)
        for k in range(click_len):
            p = p0 + k
            if 0 <= p < n:
                # windowed sine burst
                w = 1.0 - (k / click_len)
                buf[p] += amp * w * math.sin(2 * math.pi * freq * (k / SR))

    # clamp and convert
    out = bytearray()
    for s in buf:
        s = max(-1.0, min(1.0, s))
        out += struct.pack('<h', int(s * 32767))
    return bytes(out)


def write_wav(path: pathlib.Path, pcm16: bytes):
    path.parent.mkdir(parents=True, exist_ok=True)
    nch = 1
    bits = 16
    byte_rate = SR * nch * bits // 8
    block_align = nch * bits // 8
    data_size = len(pcm16)

    header = bytearray()
    header += b'RIFF'
    header += struct.pack('<I', 36 + data_size)
    header += b'WAVE'
    header += b'fmt '
    header += struct.pack('<I', 16)
    header += struct.pack('<H', 1)  # PCM
    header += struct.pack('<H', nch)
    header += struct.pack('<I', SR)
    header += struct.pack('<I', byte_rate)
    header += struct.pack('<H', block_align)
    header += struct.pack('<H', bits)
    header += b'data'
    header += struct.pack('<I', data_size)

    path.write_bytes(bytes(header) + pcm16)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', required=True)
    ap.add_argument('--beats', type=int, required=True)
    ap.add_argument('--interval', type=float, default=1.0)
    ap.add_argument('--tail', type=float, default=2.0)
    args = ap.parse_args()

    duration = args.beats * args.interval + args.tail
    pcm = synth_click_track(duration, args.beats, args.interval)
    write_wav(pathlib.Path(args.out), pcm)
    print('Wrote', args.out, 'duration', duration)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
