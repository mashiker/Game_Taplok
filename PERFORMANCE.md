# PlayTap Performance Optimization Guide

## Optimizations Implemented

### 1. Frame Rate Capping
- **FPS Cap**: 30 FPS via `Engine.max_fps = 30` in GameManager._ready()
- **Purpose**: Consistent performance and battery saving on mobile devices
- **Location**: `scripts/GameManager.gd:21`

### 2. Object Pooling
- **Balloon Pool**: Pre-allocated pool of 6 balloons in TapPopGame
- **Reuse Instead of Destroy**: Balloons returned to pool instead of queue_free()
- **Pool Management**:
  - `_initialize_balloon_pool()` - Creates pool on startup
  - `_get_balloon_from_pool()` - Gets or creates balloon
  - `_return_balloon_to_pool()` - Returns balloon for reuse
- **Location**: `scripts/TapPopGame.gd`

### 3. Texture Compression
- **VRAM Compression**: Enabled via `textures/vram_compression/import_etc2_astc=true`
- **Mobile Format**: ETC2/ASTC compression for reduced memory
- **Location**: `project.godot:116`

### 4. Audio Performance
- **SFX Pool**: 4-player pool for simultaneous sound effects
- **Voice Ducking**: Automatic volume reduction during voice playback
- **Ogg Vorbis**: Compressed audio format for all sounds
- **Location**: `scripts/AudioManager.gd`

### 5. Export Optimizations
- **Strip Binaries**: Enabled for release builds (smaller APK)
- **LTO Debug Format**: Link-time optimization for better performance
- **Gradle Build**: Modern build system with optimizations
- **Location**: `export_presets.cfg`

## Performance Targets

| Metric | Target | Status |
|--------|--------|--------|
| FPS | 30 capped | ✓ Implemented |
| Memory Usage | <150MB | To be verified with profiler |
| Tap Latency | <100ms | ✓ Low-latency input handling |
| APK Size (Lite) | <50MB | To be verified on build |

## Best Practices for Game Scripts

### Object Pooling Pattern
```gdscript
# 1. Create pool in _ready()
func _ready():
    _initialize_pool()

# 2. Get from pool instead of instantiate()
var obj = _get_from_pool()

# 3. Return to pool instead of queue_free()
_return_to_pool(obj)
```

### Input Handling
- Use `gui_input()` for UI controls (already in Button nodes)
- Use `_input()` for global shortcuts
- Avoid heavy computation in input handlers

### Scene Transitions
- Use `GameManager.fade_to_scene()` for all transitions
- Avoid direct `get_tree().change_scene()` calls

## Profiling Checklist

Before release, verify performance using Godot profiler:

1. **Memory Profiler**
   - [ ] Static memory < 100MB
   - [ ] Peak memory < 150MB
   - [ ] No memory leaks after 10min play

2. **Performance Monitor**
   - [ ] FPS stable at 30
   - [ ] No frame spikes >100ms
   - [ ] Physics step <16ms

3. **Network Profiler** (if cloud sync added)
   - [ ] Bandwidth <10KB/min
   - [ ] Latency <500ms

## Low-End Device Considerations

- Minimum SDK: Android 8.0 (API 26)
- GPU: Adreno 506 or equivalent
- RAM: 2GB minimum
- Storage: 100MB free for app + data

## Optimization TODO (Future)

- [ ] Add VisibleOnScreenNotifier2D to particle emitters
- [ ] Implement audio preloading in AudioManager._ready()
- [ ] Add LOD (Level of Detail) for 3D elements (if any)
- [ ] Profile and optimize Database queries
- [ ] Add texture streaming for large backgrounds
