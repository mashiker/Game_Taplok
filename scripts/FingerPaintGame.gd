extends "res://scripts/GameSceneBase.gd"

class_name FingerPaintGame

# FingerPaintGame - Drawing game for toddlers
# Allows free-form drawing with color selection and brush sizes

## Constants ##
const CANVAS_WIDTH: int = 800
const CANVAS_HEIGHT: int = 600
const MAX_STROKES: int = 500
const HAPTIC_INTERVAL_MS: int = 50  # ~20Hz for haptic feedback

## Color Palette ##
const COLORS: Array[Color] = [
	Color.RED,        # Red
	Color.BLUE,       # Blue
	Color.YELLOW,     # Yellow
	Color.GREEN,      # Green
	Color.PINK,       # Pink
	Color.ORANGE,     # Orange
	Color.PURPLE,     # Purple
	Color.BLACK       # Black
]

const COLOR_NAMES: Array[String] = [
	"red", "blue", "yellow", "green", "pink", "orange", "purple", "black"
]

## Brush Sizes ##
const BRUSH_SIZES: Array[int] = [10, 20, 30]

## Variables ##
var canvas: ColorRect
var canvas_texture: ImageTexture
var canvas_image: Image
var current_color: Color = Color.BLACK
var current_brush_size: int = 20
var is_drawing: bool = false
var last_point: Vector2 = Vector2.ZERO
var strokes: Array[Dictionary] = []  # Array of stroke dictionaries
var current_stroke: Array[Vector2] = []
var haptic_timer: float = 0.0
var color_buttons: Array[Button] = []
var brush_size_buttons: Array[Button] = []

var _strokes_done: int = 0
var _target_strokes: int = 5
var _goal_rewarded: bool = false
const GAME_ID := "finger_paint"
const SCENE_PATH := "res://scenes/FingerPaintGame.tscn"
var current_level: int = 1
var goal_type: String = "free"
var goal_value: int = 0

## UI References ##
@onready var color_palette_container: HBoxContainer
@onready var brush_size_container: HBoxContainer
@onready var save_button: Button
@onready var clear_button: Button
@onready var save_label: Label

## Built-in Functions ##
func _ready() -> void:
	super._ready()
	game_name = "FingerPaint"
	Engine.max_fps = 30  # Cap FPS for drawing performance
	_update_hud()
	_apply_level_config()
	_setup_canvas()
	_setup_ui_elements()
	_create_paintings_directory()

func _input(event: InputEvent) -> void:
	if not is_active:
		return

	if event is InputEventMouseMotion:
		_handle_mouse_motion(event)
	elif event is InputEventMouseButton:
		_handle_mouse_button(event)

func _process(delta: float) -> void:
	if is_drawing:
		haptic_timer += delta
		if haptic_timer >= (HAPTIC_INTERVAL_MS / 1000.0):
			haptic_timer = 0.0
			_trigger_haptic()

## GameSceneBase Override ##
func _on_game_start() -> void:
	super._on_game_start()
	SessionManager.start_session("FingerPaint")

func _on_game_end() -> void:
	super._on_game_end()
	SessionManager.end_session()

## Public Functions ##

# Change the current drawing color
func set_color(color_idx: int) -> void:
	if color_idx >= 0 and color_idx < COLORS.size():
		current_color = COLORS[color_idx]
		_update_color_buttons()

# Change the current brush size
func set_brush_size(size_idx: int) -> void:
	if size_idx >= 0 and size_idx < BRUSH_SIZES.size():
		current_brush_size = BRUSH_SIZES[size_idx]
		_update_brush_size_buttons()

# Clear the canvas with confirmation dialog
func clear_canvas() -> void:
	_show_clear_dialog()

