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

## Node References ##
@onready var shapes_container: HBoxContainer = $GameContainer/GameContent/ShapesContainer
@onready var slots_container: GridContainer = $GameContainer/GameContent/SlotsContainer
@onready var wayang_mascot: AnimatedSprite2D = $GameContainer/TopBar/WayangMascot

## Built-in Functions ##
func _ready() -> void:
	game_name = "DragMatch"
	super._ready()

# Override to set up game-specific initialization
func _on_game_start() -> void:
	super._on_game_start()
	_determine_difficulty()
	_spawn_shapes_and_slots()
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
		# Invalid drop - bounce back
		shape.reset_position()
		AudioManager.play_sfx("sfx/gentle.ogg")
		return

	# Valid match!
	_process_match(shape, slot)

## Private Functions ##

# Determine difficulty based on progression
func _determine_difficulty() -> void:
	var times_played = Database.get_game_play_count("DragMatch")

	if times_played < 3:
		active_shapes_count = 2  # Sessions 1-3: 2 shapes
	elif times_played < 8:
		active_shapes_count = 3  # Sessions 4-7: 3 shapes
	else:
		active_shapes_count = 4  # Sessions 8+: 4 shapes

	print("Drag Match difficulty: ", active_shapes_count, " shapes (session #", times_played + 1, ")")

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

	# Connect slot signals
	slot.shape_drag_ended.connect(_on_slot_shape_drag_ended)

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

# Process a successful match
func _process_match(shape: Shape, slot: Slot) -> void:
	# Play success audio
	AudioManager.play_sfx("sfx/success.ogg")

	# Play word callout
	var shape_key = "shape_" + shape.shape_type
	var word = TranslationManager.get_text(shape_key)
	AudioManager.play_voice("words/id/bentuk_" + shape.shape_type + ".ogg")

	# Animate shape to slot center
	var slot_global = slot.global_position
	var shape_global = shape.get_parent().global_position
	var relative_pos = slot_global - shape_global

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(shape, "position", relative_pos, 0.2)

	# Mark slot as filled
	slot.fill()
	slot.show_success()

	# Mark shape as matched
	shape.mark_matched()

	# Update mascot animation
	_play_mascot_celebration()

	# Increment match count
	matched_count += 1

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
	# End after max matches
	if matched_count >= MAX_MATCHES:
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

	# Fade back to menu after delay
	await get_tree().create_timer(3.0).timeout
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
