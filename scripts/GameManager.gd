extends Node2D

# GameManager - Global autoload singleton for managing game state
# Handles signals, scene transitions, and global game configuration

## Signals ##
signal game_started(game_name: String)
signal game_ended(game_name: String, metrics: Dictionary)
signal reward_trigger(type: String)

## Constants ##
const TRANSITION_DURATION: float = 1.0

## Variables ##
var current_game: String = ""
var is_transitioning: bool = false
var child_age: int = 3  # Default age for age-gating content

## Built-in Functions ##
func _ready() -> void:
	Engine.max_fps = 30  # Cap FPS for consistent performance and battery saving
	_load_child_profile()
	print("PlayTap - Game Edukasi Balita Indonesia")
	print("GameManager initialized")

## Public Functions ##

# Fade to a new scene with a transition effect
# @param scene_path: The path to the scene to load (e.g., "res://scenes/MyGame.tscn")
func fade_to_scene(scene_path: String) -> void:
	if is_transitioning:
		push_warning("Already transitioning, ignoring request")
		return

	is_transitioning = true

	# Create transition tween
	var tween = create_tween()
	tween.set_parallel(false)

	# Fade out (simulate with a black overlay)
	var canvas = CanvasLayer.new()
	add_child(canvas)
	var color_rect = ColorRect.new()
	color_rect.color = Color(0, 0, 0, 0)
	color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(color_rect)

	# Fade to black
	tween.tween_property(color_rect, "color:a", 1.0, TRANSITION_DURATION / 2.0)
	tween.tween_callback(_change_scene.bind(scene_path, color_rect, canvas))

# Internal callback to change scene after fade out
func _change_scene(scene_path: String, color_rect: ColorRect, canvas: CanvasLayer) -> void:
	get_tree().change_scene_to_file(scene_path)

	# Fade in
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 0.0, TRANSITION_DURATION / 2.0)
	tween.tween_callback(_on_transition_complete.bind(canvas))

# Internal callback when transition completes
func _on_transition_complete(canvas: CanvasLayer) -> void:
	canvas.queue_free()
	is_transitioning = false

# Emit game started signal
func start_game(game_name: String) -> void:
	current_game = game_name
	game_started.emit(game_name)
	print("Game started: ", game_name)

# Emit game ended signal with metrics
func end_game(metrics: Dictionary = {}) -> void:
	game_ended.emit(current_game, metrics)
	print("Game ended: ", current_game, " with metrics: ", metrics)
	current_game = ""

# Trigger a reward event
func trigger_reward(type: String) -> void:
	reward_trigger.emit(type)
	print("Reward triggered: ", type)

# Get the child's age from settings (for age-gated content)
# @return: Child's age (2-5), defaults to 3 if not set
func get_child_age() -> int:
	return child_age

# Set the child's age (called from parent dashboard)
# @param age: Child's age (should be 2-5)
func set_child_age(age: int) -> void:
	if age >= 2 and age <= 5:
		child_age = age
		print("Child age set to: ", age)
	else:
		push_warning("Invalid child age: ", age, ". Should be 2-5.")

# Load child profile from settings file
func _load_child_profile() -> void:
	const CHILD_PROFILE_PATH = "user://child_profile.json"
	if FileAccess.file_exists(CHILD_PROFILE_PATH):
		var file = FileAccess.open(CHILD_PROFILE_PATH, FileAccess.READ)
		if file:
			var data = JSON.parse_string(file.get_as_text())
			if data and data.has("age"):
				child_age = data.age
			file.close()
