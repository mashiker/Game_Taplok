extends "res://scripts/GameSceneBase.gd"

# ShapeMatchGame - Shape Silhouette matching game (US-026, US-027)
# Children drag shapes to match silhouettes of Rumah Adat, Hewan, etc.

class_name ShapeMatchGame

## Constants ##
const DRAG_DEADZONE: float = 10.0  # pixels to move before drag activates
const DRAG_OPACITY: float = 0.7  # opacity during drag
const DRAG_SCALE: float = 1.1  # scale during drag
const CORRECT_ANIMATION_DURATION: float = 0.5  # seconds for slide+scale
const COLOR_FILL_DURATION: float = 0.3  # seconds for silhouette color fill
const AUTO_TRANSITION_DELAY: float = 1.5  # seconds before next puzzle
const PUZZLES_PER_SESSION_MIN: int = 5
const PUZZLES_PER_SESSION_MAX: int = 7
const MAX_SESSION_DURATION: int = 600  # 10 minutes in seconds

## Content Sets ##
# Rumah Adat (sessions 1-2)
var content_rumah_adat: Array = [
	{"id": "joglo", "name": "Rumah Joglo", "color": Color(0.8, 0.6, 0.4)},
	{"id": "gadang", "name": "Rumah Gadang", "color": Color(0.6, 0.4, 0.6)},
	{"id": "tongkonan", "name": "Rumah Tongkonan", "color": Color(0.6, 0.5, 0.3)},
	{"id": "kampoeng", "name": "Rumah Kampoeng", "color": Color(0.7, 0.5, 0.3)}
]

# Hewan (sessions 3-4)
var content_hewan: Array = [
	{"id": "komodo", "name": "Komodo", "color": Color(0.7, 0.6, 0.4)},
	{"id": "orangutan", "name": "Orangutan", "color": Color(0.6, 0.4, 0.3)},
	{"id": "burung", "name": "Burung", "color": Color(0.4, 0.6, 0.7)},
	{"id": "paus", "name": "Paus", "color": Color(0.3, 0.4, 0.7)}
]

# Mix (sessions 5+)
var content_mix: Array = []

## Variables ##
# game_name and is_active provided by GameSceneBase
var session_number: int = 1
var puzzles_completed: int = 0
var puzzles_in_session: int = 0
var session_start_time: int = 0

var current_puzzle: Dictionary = {}
var current_content_set: Array = []
var puzzle_index: int = 0

# Drag state
var is_dragging: bool = false
var drag_target: Control = null
var drag_start_pos: Vector2 = Vector2.ZERO
var drag_offset: Vector2 = Vector2.ZERO
var original_position: Vector2 = Vector2.ZERO

var correct_answer_id: String = ""
var is_transitioning: bool = false

## Built-in Functions ##
func _ready() -> void:
	game_name = "Shape Silhouette"
	_setup_content_mix()
	super._ready()

	# Connect input handlers for each option
	var options_container = $GameContainer/GameContent/OptionsContainer
	for i in range(4):
		var option = options_container.get_child(i)
		if option and not option.gui_input.is_connected(_on_option_gui_input):
			option.gui_input.connect(_on_option_gui_input.bind(option))

	_update_hud()

func _process(_delta: float) -> void:
	if is_active:
		_check_session_duration()

func _input(event: InputEvent) -> void:
	if not is_active or is_transitioning:
		return

	# Handle drag release
	if is_dragging and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_on_drag_release()

## Virtual Functions (override from GameSceneBase) ##
func _on_game_start() -> void:
	super._on_game_start()
	SessionManager.start_session(game_name, "cognitive")

	session_start_time = Time.get_unix_time_from_system()

	# Get session number from database or default to 1
	session_number = _get_session_number()

	# Determine content set based on session number
	_determine_content_set()

	# Set up puzzles for this session
	puzzles_in_session = randi_range(PUZZLES_PER_SESSION_MIN, PUZZLES_PER_SESSION_MAX)
	puzzles_completed = 0
	puzzle_index = 0

	# Shuffle content set
	current_content_set.shuffle()

	# Load first puzzle
	_load_puzzle()
	_update_hud()

	print("Shape Silhouette started - Session ", session_number, " with ", puzzles_in_session, " puzzles")

