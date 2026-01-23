extends "res://scripts/GameSceneBase.gd"

# TapPopGame - A game where toddlers tap balloons to pop them
# Balloon count and colors are age-gated for appropriate difficulty

## Constants ##
const MAX_BALLOONS_YOUNG: int = 2  # Ages 2-3
const MAX_BALLOONS_OLDER: int = 3  # Ages 4-5
const RESPAWN_DELAY: float = 1.0  # Seconds before respawn
const SCREEN_MARGIN: int = 200    # Pixels from screen edge

## Balloon Colors ##
const BALLOON_COLORS = {
	"red": Color(0.91, 0.29, 0.24, 1),    # #E84A3D
	"blue": Color(0.22, 0.74, 0.97, 1),   # #38BDF8
	"yellow": Color(0.98, 0.75, 0.14, 1), # #FBBF24
	"green": Color(0.2, 0.83, 0.6, 1)     # #34D399
}

const COLOR_TRANSLATION_KEYS = {
	"red": "color_red",
	"blue": "color_blue",
	"yellow": "color_yellow",
	"green": "color_green"
}

## Audio Paths ##
const POP_SOUND_PATH: String = "sfx/pop_success.ogg"
const COLOR_WORD_PATH_TEMPLATE: String = "words/id/warna_{color}.ogg"

## Variables ##
var balloon_scene: PackedScene = null
var active_balloons: Array[Node] = []
var max_balloons: int = MAX_BALLOONS_YOUNG
var child_age: int = 3
var available_colors: Array[String] = []
var respawn_timer: Timer = null

## Built-in Functions ##
func _ready() -> void:
	game_name = "TapPop"
	super._ready()

	# Load balloon scene
	balloon_scene = load("res://scenes/Balloon.tscn")
	if not balloon_scene:
		push_error("Failed to load Balloon scene")
		return

	# Get child age for age gating
	child_age = _get_child_age()
	_setup_age_gating()

	# Create respawn timer
	respawn_timer = Timer.new()
	respawn_timer.wait_time = RESPAWN_DELAY
	respawn_timer.one_shot = true
	respawn_timer.timeout.connect(_on_respawn_timeout)
	add_child(respawn_timer)

	# Start session
	SessionManager.start_session(game_name, "cognitive")

## Virtual Function Overrides ##

# Called when game starts
func _on_game_start() -> void:
	super._on_game_start()
	_spawn_initial_balloons()

# Called when game ends
func _on_game_end() -> void:
	# Clean up balloons
	for balloon in active_balloons:
		if is_instance_valid(balloon):
			balloon.queue_free()
	active_balloons.clear()

	# End session
	SessionManager.end_session()
	super._on_game_end()

# Get game metrics
func _get_game_metrics() -> Dictionary:
	var base_metrics = super._get_game_metrics()
	base_metrics["game_type"] = "tap_pop"
	base_metrics["balloons_popped"] = SessionManager.get_tap_count()
	return base_metrics

## Private Functions ##

# Get the child's age from GameManager (default to 3 if not set)
func _get_child_age() -> int:
	# Check if GameManager has get_child_age method
	if GameManager.has_method("get_child_age"):
		return GameManager.get_child_age()
	return 3  # Default age

# Set up age-gated content (balloon count and colors)
func _setup_age_gating() -> void:
	if child_age >= 4:
		# Ages 4-5: 3 balloons, all colors
		max_balloons = MAX_BALLOONS_OLDER
		available_colors = ["red", "blue", "yellow", "green"]
	else:
		# Ages 2-3: 2 balloons, limited colors (no green)
		max_balloons = MAX_BALLOONS_YOUNG
		available_colors = ["red", "blue", "yellow"]

	print("Tap Pop: Age ", child_age, " -> ", max_balloons, " balloons, colors: ", available_colors)

# Spawn the initial set of balloons
func _spawn_initial_balloons() -> void:
	for i in range(max_balloons):
		_spawn_balloon()

# Spawn a single balloon at a random position
func _spawn_balloon() -> void:
	if not balloon_scene:
		return

	var balloon = balloon_scene.instantiate()
	var container = $GameContainer/GameContent/BalloonContainer

	if not container:
		push_error("BalloonContainer not found")
		balloon.queue_free()
		return

	# Connect pop signal
	balloon.balloon_popped.connect(_on_balloon_popped)

	# Set random color from available options
	var color_name = available_colors.pick_random()
	balloon.set_balloon_color(BALLOON_COLORS[color_name], color_name)

	# Get container bounds for random positioning
	var container_size = container.get_size()
	var margin = float(SCREEN_MARGIN)

	# Random position within bounds (keeping away from edges)
	var x_range = container_size.x - (2.0 * BALLOON_COLORS.size() * 80.0)  # Approximate balloon spacing
	var y_range = container_size.y - 200.0

	if x_range > 0 and y_range > 0:
		var random_x = randf_range(margin, container_size.x - margin - 80.0)
		var random_y = randf_range(margin, container_size.y - margin - 80.0)
		balloon.position = Vector2(random_x, random_y)
	else:
		# Fallback to center if bounds are too small
		balloon.position = container_size / 2.0

	container.add_child(balloon)
	active_balloons.append(balloon)

# Handle balloon pop event
func _on_balloon_popped(color_name: String) -> void:
	# Record the tap
	SessionManager.record_tap()

	# Find and remove the popped balloon from active list
	var popped_balloon = null
	for balloon in active_balloons:
		if is_instance_valid(balloon) and balloon.get_color_name() == color_name:
			popped_balloon = balloon
			break

	if popped_balloon:
		active_balloons.erase(popped_balloon)
		# Balloon will remove itself after animation completes

	# Play pop sound
	AudioManager.play_sfx(POP_SOUND_PATH)

	# Play color word audio
	var color_key = COLOR_TRANSLATION_KEYS.get(color_name, "")
	if not color_key.is_empty():
		var word = TranslationManager.get_text(color_key)
		print("Color popped: ", word)
		# Audio path: sounds/words/id/warna_{color}.ogg
		var audio_path = COLOR_WORD_PATH_TEMPLATE.format({"color": _color_name_to_indonesian(color_name)})
		AudioManager.play_voice(audio_path)

	# Trigger Wayang celebration (if sprite has animations)
	var wayang = $GameContainer/TopBar/WayangMascot
	if wayang and wayang.has_method("play"):
		if wayang.sprite_frames and wayang.sprite_frames.has_animation("celebrate"):
			wayang.play("celebrate")

	# Check auto-end conditions (60 taps or 10 minutes)
	SessionManager.check_auto_end_conditions()
	if not SessionManager.is_session_active():
		# Session ended, return to menu after a brief delay
		await get_tree().create_timer(1.0).timeout
		GameManager.fade_to_scene("res://scenes/MainMenu.tscn")
		return

	# Start respawn timer
	respawn_timer.start()

# Respawn timer callback - spawn new balloon
func _on_respawn_timeout() -> void:
	if active_balloons.size() < max_balloons:
		_spawn_balloon()

# Convert color name to Indonesian for audio file path
func _color_name_to_indonesian(color_name: String) -> String:
	match color_name:
		"red":
			return "merah"
		"blue":
			return "biru"
		"yellow":
			return "kuning"
		"green":
			return "hijau"
		_:
			return color_name