# Save the current painting
func save_painting() -> void:
	var timestamp = Time.get_unix_time_from_system()
	var filename = "painting_%d.png" % timestamp
	var filepath = "user://paintings/%s" % filename

	# Ensure paintings directory exists
	DirAccess.make_dir_absolute("user://paintings")

	# Save the image
	var save_error = canvas_image.save_png(filepath)
	if save_error != OK:
		push_error("Failed to save painting: ", filepath)
		return

	# Save to database
	Database.save_painting("FingerPaint", filepath)

	# Reward feedback
	RewardSystem.reward_success(get_viewport().get_visible_rect().size * 0.5, 1.6)

	# Show save confirmation
	_show_save_confirmation()

	# Trigger level completion on successful save
	if _strokes_done >= _target_strokes:
		await _handle_level_complete(true)

# Cancel clear dialog
func _on_clear_dialog_cancelled() -> void:
	pass

## Private Functions ##

func _apply_level_config() -> void:
	var pm: Node = get_node_or_null("/root/ProgressManager")
	current_level = int(pm.get_level(GAME_ID)) if pm else 1
	var cfg: Dictionary = pm.get_level_config(GAME_ID, current_level) if pm else {}
	if cfg.is_empty():
		# Default level 1: free mode
		goal_type = "free"
		goal_value = 0
	else:
		goal_type = str(cfg.get("goal_type", "free"))
		goal_value = int(cfg.get("goal_value", 0))
		# Reset goal tracking based on new goal type
		_strokes_done = 0
		_goal_rewarded = false
		match goal_type:
			"free":
				_target_strokes = 999999
			"dot_count":
				_target_strokes = goal_value
			"line_count":
				_target_strokes = goal_value
			"fill_area":
				_target_strokes = 999999

# Set up the drawing canvas
func _setup_canvas() -> void:
	canvas = ColorRect.new()
	canvas.color = Color.WHITE
	canvas.custom_minimum_size = Vector2(CANVAS_WIDTH, CANVAS_HEIGHT)
	canvas.z_index = 0
	$GameContainer/GameContent.add_child(canvas)
	canvas.size = Vector2(CANVAS_WIDTH, CANVAS_HEIGHT)

	# Center the canvas in the game content
	canvas.position = Vector2(
		($GameContainer/GameContent.size.x - CANVAS_WIDTH) / 2,
		($GameContainer/GameContent.size.y - CANVAS_HEIGHT) / 2
	)

	# Create image for drawing
	canvas_image = Image.create(CANVAS_WIDTH, CANVAS_HEIGHT, false, Image.FORMAT_RGBA8)
	canvas_image.fill(Color.WHITE)

	# Create texture from image
	canvas_texture = ImageTexture.new()
	canvas_texture.set_image(canvas_image)

	# Set up the canvas for drawing
	canvas.mouse_filter = Control.MOUSE_FILTER_PASS
	canvas.gui_input.connect(_on_canvas_input)

# Set up UI elements (colors, brush sizes, buttons)
func _setup_ui_elements() -> void:
	var game_content = $GameContainer/GameContent

	# Color palette at bottom
	color_palette_container = HBoxContainer.new()
	color_palette_container.name = "ColorPalette"
	color_palette_container.position = Vector2(
		(game_content.size.x - 360) / 2,
		game_content.size.y - 80
	)
	_create_color_buttons()
	game_content.add_child(color_palette_container)

	# Brush size buttons
	brush_size_container = HBoxContainer.new()
	brush_size_container.name = "BrushSizes"
	brush_size_container.position = Vector2(
		20,
		game_content.size.y - 80
	)
	_create_brush_size_buttons()
	game_content.add_child(brush_size_container)

	# Clear button
	clear_button = Button.new()
	clear_button.text = "Hapus"
	clear_button.custom_minimum_size = Vector2(80, 40)
	clear_button.position = Vector2(
		20,
		game_content.size.y - 140
	)
	clear_button.pressed.connect(_on_clear_pressed)
	game_content.add_child(clear_button)

	# Save button
	save_button = Button.new()
	save_button.text = "Simpan"
	save_button.custom_minimum_size = Vector2(80, 40)
	save_button.position = Vector2(
		game_content.size.x - 100,
		game_content.size.y - 80
	)
	save_button.pressed.connect(save_painting)
	game_content.add_child(save_button)

	# Save confirmation label (hidden by default)
	save_label = Label.new()
	save_label.text = "Gambar Tersimpan!"
	save_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	save_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	save_label.add_theme_color_override("font_color", Color.GREEN)
	save_label.add_theme_font_size_override("font_size", 24)
	save_label.size = Vector2(300, 60)
	save_label.position = Vector2(
		(game_content.size.x - 300) / 2,
		(game_content.size.y - 60) / 2
	)
	save_label.visible = false
	game_content.add_child(save_label)