func _on_game_end() -> void:
	super._on_game_end()
	SessionManager.end_session()

func _get_game_metrics() -> Dictionary:
	var duration = 0
	if session_start_time > 0:
		duration = int(Time.get_unix_time_from_system() - session_start_time)
	return {
		"duration": duration,
		"puzzles_completed": puzzles_completed,
		"session_number": session_number
	}

## Private Functions ##

# Set up mixed content for sessions 5+
func _setup_content_mix() -> void:
	content_mix = []
	content_mix.append_array(content_rumah_adat)
	content_mix.append_array(content_hewan)
	content_mix.shuffle()

# Set up UI elements with translations
func _setup_ui() -> void:
	var back_button = $GameContainer/TopBar/BackButton
	if back_button:
		back_button.text = TranslationManager.get_text("back")

	# Set up option shapes
	var options = $GameContainer/GameContent/OptionsContainer
	if options:
		for i in range(4):
			var option = options.get_child(i)
			if option:
				option.name = "Option" + str(i + 1)

# Connect signals
func _connect_signals() -> void:
	var back_button = $GameContainer/TopBar/BackButton
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

# Get session number from database
func _get_session_number() -> int:
	# Query database for number of previous sessions
	# For now, default to 1
	return 1

# Determine content set based on session number
func _determine_content_set() -> void:
	if session_number <= 2:
		current_content_set = content_rumah_adat.duplicate()
		SessionManager.set_metric("content_category", "rumah_adat")
	elif session_number <= 4:
		current_content_set = content_hewan.duplicate()
		SessionManager.set_metric("content_category", "hewan")
	else:
		current_content_set = content_mix.duplicate()
		SessionManager.set_metric("content_category", "mixed")

# Load a new puzzle
func _load_puzzle() -> void:
	if puzzle_index >= current_content_set.size():
		# Restart content set if we've used all items
		current_content_set.shuffle()
		puzzle_index = 0

	# Get current puzzle item
	var puzzle_item = current_content_set[puzzle_index]
	current_puzzle = puzzle_item.duplicate()
	correct_answer_id = puzzle_item.id

	# Update silhouette tint (dark placeholder)
	var silhouette = $GameContainer/GameContent/SilhouetteContainer/SilhouettePlaceholder
	if silhouette:
		silhouette.modulate = Color(0.75, 0.8, 0.95, 1)
		silhouette.set_meta("answer_id", correct_answer_id)

	# Set up answer options
	var options_container = $GameContainer/GameContent/OptionsContainer
	var answer_index = randi() % 4  # Random position for correct answer

	var used_ids = [correct_answer_id]
	var options = []

	# Pick 3 other items as distractors
	var distractors = current_content_set.duplicate()
	distractors.erase(puzzle_item)
	distractors.shuffle()

	# Create options array with correct answer at random position
	for i in range(4):
		if i == answer_index:
			options.append(puzzle_item)
		else:
			if distractors.size() > 0:
				var d = distractors.pop_front()
				options.append(d)
				used_ids.append(d.id)

	# Set up option nodes
	for i in range(4):
		var option_node = options_container.get_child(i)
		if option_node:
			var tile := option_node.get_node("Tile") as TextureRect
			var icon := option_node.get_node("Icon") as TextureRect
			var shape_area = option_node.get_node("ShapeArea")

			if tile:
				tile.modulate = options[i].color
				tile.z_index = 0

			if icon:
				var icon_path := "res://assets/textures/games/shape_match/icon_%s_256.png" % options[i].id
				if ResourceLoader.exists(icon_path):
					icon.texture = load(icon_path)
					icon.modulate = Color(1, 1, 1, 1)

			# Store answer ID in the area for validation
			if shape_area:
				shape_area.set_meta("answer_id", options[i].id)
				shape_area.set_meta("color", options[i].color)

			# Reset position
			option_node.position = Vector2.ZERO
			option_node.scale = Vector2(1, 1)
			option_node.modulate = Color(1, 1, 1, 1)

