extends "res://scripts/GameSceneBase.gd"

# RhythmGame - Music rhythm game with beat tapping
# Children tap circles in sync with the beat

class_name RhythmGame

## Constants ##
const CIRCLE_SIZE: int = 50
const CIRCLE_SPACING: int = 20
const BEAT_INTERVAL: float = 1.0  # 1 second between beats
const TIMING_WINDOW: float = 0.3  # ±0.3s window for correct tap
const BEAT_PULSE_DURATION: float = 0.2  # Duration of beat pulse animation
const CORRECT_ANIMATION_DURATION: float = 0.3  # Duration of correct tap animation
const PARTICLE_COUNT: int = 8  # Number of particles on correct tap

## Song Configuration ##
const SONGS: Array = [
	{"name": "Twinkle Twinkle ID", "path": "res://assets/sounds/music/twinkle_twinkle.ogg", "beats": 12},
	{"name": "Cicak-cicak di Dinding", "path": "res://assets/sounds/music/cicak_cicak.ogg", "beats": 16},
	{"name": "Lihat Lihat Penyu", "path": "res://assets/sounds/music/lihat_lihat_penyu.ogg", "beats": 14}
]

## Circle Colors ##
const CIRCLE_COLORS: Array[Color] = [
	Color(0.92, 0.3, 0.24),  # Red #E84A3D
	Color(0.22, 0.74, 0.97),  # Blue #38BDF8
	Color(0.98, 0.75, 0.14),  # Yellow #FBBF24
	Color(0.2, 0.83, 0.6)  # Green #34D399
]

## Variables ##
var beat_circles: Array[ColorRect] = []
var beat_timestamps: Array[float] = []
var current_song_index: int = 0
var song_start_time: float = 0.0
var song_duration: float = 0.0
var is_playing: bool = false
var correct_beats: int = 0
var total_beats: int = 0
var tapped_beats: Array[int] = []  # Track which beats have been tapped
var active_particles: Array[Node2D] = []
var is_transitioning: bool = false

## Node References ##
var music_player: AudioStreamPlayer = null
var result_label: Label = null
var circles_container: HBoxContainer = null
var wayang_sprite: AnimatedSprite2D = null

## Built-in Functions ##
func _ready() -> void:
	# Set game name before calling parent _ready
	game_name = "Music Rhythm"
	super._ready()

	# Get node references
	_setup_node_references()

	# Set up the rhythm game
	_setup_rhythm_game()

func _process(delta: float) -> void:
	if not is_active or not is_playing:
		return

	# Update beat visualization
	_update_beat_visuals()

## Virtual Functions Overrides ##

func _on_game_start() -> void:
	super._on_game_start()
	# Start session tracking
	SessionManager.start_session(game_name)
	SessionManager.set_metric("content_category", "musical")

func _on_game_end() -> void:
	super._on_game_end()
	# Stop music
	_stop_music()
	# End session
	SessionManager.end_session()

func _get_game_metrics() -> Dictionary:
	var base_metrics = super._get_game_metrics()
	base_metrics["correct_beats"] = correct_beats
	base_metrics["total_beats"] = total_beats
	base_metrics["accuracy"] = float(correct_beats) / float(total_beats) if total_beats > 0 else 0.0
	return base_metrics

## Private Functions ##

# Set up node references
func _setup_node_references() -> void:
	music_player = $MusicPlayer
	result_label = $ResultLabel
	wayang_sprite = $GameContainer/TopBar/WayangMascot

# Set up the rhythm game UI
func _setup_rhythm_game() -> void:
	var game_content = $GameContainer/GameContent
	if not game_content:
		push_error("RhythmGame._setup_rhythm_game: GameContent node not found")
		return

	# Create main container
	var main_container = VBoxContainer.new()
	main_container.name = "RhythmContainer"
	main_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.add_theme_constant_override("separation", 40)
	game_content.add_child(main_container)

	# Add spacer at top
	var top_spacer = Control.new()
	top_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.add_child(top_spacer)

	# Create circles container
	circles_container = HBoxContainer.new()
	circles_container.name = "CirclesContainer"
	circles_container.alignment = BoxContainer.ALIGNMENT_CENTER
	circles_container.add_theme_constant_override("separation", CIRCLE_SPACING)
	main_container.add_child(circles_container)

	# Create 4 beat circles
	for i in range(4):
		_create_beat_circle(i)

	# Add spacer at bottom
	var bottom_spacer = Control.new()
	bottom_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.add_child(bottom_spacer)

	# Pick a random song
	current_song_index = randi() % SONGS.size()

	# Start the game
	_start_song()

