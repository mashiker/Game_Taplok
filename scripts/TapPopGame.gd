extends "res://scripts/GameSceneBase.gd"

# TapPopGame - A game where toddlers tap balloons to pop them
# Now includes a simple objective loop: pop a target color N times.

## Constants ##
const MAX_BALLOONS_YOUNG: int = 2  # Ages 2-3
const MAX_BALLOONS_OLDER: int = 3  # Ages 4-5
const RESPAWN_DELAY: float = 0.7  # Faster pace
const SCREEN_MARGIN: int = 40     # Pixels from container edge
const POOL_SIZE: int = 10         # Slightly bigger pool

# Round objective
const TARGET_PER_ROUND: int = 5

## Balloon Colors ##
const BALLOON_COLORS = {
	"red": Color(0.91, 0.29, 0.24, 1),
	"blue": Color(0.22, 0.74, 0.97, 1),
	"yellow": Color(0.98, 0.75, 0.14, 1),
	"green": Color(0.2, 0.83, 0.6, 1)
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
var balloon_pool: Array[Node] = []
var max_balloons: int = MAX_BALLOONS_YOUNG
var child_age: int = 3
var available_colors: Array[String] = []
var respawn_timer: Timer = null

# Objective: pop a target color N times
var target_color: String = "red"
var target_goal: int = TARGET_PER_ROUND
var target_progress: int = 0

## Built-in Functions ##
func _ready() -> void:
	game_name = "TapPop"
	super._ready()

	balloon_scene = load("res://scenes/Balloon.tscn")
	if not balloon_scene:
		push_error("Failed to load Balloon scene")
		return

	child_age = _get_child_age()
	_setup_age_gating()
	_initialize_balloon_pool()

	respawn_timer = Timer.new()
	respawn_timer.wait_time = RESPAWN_DELAY
	respawn_timer.one_shot = true
	respawn_timer.timeout.connect(_on_respawn_timeout)
	add_child(respawn_timer)

	SessionManager.start_session(game_name, "cognitive")

	_setup_round()
	_update_hud()

## Virtual Function Overrides ##
func _on_game_start() -> void:
	super._on_game_start()
	_spawn_initial_balloons()

func _on_game_end() -> void:
	for balloon in active_balloons:
		if is_instance_valid(balloon):
			_return_balloon_to_pool(balloon)
	active_balloons.clear()

	SessionManager.end_session()
	super._on_game_end()

func _get_game_metrics() -> Dictionary:
	var base_metrics = super._get_game_metrics()
	base_metrics["game_type"] = "tap_pop"
	base_metrics["balloons_popped"] = SessionManager.get_tap_count()
	base_metrics["target_color"] = target_color
	base_metrics["target_progress"] = target_progress
	return base_metrics

## Round / HUD ##
func _setup_round() -> void:
	# Pick a target color from available pool
	if available_colors.size() == 0:
		available_colors = ["red", "blue", "yellow"]
	target_color = available_colors.pick_random()
	target_goal = TARGET_PER_ROUND
	target_progress = 0

	# Optional: voice prompt (if audio exists)
	var audio_path = COLOR_WORD_PATH_TEMPLATE.format({"color": _color_name_to_indonesian(target_color)})
	AudioManager.play_voice(audio_path)

func _update_hud() -> void:
	var target_label = $GameContainer/HUD/TargetLabel
	var progress_label = $GameContainer/HUD/ProgressLabel

	if target_label:
		var color_key = COLOR_TRANSLATION_KEYS.get(target_color, "")
		var word = TranslationManager.get_text(color_key) if not color_key.is_empty() else target_color
		target_label.text = "Pop: %s" % word

	if progress_label:
		progress_label.text = "%d/%d" % [target_progress, target_goal]

func _on_round_complete() -> void:
	# Celebrate bigger
	RewardSystem.reward_success(get_viewport().get_visible_rect().size / 2.0, 2.0)
	AudioManager.play_sfx(POP_SOUND_PATH)

	# Start a new round after a short delay
	await get_tree().create_timer(0.8).timeout
	_setup_round()
	_update_hud()

## Pool / Spawning ##
func _initialize_balloon_pool() -> void:
	var container = $GameContainer/GameContent/BalloonContainer
	if not container:
		push_error("BalloonContainer not found for pool initialization")
		return

	for i in range(POOL_SIZE):
		var balloon = balloon_scene.instantiate()
		balloon.visible = false
		balloon.set_process(false)
		balloon.set_physics_process(false)
		container.add_child(balloon)
		balloon_pool.append(balloon)

func _get_balloon_from_pool() -> Node:
	if balloon_pool.size() > 0:
		var balloon = balloon_pool.pop_back()
		balloon.visible = true
		balloon.set_process(true)
		balloon.set_physics_process(true)
		balloon.modulate = Color.WHITE
		balloon.scale = Vector2.ONE
		return balloon
	return balloon_scene.instantiate()

func _return_balloon_to_pool(balloon: Node) -> void:
	if balloon_pool.size() < POOL_SIZE:
		balloon.visible = false
		balloon.set_process(false)
		balloon.set_physics_process(false)
		balloon.position = Vector2(-1000, -1000)
		balloon_pool.append(balloon)
	else:
		balloon.queue_free()

func _spawn_initial_balloons() -> void:
	for i in range(max_balloons):
		_spawn_balloon()

func _spawn_balloon() -> void:
	if not balloon_scene:
		return

	var balloon = _get_balloon_from_pool()
	var container = $GameContainer/GameContent/BalloonContainer
	if not container:
		push_error("BalloonContainer not found")
		balloon.queue_free()
		return

	# Connect pop signal
	if balloon.balloon_popped.is_connected(_on_balloon_popped):
		balloon.balloon_popped.disconnect(_on_balloon_popped)
	balloon.balloon_popped.connect(_on_balloon_popped.bind(balloon))

	# Color selection
	var color_name = available_colors.pick_random()
	balloon.set_balloon_color(BALLOON_COLORS[color_name], color_name)

	# Random position within bounds
	var rect = container.get_rect()
	var margin = float(SCREEN_MARGIN)
	var random_x = randf_range(margin, rect.size.x - margin)
	var random_y = randf_range(margin, rect.size.y - margin)
	balloon.position = Vector2(random_x, random_y)

	if balloon.get_parent() != container:
		container.add_child(balloon)
	active_balloons.append(balloon)

# Handle balloon pop
func _on_balloon_popped(color_name: String, balloon: Node) -> void:
	SessionManager.record_tap()

	# Remove from active
	if balloon and is_instance_valid(balloon):
		active_balloons.erase(balloon)
		_await_and_return_balloon(balloon)

	# Objective progress
	if color_name == target_color:
		target_progress += 1
		_update_hud()
		RewardSystem.reward_success(balloon.global_position if balloon else get_viewport().get_mouse_position(), 1.3)
		if target_progress >= target_goal:
			_on_round_complete()

	# Base feedback
	RewardSystem.reward_tap(balloon.global_position if balloon else get_viewport().get_mouse_position())

	AudioManager.play_sfx(POP_SOUND_PATH)

	# Voice callout (if exists)
	var audio_path = COLOR_WORD_PATH_TEMPLATE.format({"color": _color_name_to_indonesian(color_name)})
	AudioManager.play_voice(audio_path)

	# Auto-end check
	SessionManager.check_auto_end_conditions()
	if not SessionManager.is_session_active():
		await get_tree().create_timer(1.0).timeout
		GameManager.fade_to_scene("res://scenes/MainMenu.tscn")
		return

	respawn_timer.start()

func _on_respawn_timeout() -> void:
	if active_balloons.size() < max_balloons:
		_spawn_balloon()

func _get_child_age() -> int:
	if GameManager.has_method("get_child_age"):
		return GameManager.get_child_age()
	return 3

func _setup_age_gating() -> void:
	if child_age >= 4:
		max_balloons = MAX_BALLOONS_OLDER
		available_colors = ["red", "blue", "yellow", "green"]
	else:
		max_balloons = MAX_BALLOONS_YOUNG
		available_colors = ["red", "blue", "yellow"]

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

func _await_and_return_balloon(balloon: Node) -> void:
	if is_instance_valid(balloon):
		await get_tree().create_timer(0.22).timeout
		_return_balloon_to_pool(balloon)