# Create color palette buttons
func _create_color_buttons() -> void:
	for i in range(COLORS.size()):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(40, 40)
		btn.pressed.connect(_on_color_pressed.bind(i))

		# Create circular color indicator
		var color_rect = ColorRect.new()
		color_rect.color = COLORS[i]
		color_rect.custom_minimum_size = Vector2(36, 36)
		color_rect.position = Vector2(2, 2)
		btn.add_child(color_rect)

		# Make button circular
		var style_box = StyleBoxFlat.new()
		style_box.corner_radius_top_left = 18
		style_box.corner_radius_top_right = 18
		style_box.corner_radius_bottom_left = 18
		style_box.corner_radius_bottom_right = 18
		btn.add_theme_stylebox_override("normal", style_box)

		color_palette_container.add_child(btn)
		color_buttons.append(btn)

	# Highlight black (default)
	_update_color_buttons()

# Create brush size buttons
func _create_brush_size_buttons() -> void:
	var sizes = ["Kecil", "Sedang", "Besar"]
	for i in range(BRUSH_SIZES.size()):
		var btn = Button.new()
		btn.text = sizes[i]
		btn.custom_minimum_size = Vector2(60, 40)
		btn.pressed.connect(_on_brush_size_pressed.bind(i))
		brush_size_container.add_child(btn)
		brush_size_buttons.append(btn)

	# Highlight medium (default)
	_update_brush_size_buttons()

# Handle canvas input for drawing
func _on_canvas_input(event: InputEvent) -> void:
	if not is_active:
		return

	if event is InputEventMouseMotion:
		_handle_mouse_motion(event)
	elif event is InputEventMouseButton:
		_handle_mouse_button(event)

# Handle mouse motion for drawing
func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if not is_drawing:
		return

	var local_pos = canvas.get_local_mouse_position()

	# Check if within canvas bounds
	if local_pos.x < 0 or local_pos.x >= CANVAS_WIDTH or local_pos.y < 0 or local_pos.y >= CANVAS_HEIGHT:
		return

	if last_point == Vector2.ZERO:
		last_point = local_pos
		current_stroke.append(local_pos)
		return

	# Draw line from last point to current point
	_draw_line_on_canvas(last_point, local_pos, current_color, current_brush_size)

	# Store point in current stroke (with smoothing - average every 2 points)
	current_stroke.append(local_pos)
	if current_stroke.size() >= 2:
		var avg_point = (current_stroke[current_stroke.size() - 2] + current_stroke[current_stroke.size() - 1]) / 2
		current_stroke[current_stroke.size() - 1] = avg_point

	last_point = local_pos

# Handle mouse button press/release
func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if not event.button_index == MOUSE_BUTTON_LEFT:
		return

	var local_pos = canvas.get_local_mouse_position()

	# Check if within canvas bounds
	if local_pos.x < 0 or local_pos.x >= CANVAS_WIDTH or local_pos.y < 0 or local_pos.y >= CANVAS_HEIGHT:
		return

	if event.pressed:
		is_drawing = true
		last_point = local_pos
		current_stroke = [local_pos]
		haptic_timer = 0.0
		_trigger_haptic()
	else:
		if is_drawing and current_stroke.size() > 0:
			# Save the stroke
			_stroke_to_array()
			_strokes_done += 1
			RewardSystem.reward_success(canvas.global_position + local_pos, 0.7)
			_update_hud()
		is_drawing = false
		last_point = Vector2.ZERO
		current_stroke = []

