extends Node

# AudioManager - Global singleton for all audio playback
# Handles SFX, voice, and music with proper bus routing and ducking

## Constants ##
const SFX_POOL_SIZE: int = 4
const SOUNDS_PATH: String = "res://assets/sounds/"

## Audio Bus Names ##
const BUS_MASTER: String = "Master"
const BUS_BACKGROUND: String = "Background"
const BUS_SFX: String = "SFX"
const BUS_VOICE: String = "Voice"

## Variables ##
var _sfx_pool: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer = null
var _voice_player: AudioStreamPlayer = null
var _current_music: String = ""
var _previous_sfx_volumes: Dictionary = {}

## Built-in Functions ##
func _ready() -> void:
	_create_sfx_pool()
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = BUS_BACKGROUND
	add_child(_music_player)

	_voice_player = AudioStreamPlayer.new()
	_voice_player.bus = BUS_VOICE
	add_child(_voice_player)

	# Connect voice player signal for ducking
	_voice_player.finished.connect(_on_voice_finished)

	print("AudioManager initialized with ", _sfx_pool.size(), " SFX players")

## Public Functions ##

# Play a sound effect
# @param path: Path to audio file relative to /assets/sounds/ or full path
# @param bus: Audio bus to use (default: "SFX")
func play_sfx(path: String, bus: String = BUS_SFX) -> void:
	if path.is_empty():
		push_warning("AudioManager.play_sfx: empty path")
		return

	# Build full path if not absolute
	var full_path = path if path.begins_with("res://") or path.begins_with("user://") else SOUNDS_PATH + path

	# Check if file exists
	if not FileAccess.file_exists(full_path):
		push_warning("AudioManager.play_sfx: file not found: ", full_path)
		return

	# Find available player in pool
	var player = _get_available_sfx_player()
	if not player:
		push_warning("AudioManager.play_sfx: no available players")
		return

	# Load and play
	var stream = _load_audio_stream(full_path)
	if stream:
		player.stream = stream
		player.bus = bus
		player.play()
	else:
		push_error("AudioManager.play_sfx: failed to load ", full_path)

# Play a voice line (ducks SFX when playing)
# @param path: Path to audio file relative to /assets/sounds/
func play_voice(path: String) -> void:
	if path.is_empty():
		push_warning("AudioManager.play_voice: empty path")
		return

	# Don't interrupt current voice
	if _voice_player.playing:
		push_warning("AudioManager.play_voice: voice already playing")
		return

	var full_path = path if path.begins_with("res://") or path.begins_with("user://") else SOUNDS_PATH + path

	if not FileAccess.file_exists(full_path):
		push_warning("AudioManager.play_voice: file not found: ", full_path)
		return

	# Duck SFX buses before playing voice
	_duck_sfx_buses()

	var stream = _load_audio_stream(full_path)
	if stream:
		_voice_player.stream = stream
		_voice_player.play()
	else:
		push_error("AudioManager.play_voice: failed to load ", full_path)

# Play background music (loops by default)
# @param path: Path to audio file relative to /assets/sounds/
# @param loop: Whether to loop the music (default: true)
# @param fade_duration: Fade in duration in seconds (default: 0 for instant)
func play_music(path: String, loop: bool = true, fade_duration: float = 0.0) -> void:
	if path.is_empty():
		push_warning("AudioManager.play_music: empty path")
		return

	var full_path = path if path.begins_with("res://") or path.begins_with("user://") else SOUNDS_PATH + path

	if not FileAccess.file_exists(full_path):
		push_warning("AudioManager.play_music: file not found: ", full_path)
		return

	# Store for reference
	_current_music = full_path

	var stream = _load_audio_stream(full_path)
	if stream:
		stream.loop = loop
		_music_player.stream = stream

		if fade_duration > 0:
			_music_player.volume_db = -60  # Start silent
			_music_player.play()
			_fade_music_to(0, fade_duration)  # Fade to normal volume
		else:
			_music_player.play()
	else:
		push_error("AudioManager.play_music: failed to load ", full_path)

# Stop background music
# @param fade_duration: Fade out duration in seconds (default: 0 for instant)
func stop_music(fade_duration: float = 0.0) -> void:
	if fade_duration > 0:
		_fade_music_to(-60, fade_duration)
		await get_tree().create_timer(fade_duration).timeout
		_music_player.stop()
		_music_player.volume_db = 0  # Reset volume
	else:
		_music_player.stop()
	_current_music = ""

# Set volume for an audio bus
# @param bus_name: Name of the audio bus
# @param volume_db: Volume in decibels (-60 to 0, typically -20 to 0)
func set_volume(bus_name: String, volume_db: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		AudioServer.set_bus_volume_db(bus_index, volume_db)
	else:
		push_warning("AudioManager.set_volume: bus not found: ", bus_name)

# Get volume for an audio bus
# @param bus_name: Name of the audio bus
# @return: Volume in decibels
func get_volume(bus_name: String) -> float:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		return AudioServer.get_bus_volume_db(bus_index)
	return 0.0

# Check if a voice is currently playing
# @return: true if voice is playing
func is_voice_playing() -> bool:
	return _voice_player != null and _voice_player.playing

# Check if music is currently playing
# @return: true if music is playing
func is_music_playing() -> bool:
	return _music_player != null and _music_player.playing

## Private Functions ##

# Create the SFX player pool
func _create_sfx_pool() -> void:
	for i in range(SFX_POOL_SIZE):
		var player = AudioStreamPlayer.new()
		player.bus = BUS_SFX
		add_child(player)
		_sfx_pool.append(player)

# Get an available SFX player from the pool
func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in _sfx_pool:
		if not player.playing:
			return player
	return null

# Load an audio stream from file
func _load_audio_stream(path: String) -> AudioStream:
	# Determine file type and load accordingly
	var ext = path.get_extension().to_lower()

	match ext:
		"ogg":
			var loader = AudioStreamOggVorbis.new()
			var file = FileAccess.open(path, FileAccess.READ)
			if file:
				loader.data = file.get_buffer(file.get_length())
				file.close()
				return loader
		"mp3":
			return load(path) as AudioStreamMP3
		"wav":
			return load(path) as AudioStreamWAV
		_:
			push_error("AudioManager: unsupported audio format: ", ext)
			return null

	return null

# Duck SFX buses when voice plays (lower volume)
func _duck_sfx_buses() -> void:
	# Store current volumes and reduce SFX bus
	var sfx_bus_index = AudioServer.get_bus_index(BUS_SFX)
	if sfx_bus_index >= 0:
		_previous_sfx_volumes[BUS_SFX] = AudioServer.get_bus_volume_db(sfx_bus_index)
		AudioServer.set_bus_volume_db(sfx_bus_index, -12)  # Reduce by ~12dB

# Restore SFX bus volumes when voice finishes
func _on_voice_finished() -> void:
	# Restore SFX volume
	if _previous_sfx_volumes.has(BUS_SFX):
		var sfx_bus_index = AudioServer.get_bus_index(BUS_SFX)
		if sfx_bus_index >= 0:
			AudioServer.set_bus_volume_db(sfx_bus_index, _previous_sfx_volumes[BUS_SFX])
		_previous_sfx_volumes.erase(BUS_SFX)

# Fade music volume to target
func _fade_music_to(target_db: float, duration: float) -> void:
	var tween = create_tween()
	var current_db = _music_player.volume_db
	tween.tween_property(_music_player, "volume_db", target_db, duration)