# Check session duration (10 minute limit)
func _check_session_duration() -> void:
	var duration = int(Time.get_unix_time_from_system() - session_start_time)
	if duration >= MAX_SESSION_DURATION:
		_end_session("duration")

# Handle drag start
func _on_drag_start(option: Control, event_pos: Vector2) -> void:
	if is_dragging or is_transitioning:
		return

	var shape_area = option.get_node("ShapeArea")
	if not shape_area:
		return

	is_dragging = true
	drag_target = option
	drag_start_pos = event_pos
	original_position = option.position

	# Get local position
	var local_pos = option.to_local(event_pos)
	drag_offset = option.position - local_pos

	# Apply drag visual effects
	option.modulate.a = DRAG_OPACITY
	option.scale = Vector2(DRAG_SCALE, DRAG_SCALE)
	option.z_index = 100  # Bring to front

# Handle drag motion
func _on_drag_motion(event_pos: Vector2) -> void:
	if not is_dragging or drag_target == null:
		return

	# Check if we've moved past deadzone
	var move_distance = event_pos.distance_to(drag_start_pos)
	if move_distance < DRAG_DEADZONE:
		return

	# Move the shape with cursor
	var local_pos = drag_target.get_parent().to_local(event_pos)
	drag_target.position = local_pos + drag_offset

# Handle drag release
func _on_drag_release() -> void:
	if not is_dragging or drag_target == null:
		return

	var shape_area = drag_target.get_node("ShapeArea")
	if not shape_area:
		_reset_drag()
		return

	var answer_id = shape_area.get_meta("answer_id", "")

	# Check if dropped on silhouette
	if _check_drop_on_silhouette():
		if answer_id == correct_answer_id:
			_on_correct_answer()
		else:
			_on_incorrect_answer()
	else:
		_reset_drag()

# Check if shape is dropped on silhouette
func _check_drop_on_silhouette() -> bool:
	var silhouette = $GameContainer/GameContent/SilhouetteContainer/SilhouettePlaceholder
	if not silhouette or not drag_target:
		return false

	var silhouette_global = silhouette.global_position
	var silhouette_size = silhouette.size
	var shape_global = drag_target.global_position
	var shape_size = drag_target.size

	# Simple AABB overlap check
	var overlap_x = (shape_global.x < silhouette_global.x + silhouette_size.x) and \
					(shape_global.x + shape_size.x > silhouette_global.x)
	var overlap_y = (shape_global.y < silhouette_global.y + silhouette_size.y) and \
					(shape_global.y + shape_size.y > silhouette_global.y)

	return overlap_x and overlap_y

# Handle correct answer
func _on_correct_answer() -> void:
	is_transitioning = true

	var silhouette = $GameContainer/GameContent/SilhouetteContainer/SilhouettePlaceholder
	var shape_area = drag_target.get_node("ShapeArea")
	var shape_color = shape_area.get_meta("color", Color.WHITE)

	# Animate shape into silhouette
	var tween = create_tween()
	tween.set_parallel(true)

	# Slide to silhouette center
	var silhouette_center = silhouette.global_position + silhouette.size / 2
	var target_pos = silhouette.to_local(silhouette_center) - drag_target.size / 2

	tween.tween_property(drag_target, "position", target_pos, CORRECT_ANIMATION_DURATION)
	tween.tween_property(drag_target, "scale", Vector2(1, 1), CORRECT_ANIMATION_DURATION)
	tween.tween_property(drag_target, "modulate:a", 1.0, CORRECT_ANIMATION_DURATION)

	# Fill silhouette tint with the chosen color after animation
	await tween.finished
	tween = create_tween()
	tween.tween_property(silhouette, "modulate", shape_color, COLOR_FILL_DURATION)

	# Reward feedback
	RewardSystem.reward_success(silhouette.global_position + (silhouette.size * 0.5), 1.1)

	# Play success SFX
	AudioManager.play_sfx("success.ogg")

	# Play voice callout if available
	var voice_path = "words/id/" + correct_answer_id + ".ogg"
	AudioManager.play_voice(voice_path)

	# Wayang celebration animation
	_trigger_wayang_celebration()

	# Record tap
	SessionManager.record_tap()
	puzzles_completed += 1
	_update_hud()

	# Wait then transition
	await get_tree().create_timer(AUTO_TRANSITION_DELAY).timeout
	_next_puzzle()

