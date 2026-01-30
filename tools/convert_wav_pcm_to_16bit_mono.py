#!/usr/bin/env python3
"""Convert PCM WAV (including 24-bit) to 16-bit mono WAV.

Godot's AudioStreamWAV support can be picky; 24-bit PCM often won't play.
This script reads PCM WAV and writes 16-bit mono (44100 Hz preserved).

Usage:
  python3 tools/convert_wav_pcm_to_16bit_mono.py in.wav out.wav
"""

import sys
import wave
import struct


def read_samples_pcm(w: wave.Wave_read):
    nch = w.getnchannels()
    sw = w.getsampwidth()
    nframes = w.getnframes()
    raw = w.readframes(nframes)

    if sw == 1:
        # unsigned 8-bit
        fmt = f"<{nframes * nch}B"
        data = struct.unpack(fmt, raw)
        # convert to signed centered
        data = [x - 128 for x in data]
        return nch, data

    if sw == 2:
        fmt = f"<{nframes * nch}h"
        data = struct.unpack(fmt, raw)
        return nch, list(data)

    if sw == 3:
        # signed 24-bit little-endian
        data = []
        for i in range(0, len(raw), 3):
            b0 = raw[i]
            b1 = raw[i + 1]
            b2 = raw[i + 2]
            v = b0 | (b1 << 8) | (b2 << 16)
            # sign extend
            if v & 0x800000:
                v -= 1 << 24
            data.append(v)
        return nch, data

    if sw == 4:
        fmt = f"<{nframes * nch}i"
        data = struct.unpack(fmt, raw)
        return nch, list(data)

    raise SystemExit(f"Unsupported sample width: {sw}")


def downmix_to_mono(nch: int, samples):
    if nch == 1:
        return samples
    mono = []
    for i in range(0, len(samples), nch):
        s = 0
        for c in range(nch):
            s += samples[i + c]
        mono.append(int(s / nch))
    return mono


def scale_to_int16(samples, sw_in: int):
    # Determine max range based on input width
    if sw_in == 1:
        max_in = 127
    elif sw_in == 2:
        max_in = 32767
    elif sw_in == 3:
        max_in = 8388607
    elif sw_in == 4:
        max_in = 2147483647
    else:
        max_in = 32767

    out = []
    for s in samples:
        # clamp
        if s > max_in:
            s = max_in
        if s < -max_in - 1:
            s = -max_in - 1
        # scale to int16
        v = int(s / max_in * 32767)
        if v > 32767:
            v = 32767
        if v < -32768:
            v = -32768
        out.append(v)
    return out


def main():
    if len(sys.argv) != 3:
        print("Usage: convert_wav_pcm_to_16bit_mono.py in.wav out.wav")
        return 2

    src, dst = sys.argv[1], sys.argv[2]
    with wave.open(src, "rb") as w:
        fr = w.getframerate()
        sw = w.getsampwidth()
        nch, samples = read_samples_pcm(w)

    mono = downmix_to_mono(nch, samples)
    out16 = scale_to_int16(mono, sw)

    with wave.open(dst, "wb") as o:
        o.setnchannels(1)
        o.setsampwidth(2)
        o.setframerate(fr)
        o.writeframes(struct.pack(f"<{len(out16)}h", *out16))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