# Create a single beat circle
func _create_beat_circle(index: int) -> void:
	var circle = ColorRect.new()
	circle.name = "BeatCircle" + str(index)
	circle.custom_minimum_size = Vector2(CIRCLE_SIZE, CIRCLE_SIZE)
	circle.color = CIRCLE_COLORS[index]
	circle.mouse_filter = Control.MOUSE_FILTER_PASS

	# Make it circular (corner radius)
	# Note: In Godot 4.2, we use theme overrides for corner radius
	# For now, we'll use a simple colored rect - visual polish can be added later

	# Connect gui_input for tap detection
	circle.gui_input.connect(_on_circle_input.bind(index))

	# Store reference
	beat_circles.append(circle)
	circles_container.add_child(circle)

# Start the song and beat tracking
func _start_song() -> void:
	var current_song = SONGS[current_song_index]
	total_beats = current_song.beats
	correct_beats = 0
	tapped_beats.clear()
	active_particles.clear()

	# Generate beat timestamps (1 second intervals starting from 0.5s)
	beat_timestamps.clear()
	for i in range(total_beats):
		beat_timestamps.append(0.5 + (i * BEAT_INTERVAL))

	# Load and play music
	var audio_stream = load(current_song.path)
	if audio_stream:
		music_player.stream = audio_stream
		song_duration = audio_stream.get_length() if audio_stream is AudioStreamOggVorbis else float(total_beats) * BEAT_INTERVAL + 2.0

		# Start playing
		music_player.play()
		song_start_time = Time.get_unix_time_from_system()
		is_playing = true

		# Connect to finished signal
		if not music_player.finished.is_connected(_on_song_finished):
			music_player.finished.connect(_on_song_finished)

		print("RhythmGame: Started song '", current_song.name, "' with ", total_beats, " beats")
	else:
		push_error("RhythmGame._start_song: Failed to load audio stream from ", current_song.path)
		# Use fallback timing
		song_duration = float(total_beats) * BEAT_INTERVAL + 2.0
		song_start_time = Time.get_unix_time_from_system()
		is_playing = true

		# Create a timer to simulate song end
		var timer = Timer.new()
		timer.wait_time = song_duration
		timer.one_shot = true
		timer.timeout.connect(_on_song_finished)
		add_child(timer)
		timer.start()

# Update beat visuals (pulse on beat)
func _update_beat_visuals() -> void:
	var current_time = Time.get_unix_time_from_system() - song_start_time

	# Find the current beat index
	var current_beat_index = -1
	for i in range(beat_timestamps.size()):
		var beat_time = beat_timestamps[i]
		var time_since_beat = current_time - beat_time

		# If we're in the pulse window for this beat
		if time_since_beat >= 0 and time_since_beat < BEAT_PULSE_DURATION:
			current_beat_index = i % 4  # Cycle through 4 circles
			break

	# Pulse the appropriate circle
	for i in range(beat_circles.size()):
		var circle = beat_circles[i]
		if circle:
			if i == current_beat_index:
				# Brighten the circle (pulse effect)
				circle.color = CIRCLE_COLORS[i].lightened(0.3)
			else:
				# Return to normal color
				circle.color = CIRCLE_COLORS[i]

# Handle tap on beat circle
func _on_circle_input(event: InputEvent, circle_index: int) -> void:
	if not is_playing or is_transitioning:
		return

	# Only handle tap events (mouse button press or touch)
	if event is InputEventMouseButton and event.pressed:
		_handle_tap(circle_index)
	elif event is InputEventScreenTouch and event.pressed:
		_handle_tap(circle_index)

# Handle a tap on a circle
func _handle_tap(circle_index: int) -> void:
	var current_time = Time.get_unix_time_from_system() - song_start_time

	# Find the closest beat
	var closest_beat_index = -1
	var closest_beat_distance = INF

	for i in range(beat_timestamps.size()):
		var beat_time = beat_timestamps[i]
		var distance = abs(current_time - beat_time)

		if distance < closest_beat_distance:
			closest_beat_distance = distance
			closest_beat_index = i

	# Check if tap is within timing window
	if closest_beat_index >= 0 and closest_beat_distance <= TIMING_WINDOW:
		# Check if this beat was already tapped
		if closest_beat_index in tapped_beats:
			return  # Already tapped this beat

		# Correct tap!
		_on_correct_tap(circle_index, closest_beat_index)
	else:
		# Missed beat - no penalty, just ignore
		pass