# Draw a line on the canvas image with anti-aliasing
func _draw_line_on_canvas(from: Vector2, to: Vector2, color: Color, width: int) -> void:
	var distance = from.distance_to(to)
	if distance < 1:
		_draw_circle_on_canvas(from, width / 2, color)
		return

	var steps = int(distance)
	for i in range(steps + 1):
		var t = float(i) / float(steps)
		var point = from.lerp(to, t)
		_draw_circle_on_canvas(point, width / 2, color)

	# Update texture
	canvas_texture.set_image(canvas_image)

# Draw a filled circle at position
func _draw_circle_on_canvas(center: Vector2, radius: int, color: Color) -> void:
	var x_start = max(0, int(center.x) - radius)
	var x_end = min(CANVAS_WIDTH, int(center.x) + radius + 1)
	var y_start = max(0, int(center.y) - radius)
	var y_end = min(CANVAS_HEIGHT, int(center.y) + radius + 1)

	for y in range(y_start, y_end):
		for x in range(x_start, x_end):
			var dist = Vector2(x, y).distance_to(center)
			if dist <= float(radius):
				# Anti-aliasing at edges
				var alpha = 1.0
				if dist > float(radius) - 1.5:
					alpha = float(radius) - dist + 0.5
					alpha = clamp(alpha, 0.0, 1.0)

				var pixel_color = color
				pixel_color.a = alpha
				canvas_image.set_pixel(x, y, pixel_color)

# Store current stroke in strokes array
func _stroke_to_array() -> void:
	var stroke_data = {
		"points": current_stroke.duplicate(),
		"color": current_color,
		"size": current_brush_size
	}
	strokes.append(stroke_data)

	# Limit stroke count
	if strokes.size() > MAX_STROKES:
		strokes.pop_front()

# Redraw all strokes (for undo/redo functionality if needed)
func _redraw_all_strokes() -> void:
	canvas_image.fill(Color.WHITE)
	for stroke in strokes:
		var points = stroke["points"]
		var stroke_color = stroke["color"]
		var stroke_size = stroke["size"]

		if points.size() < 2:
			if points.size() == 1:
				_draw_circle_on_canvas(points[0], stroke_size / 2, stroke_color)
		else:
			for i in range(points.size() - 1):
				_draw_line_on_canvas(points[i], points[i + 1], stroke_color, stroke_size)

	canvas_texture.set_image(canvas_image)

func _update_hud() -> void:
	var obj := $GameContainer/TopBar/ObjectiveLabel
	var prog := $GameContainer/TopBar/ProgressLabel
	if obj:
		obj.text = "Buat coretan"
	if prog:
		prog.text = str(min(_strokes_done, _target_strokes)) + "/" + str(_target_strokes)

	if not _goal_rewarded and _strokes_done >= _target_strokes:
		_goal_rewarded = true
		RewardSystem.reward_success(get_viewport().get_visible_rect().size * 0.5, 1.5)

# Trigger haptic feedback
func _trigger_haptic() -> void:
	if OS.has_feature("android") or OS.has_feature("ios"):
		Input.vibrate_handheld(20)

# Update color button highlighting
func _update_color_buttons() -> void:
	for i in range(color_buttons.size()):
		var btn = color_buttons[i]
		if i == COLORS.find(current_color):
			# Add glow effect
			var style_box = StyleBoxFlat.new()
			style_box.bg_color = COLORS[i]
			style_box.corner_radius_top_left = 18
			style_box.corner_radius_top_right = 18
			style_box.corner_radius_bottom_left = 18
			style_box.corner_radius_bottom_right = 18
			style_box.border_width_left = 4
			style_box.border_width_top = 4
			style_box.border_width_right = 4
			style_box.border_width_bottom = 4
			style_box.border_color = Color.GOLD
			btn.add_theme_stylebox_override("normal", style_box)
		else:
			# Remove glow
			var style_box = StyleBoxFlat.new()
			style_box.bg_color = COLORS[i]
			style_box.corner_radius_top_left = 18
			style_box.corner_radius_top_right = 18
			style_box.corner_radius_bottom_left = 18
			style_box.corner_radius_bottom_right = 18
			btn.add_theme_stylebox_override("normal", style_box)

