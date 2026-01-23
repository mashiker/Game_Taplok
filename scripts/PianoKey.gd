extends Control

# PianoKey - Individual piano key with animal sound
# Handles touch input, highlighting, and audio playback

class_name PianoKey

## Signals ##
signal key_pressed(key_id)
signal key_released(key_id)

## Constants ##
const BRIGHTEN_AMOUNT: float = 0.3  # 30% brightness increase on press
const HAPTIC_PRESS_MS: int = 30     # Haptic feedback duration on press
const HAPTIC_RELEASE_MS: int = 50   # Haptic feedback duration on release
const LOOP_MAX_DURATION: float = 3.0  # Max 3 seconds for loop
const FADE_DURATION: float = 0.5      # Fade out duration

## Exported Variables ##
@export var key_id: String = ""       # e.g., "C4", "D4", "E4", "F4", "G4"
@export var animal_name: String = ""  # e.g., "Komodo", "Orangutan", "Burung", "Paus", "Belalang"
@export var sound_path: String = ""   # Path to animal sound file
@export var base_color: Color = Color.WHITE  # Base color of the key

## Variables ##
var is_pressed: bool = false
var press_start_time: float = 0.0
var current_player: AudioStreamPlayer = null
var loop_timer: Timer = null
var fade_tween: Tween = null

## Node References ##
@onready var color_rect: ColorRect = $ColorRect
@onready var icon_rect: TextureRect = $IconTexture

## Built-in Functions ##
func _ready() -> void:
	# Set initial color
	if color_rect:
		color_rect.color = base_color

	# Create timer for loop duration
	loop_timer = Timer.new()
	loop_timer.wait_time = LOOP_MAX_DURATION
	loop_timer.one_shot = true
	loop_timer.timeout.connect(_on_loop_timeout)
	add_child(loop_timer)

	# Enable multi-touch
	mouse_filter = MOUSE_FILTER_PASS

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return

	# Handle touch events for multi-touch support
	if event is InputEventScreenTouch:
		var local_pos = make_input_local(event).position
		if get_rect().has_point(local_pos):
			if event.pressed and not is_pressed:
				_press_key()
			elif not event.pressed and is_pressed:
				_release_key()
			accept_event()

	# Handle mouse events for desktop testing
	elif event is InputEventMouseButton:
		var local_pos = make_input_local(event).position
		if get_rect().has_point(local_pos) and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not is_pressed:
				_press_key()
				accept_event()
			elif not event.pressed and is_pressed:
				_release_key()
				accept_event()

## Private Functions ##

# Press the key (start playing sound)
func _press_key() -> void:
	is_pressed = true
	press_start_time = Time.get_unix_time_from_system()

	# Highlight the key
	_highlight_key()

	# Haptic feedback
	_trigger_haptic(HAPTIC_PRESS_MS)

	# Start playing sound
	_play_sound()

	# Start loop timer
	loop_timer.start()

	# Emit signal
	key_pressed.emit(key_id)

# Release the key (stop playing sound or let it fade)
func _release_key() -> void:
	is_pressed = false

	# Remove highlight
	_unhighlight_key()

	# Haptic feedback
	_trigger_haptic(HAPTIC_RELEASE_MS)

	# Stop loop timer
	loop_timer.stop()

	# Fade out sound if still playing
	if current_player and current_player.playing:
		_fade_out_sound()

	# Emit signal
	key_released.emit(key_id)

# Highlight the key (increase brightness)
func _highlight_key() -> void:
	if color_rect:
		var highlighted_color = base_color
		highlighted_color.v = min(1.0, base_color.v + BRIGHTEN_AMOUNT)
		color_rect.color = highlighted_color

# Remove highlight from the key
func _unhighlight_key() -> void:
	if color_rect:
		color_rect.color = base_color

# Play the animal sound
func _play_sound() -> void:
	if sound_path.is_empty():
		push_warning("PianoKey._play_sound: no sound path for key ", key_id)
		return

	# Create a new audio player for this key
	if current_player == null:
		current_player = AudioStreamPlayer.new()
		current_player.bus = "SFX"
		add_child(current_player)

	# Load and play the sound
	var full_path = "res://assets/sounds/" + sound_path
	if not FileAccess.file_exists(full_path):
		push_warning("PianoKey._play_sound: file not found: ", full_path)
		return

	var stream = _load_audio_stream(full_path)
	if stream:
		stream.loop = true  # Enable looping
		current_player.stream = stream
		current_player.play()

# Load audio stream from file
func _load_audio_stream(path: String) -> AudioStream:
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

	return null

# Trigger haptic feedback
func _trigger_haptic(duration_ms: int) -> void:
	if OS.has_feature("android") or OS.has_feature("ios"):
		OS.vibrate_msec(duration_ms)

# Fade out the sound
func _fade_out_sound() -> void:
	if current_player and current_player.playing:
		# Cancel any existing fade tween
		if fade_tween:
			fade_tween.kill()

		# Create new fade tween
		fade_tween = create_tween()
		fade_tween.set_parallel(false)
		fade_tween.tween_property(current_player, "volume_db", -60, FADE_DURATION)
		fade_tween.tween_callback(_stop_sound_player)

# Stop the sound player
func _stop_sound_player() -> void:
	if current_player:
		current_player.stop()
		current_player.volume_db = 0  # Reset volume

# Handle loop timeout (max 3 seconds)
func _on_loop_timeout() -> void:
	if is_pressed:
		# Auto-fade after max loop duration
		_fade_out_sound()

## Public Functions ##

# Stop playing sound immediately
func stop_sound() -> void:
	if current_player and current_player.playing:
		current_player.stop()
	if loop_timer:
		loop_timer.stop()
	if fade_tween:
		fade_tween.kill()

# Check if sound is currently playing
func is_playing() -> bool:
	return current_player != null and current_player.playing

# Get the key ID
func get_key_id() -> String:
	return key_id

# Get the animal name
func get_animal_name() -> String:
	return animal_name
