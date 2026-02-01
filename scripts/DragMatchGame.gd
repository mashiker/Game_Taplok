extends "res://scripts/GameSceneBase.gd"

# DragMatchGame - Shape matching game with drag and drop
# Children drag shapes to matching slots

class_name DragMatchGame

## Constants ##
const SHAPE_SCENE: PackedScene = preload("res://scenes/Shape.tscn")
const SLOT_SCENE: PackedScene = preload("res://scenes/Slot.tscn")
const MAX_MATCHES: int = 8
const MAX_DURATION: int = 600  # 10 minutes in seconds
const MATCHED_PAIR_REMOVE_DELAY: float = 1.0

## Available shape types ##
const SHAPE_TYPES: Array[String] = ["circle", "square", "triangle", "star", "heart"]

## Variables ##
var shapes: Array[Shape] = []
var slots: Array[Slot] = []
var matched_count: int = 0
var active_shapes_count: int = 2  # Will be set based on progression

const GAME_ID := "drag_match"
const SCENE_PATH := "res://scenes/DragMatchGame.tscn"
var current_level: int = 1

## Node References ##
@onready var shapes_container: HBoxContainer = $GameContainer/GameContent/ShapesContainer
@onready var slots_container: GridContainer = $GameContainer/GameContent/SlotsContainer
@onready var wayang_mascot: AnimatedSprite2D = $GameContainer/TopBar/WayangMascot
@onready var objective_label: Label = $GameContainer/TopBar/ObjectiveLabel
@onready var progress_label: Label = $GameContainer/TopBar/ProgressLabel

## Built-in Functions ##
func _ready() -> void:
	game_name = "DragMatch"
	super._ready()

# Override to set up game-specific initialization
func _on_game_start() -> void:
	super._on_game_start()
	_determine_difficulty()
	_spawn_shapes_and_slots()
	_update_hud()
	if objective_label:
		objective_label.text = TranslationManager.get_text("game_drag_match_description")
	SessionManager.start_session("DragMatch", "cognitive")
	print("Drag Match game started with ", active_shapes_count, " shape pairs")

# Override to add game-specific metrics
func _get_game_metrics() -> Dictionary:
	return {
		"duration": SessionManager.get_session_duration(),
		"actions": matched_count,
		"matches": matched_count,
		"shape_count": active_shapes_count
	}

## Public Functions ##

# Handle shape dropped on slot
func on_shape_dropped(shape: Shape, slot: Slot) -> void:
	if not slot or not slot.accepts_shape(shape):
		# Invalid drop - bounce back (soft error feedback)
		shape.reset_position()
		RewardSystem.reward_error(shape.global_position)
		AudioManager.play_sfx("sfx/gentle.ogg")
		return

	# Valid match!
	_process_match(shape, slot)

## Private Functions ##

# Determine difficulty based on progression
func _determine_difficulty() -> void:
	current_level = ProgressManager.get_level(GAME_ID)
	var cfg := ProgressManager.get_level_config(GAME_ID, current_level)
	active_shapes_count = int(cfg.get("pairs", active_shapes_count))
	print("Drag Match level: ", current_level, " => ", active_shapes_count, " pairs")

# Spawn shape pairs and arrange in scene
func _spawn_shapes_and_slots() -> void:
	# Select random shapes based on difficulty
	var selected_shapes = _get_random_shapes(active_shapes_count)

	# Create slots (in center grid)
	for i in range(selected_shapes.size()):
		var slot = SLOT_SCENE.instantiate() as Slot
		slot.set_slot_type(selected_shapes[i])
		slots.append(slot)
		slots_container.add_child(slot)

	# Create shapes (at bottom)
	# Shuffle shapes so they don't align with slots
	var shuffled_shapes = selected_shapes.duplicate()
	shuffled_shapes.shuffle()

	for i in range(shuffled_shapes.size()):
		var shape = SHAPE_SCENE.instantiate() as Shape
		shape.set_shape_type(shuffled_shapes[i])
		shapes.append(shape)
		shapes_container.add_child(shape)

		# Connect shape signals
		shape.shape_drag_started.connect(_on_shape_drag_started)
		shape.shape_drag_ended.connect(_on_shape_drag_ended)
		shape.shape_matched.connect(_on_shape_matched)

# Get random unique shapes
func _get_random_shapes(count: int) -> Array[String]:
	var available = SHAPE_TYPES.duplicate()
	available.shuffle()

	var result: Array[String] = []
	for i in range(min(count, available.size())):
		result.append(available[i])

	return result