# Handle incorrect answer
func _on_incorrect_answer() -> void:
	# Soft error feedback
	if drag_target:
		RewardSystem.reward_error(drag_target.global_position + (drag_target.size * 0.5))

	# Play gentle SFX
	AudioManager.play_sfx("gentle.ogg")

	# Bounce back animation
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(drag_target, "position", original_position, 0.3)
	tween.tween_property(drag_target, "scale", Vector2(1, 1), 0.3)
	tween.tween_property(drag_target, "modulate:a", 1.0, 0.3)

	await tween.finished

	is_dragging = false
	drag_target = null
	is_transitioning = false

# Reset drag state
func _reset_drag() -> void:
	if drag_target == null:
		is_dragging = false
		return

	var tween = create_tween()
	tween.tween_property(drag_target, "position", original_position, 0.2)
	tween.tween_property(drag_target, "scale", Vector2(1, 1), 0.2)
	tween.tween_property(drag_target, "modulate:a", 1.0, 0.2)

	await tween.finished

	drag_target.z_index = 0

	is_dragging = false
	drag_target = null

# Trigger Wayang celebration animation
func _trigger_wayang_celebration() -> void:
	var wayang = $GameContainer/TopBar/WayangMascot
	if wayang and wayang is AnimatedSprite2D:
		# Play celebration animation if available
		if wayang.sprite_frames and wayang.sprite_frames.has_animation("celebrate"):
			wayang.play("celebrate")

# Move to next puzzle or end session
func _next_puzzle() -> void:
	puzzle_index += 1

	# Check if session is complete
	if puzzles_completed >= puzzles_in_session:
		_end_session("complete")
	else:
		is_transitioning = false
		_load_puzzle()

# End the session
func _end_session(reason: String) -> void:
	print("Session ended: ", reason)
	_on_game_end()

	# Show completion message if completed all puzzles
	if reason == "complete":
		_show_completion_message()

	# Return to main menu after short delay
	await get_tree().create_timer(2.0).timeout
	GameManager.fade_to_scene("res://scenes/MainMenu.tscn")

# Show completion message
func _show_completion_message() -> void:
	# Could add a celebration message here
	print("Puzzles completed: ", puzzles_completed)

func _update_hud() -> void:
	var obj := $GameContainer/TopBar/ObjectiveLabel
	var prog := $GameContainer/TopBar/ProgressLabel
	if obj:
		obj.text = "Cocokkan bayangan"
	if prog:
		prog.text = str(puzzles_completed) + "/" + str(puzzles_in_session)

## Signal Callbacks ##

# Handle gui_input for option dragging
func _on_option_gui_input(option: Control, event: InputEvent) -> void:
	if not is_active or is_transitioning:
		return

	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_on_drag_start(option, event.global_position)

	elif event is InputEventMouseMotion and is_dragging and drag_target == option:
		_on_drag_motion(event.global_position)

# Handle back button press
func _on_back_pressed() -> void:
	_on_game_end()
	GameManager.fade_to_scene("res://scenes/MainMenu.tscn")