# Handle a correct tap
func _on_correct_tap(circle_index: int, beat_index: int) -> void:
	# Mark beat as tapped
	tapped_beats.append(beat_index)
	correct_beats += 1

	# Record tap
	SessionManager.record_tap()

	# Get the circle
	var circle = beat_circles[circle_index]
	if not circle:
		return

	# Play ding SFX
	AudioManager.play_sfx("sfx/ding.ogg")

	# Animate circle: brighten + shrink
	_animate_correct_tap(circle)

	# Create particle effect
	_create_particle_effect(circle)

	# Trigger wayang celebration
	_trigger_wayang_celebration()

	print("RhythmGame: Correct tap! Beat ", beat_index, ", total correct: ", correct_beats)

# Animate correct tap (brighten + shrink)
func _animate_correct_tap(circle: ColorRect) -> void:
	var tween = create_tween()
	tween.set_parallel(true)

	# Brighten color
	var original_color = circle.color
	circle.color = original_color.lightened(0.5)
	tween.tween_property(circle, "color", original_color, CORRECT_ANIMATION_DURATION)

	# Shrink scale
	var original_scale = circle.scale
	circle.scale = original_scale * 1.2
	tween.tween_property(circle, "scale", original_scale, CORRECT_ANIMATION_DURATION)

	# Use ease out back for bouncy effect
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

# Create particle effect at circle position
func _create_particle_effect(circle: ColorRect) -> void:
	var circle_global_pos = circle.global_position
	var circle_size = circle.size
	var center = circle_global_pos + circle_size / 2

	for i in range(PARTICLE_COUNT):
		var particle = ColorRect.new()
		particle.color = circle.color.lightened(0.2)
		particle.size = Vector2(8, 8)
		particle.position = center
		particle.z_index = 100

		# Add to scene (add to game content)
		$GameContainer/GameContent.add_child(particle)
		active_particles.append(particle)

		# Animate particle
		var angle = (PI * 2 * i) / PARTICLE_COUNT
		var distance = 60.0
		var target_pos = center + Vector2(cos(angle), sin(angle)) * distance

		var tween = create_tween()
		tween.set_parallel(true)

		# Move outward
		tween.tween_property(particle, "global_position", target_pos, 0.4)

		# Shrink and fade
		tween.tween_property(particle, "size", Vector2.ZERO, 0.4)
		tween.parallel()
		tween.tween_property(particle, "modulate:a", 0.0, 0.4)

		# Remove after animation
		tween.tween_callback(func(): _remove_particle(particle)).set_delay(0.4)

# Remove particle effect
func _remove_particle(particle: Node2D) -> void:
	active_particles.erase(particle)
	if is_instance_valid(particle):
		particle.queue_free()

# Trigger wayang celebration animation
func _trigger_wayang_celebration() -> void:
	if wayang_sprite:
		# Play celebrate animation if available
		if wayang_sprite.sprite_frames and wayang_sprite.sprite_frames.has_animation("celebrate"):
			wayang_sprite.play("celebrate")

			# Return to idle after animation
			var timer = Timer.new()
			timer.wait_time = 1.0
			timer.one_shot = true
			timer.timeout.connect(func():
				if wayang_sprite and wayang_sprite.sprite_frames and wayang_sprite.sprite_frames.has_animation("idle"):
					wayang_sprite.play("idle")
				timer.queue_free()
			)
			add_child(timer)
			timer.start()

# Handle song finished
func _on_song_finished() -> void:
	if not is_playing:
		return

	is_playing = false
	is_transitioning = true

	# Show results
	_show_results()

	# Auto-transition to menu after 3 seconds
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(func():
		GameManager.fade_to_scene("res://scenes/MainMenu.tscn")
		timer.queue_free()
	)
	add_child(timer)
	timer.start()

# Show results
func _show_results() -> void:
	if result_label:
		# Show celebration message
		result_label.text = "Kamu dapat " + str(correct_beats) + "/" + str(total_beats) + " beat!"
		result_label.visible = true

		# Animate the label
		var tween = create_tween()
		result_label.modulate.a = 0.0
		result_label.scale = Vector2(0.5, 0.5)
		tween.set_parallel(true)
		tween.tween_property(result_label, "modulate:a", 1.0, 0.5)
		tween.tween_property(result_label, "scale", Vector2.ONE, 0.5)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)

		# Play celebration sound
		AudioManager.play_sfx("sfx/celebration.ogg")

# Stop music
func _stop_music() -> void:
	if music_player and music_player.playing:
		music_player.stop()

## Cleanup ##

func _exit_tree() -> void:
	# Clean up particles
	for particle in active_particles:
		if is_instance_valid(particle):
			particle.queue_free()
	active_particles.clear()