func _update_hud() -> void:
	if progress_label:
		progress_label.text = str(matched_count) + "/" + str(active_shapes_count)

# Process a successful match
func _process_match(shape: Shape, slot: Slot) -> void:
	# Play success audio
	AudioManager.play_sfx("sfx/success.ogg")

	# Play word callout
	var shape_key = "shape_" + shape.shape_type
	var word = TranslationManager.get_text(shape_key)
	AudioManager.play_voice("words/id/bentuk_" + shape.shape_type + ".ogg")

	# Reward feedback
	RewardSystem.reward_success(slot.global_position, 1.0)

	# Animate shape to slot center
	var slot_global = slot.global_position
	var shape_global = shape.get_parent().global_position
	var relative_pos = slot_global - shape_global

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(shape, "position", relative_pos, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(shape, "scale", Vector2.ONE * 1.15, 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(shape, "scale", Vector2.ONE, 0.12).set_delay(0.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Mark slot as filled
	slot.fill()
	slot.show_success()

	# Mark shape as matched
	shape.mark_matched()

	# Update mascot animation
	_play_mascot_celebration()

	# Increment match count
	matched_count += 1
	_update_hud()

	# Record tap
	SessionManager.record_tap()

	# Update progression
	Database.increment_progress("DragMatch", shape.shape_type)

	# Remove matched pair after delay
	await get_tree().create_timer(MATCHED_PAIR_REMOVE_DELAY).timeout
	_remove_matched_pair(shape, slot)

	# Check win condition
	_check_game_end()

# Remove a matched pair from the scene
func _remove_matched_pair(shape: Shape, slot: Slot) -> void:
	if is_instance_valid(shape):
		shape.queue_free()
	if is_instance_valid(slot):
		slot.queue_free()

	shapes.erase(shape)
	slots.erase(slot)

# Play mascot celebration animation
func _play_mascot_celebration() -> void:
	if wayang_mascot and wayang_mascot.sprite_frames:
		if wayang_mascot.sprite_frames.has_animation("dance"):
			wayang_mascot.play("dance")
			# Reset to idle after animation
			await get_tree().create_timer(1.0).timeout
			if wayang_mascot and wayang_mascot.sprite_frames.has_animation("idle"):
				wayang_mascot.play("idle")

# Check if game should end
func _check_game_end() -> void:
	# End when all current pairs are matched
	if matched_count >= active_shapes_count or slots.is_empty():
		_end_game_victory()
		return

	# End after time limit
	if SessionManager.get_session_duration() >= MAX_DURATION:
		_end_game_time_limit()
		return

# End game in victory
func _end_game_victory() -> void:
	print("Drag Match completed! ", matched_count, " matches")
	AudioManager.play_sfx("sfx/celebration.ogg")
	_show_completion_message()

# End game due to time limit
func _end_game_time_limit() -> void:
	print("Drag Match time limit reached. Matches: ", matched_count)
	_show_completion_message()

# Show completion message
func _show_completion_message() -> void:
	var message = TranslationManager.get_text("message_wah_hebat")
	print(message)

	# End session
	SessionManager.end_session()

	# Level completion flow
	await _handle_level_complete(true)

func _handle_level_complete(success: bool) -> void:
	var res := ProgressManager.complete_level(GAME_ID, success)
	var leveled_up: bool = bool(res.get("leveled_up", false))
	var new_level: int = int(res.get("new_level", current_level))
	var max_level: int = int(res.get("max_level", ProgressManager.get_max_level(GAME_ID)))

	var overlay_ps: PackedScene = preload("res://scenes/ui/LevelUpOverlay.tscn")
	var overlay = overlay_ps.instantiate()
	get_tree().root.add_child(overlay)
	if overlay.has_method("setup"):
		overlay.setup(new_level, new_level >= max_level)
	await overlay.finished

	if leveled_up:
		GameManager.fade_to_scene(SCENE_PATH)
	else:
		await get_tree().create_timer(0.6).timeout
		GameManager.fade_to_scene("res://scenes/MainMenu.tscn")

## Signal Callbacks ##

func _on_shape_drag_started(shape: Shape) -> void:
	# Bring dragged shape to front
	shape.z_index = 100

func _on_shape_drag_ended(shape: Shape, slot: Slot) -> void:
	# Reset z-index
	shape.z_index = 0

	# Validate drop
	on_shape_dropped(shape, slot)

func _on_shape_matched(shape: Shape) -> void:
	print("Shape matched: ", shape.shape_type)