# Update brush size button highlighting
func _update_brush_size_buttons() -> void:
	for i in range(brush_size_buttons.size()):
		var btn = brush_size_buttons[i]
		if BRUSH_SIZES[i] == current_brush_size:
			btn.add_theme_color_override("font_color", Color.GOLD)
			btn.add_theme_font_size_override("font_size", 16)
		else:
			btn.remove_theme_color_override("font_color")
			btn.remove_theme_font_size_override("font_size")

# Show clear confirmation dialog
func _show_clear_dialog() -> void:
	var dialog = ConfirmationDialog.new()
	dialog.title = "Hapus Gambar"
	dialog.dialog_text = "Hapus gambar?"
	dialog.get_ok_button().text = "OK"
	dialog.get_cancel_button().text = "Batal"
	dialog.confirmed.connect(_on_clear_confirmed.bind(dialog))
	dialog.canceled.connect(_on_clear_dialog_cancelled.bind(dialog))
	dialog.close_requested.connect(_on_clear_dialog_cancelled.bind(dialog))

	# Center dialog
	dialog.position = Vector2(
		(get_viewport_rect().size.x - dialog.size.x) / 2,
		(get_viewport_rect().size.y - dialog.size.y) / 2
	)

	$GameContainer/GameContent.add_child(dialog)
	dialog.popup_centered()

# Confirm clear action
func _on_clear_confirmed(dialog: ConfirmationDialog) -> void:
	canvas_image.fill(Color.WHITE)
	canvas_texture.set_image(canvas_image)
	strokes.clear()
	dialog.queue_free()

# Handle clear button press
func _on_clear_pressed() -> void:
	_show_clear_dialog()

# Handle color button press
func _on_color_pressed(color_idx: int) -> void:
	set_color(color_idx)

# Handle brush size button press
func _on_brush_size_pressed(size_idx: int) -> void:
	set_brush_size(size_idx)

# Show save confirmation
func _show_save_confirmation() -> void:
	save_label.visible = true

	# Hide after 2 seconds
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.timeout.connect(_hide_save_confirmation.bind(timer))
	add_child(timer)
	timer.start()

# Hide save confirmation
func _hide_save_confirmation(timer: Timer) -> void:
	save_label.visible = false
	timer.queue_free()

func _handle_level_complete(success: bool) -> void:
	var pm: Node = get_node_or_null("/root/ProgressManager")
	var res: Dictionary = pm.complete_level(GAME_ID, success) if pm else {"leveled_up": false, "new_level": current_level, "max_level": current_level}
	var leveled_up: bool = bool(res.get("leveled_up", false))
	var new_level: int = int(res.get("new_level", current_level))
	var max_level: int = int(res.get("max_level", pm.get_max_level(GAME_ID) if pm else current_level))

	var overlay_ps: PackedScene = preload("res://scenes/ui/LevelUpOverlay.tscn")
	var overlay = overlay_ps.instantiate()
	get_tree().root.add_child(overlay)
	if overlay.has_method("setup"):
		overlay.setup(new_level, new_level >= max_level)
	await overlay.finished

	if leveled_up:
		var gm: Node = get_node_or_null("/root/GameManager")
		if gm:
			gm.fade_to_scene(SCENE_PATH)
	else:
		await get_tree().create_timer(0.6).timeout
		var gm: Node = get_node_or_null("/root/GameManager")
		if gm:
			gm.fade_to_scene("res://scenes/MainMenu.tscn")

# Trigger level completion on successful save

# Create paintings directory if it doesn't exist
func _create_paintings_directory() -> void:
	var dir = DirAccess.open("user://")
	if dir:
		if not dir.dir_exists("paintings"):
			dir.make_dir("paintings")
			print("Created paintings directory")
