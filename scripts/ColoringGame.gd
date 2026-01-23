extends "res://scripts/GameSceneBase.gd"

class_name ColoringGame

# ColoringGame - Template-based coloring game with flood fill
# Children tap regions to fill them with colors

## Constants ##
const CANVAS_WIDTH: int = 800
const CANVAS_HEIGHT: int = 600
const EXPORT_WIDTH: int = 1200
const EXPORT_HEIGHT: int = 900
const MAX_UNDO: int = 20
const TOLERANCE: int = 50  # Color tolerance for flood fill

## Color Palette (same as FingerPaint) ##
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

## Template Definitions ##
const TEMPLATES: Array[Dictionary] = [
	{"id": "batik", "name": "Batik", "path": "res://assets/textures/coloring_templates/batik.png"},
	{"id": "komodo", "name": "Komodo", "path": "res://assets/textures/coloring_templates/komodo.png"},
	{"id": "anggrek", "name": "Anggrek", "path": "res://assets/textures/coloring_templates/anggrek.png"},
	{"id": "joglo", "name": "Joglo", "path": "res://assets/textures/coloring_templates/joglo.png"},
	{"id": "melati", "name": "Melati", "path": "res://assets/textures/coloring_templates/melati.png"}
]

## Age-based template complexity ##
const AGE_COMPLEXITY: Dictionary = {
	"2-3": ["batik"],       # Simple templates (2-3 regions)
	"3-4": ["komodo", "anggrek"],  # Medium templates (5-8 regions)
	"4-5": ["joglo", "melati"]     # Complex templates (10-15 regions)
}

## Variables ##
var canvas: TextureRect
var canvas_texture: ImageTexture
var canvas_image: Image
var template_image: Image
var current_color: Color = Color.RED
var current_template: Dictionary = {}
var undo_stack: Array[Image] = []
var color_buttons: Array[Button] = []
var template_buttons: Array[TextureButton] = []
var is_transitioning: bool = false

## UI References ##
@onready var template_list: HBoxContainer
@onready var undo_button: Button
@onready var save_button: Button

## Built-in Functions ##
func _ready() -> void:
	super._ready()
	game_name = "Coloring"
	_setup_canvas()
	_setup_template_selector()
	_setup_color_palette()
	_setup_buttons()
	_create_paintings_directory()
	_load_template_by_age()

func _input(event: InputEvent) -> void:
	if not is_active or is_transitioning:
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_handle_canvas_click(event)

## GameSceneBase Override ##
func _on_game_start() -> void:
	super._on_game_start()
	SessionManager.start_session("Coloring", "creative")

func _on_game_end() -> void:
	super._on_game_end()
	SessionManager.end_session()

## Public Functions ##

# Set current color for painting
func set_color(color_idx: int) -> void:
	if color_idx >= 0 and color_idx < COLORS.size():
		current_color = COLORS[color_idx]
		_update_color_buttons()

# Load a specific template
func load_template(template_data: Dictionary) -> void:
	current_template = template_data
	_load_template_image(template_data["path"])

# Undo last action
func undo() -> void:
	if undo_stack.size() > 0:
		canvas_image = undo_stack.pop_back()
		_update_canvas_texture()
		AudioManager.play_sfx("gentle.ogg")

# Save the current coloring
func save_painting() -> void:
	var timestamp = Time.get_unix_time_from_system()
	var filename = "coloring_%d.png" % timestamp
	var filepath = "user://paintings/%s" % filename

	# Ensure paintings directory exists
	DirAccess.make_dir_absolute("user://paintings")

	# Export at higher resolution
	var export_image = canvas_image.duplicate()
	export_image.resize(EXPORT_WIDTH, EXPORT_HEIGHT, Image.INTERPOLATE_NEAREST)
	var save_error = export_image.save_png(filepath)

	if save_error != OK:
		push_error("Failed to save coloring: ", filepath)
		return

	# Save to database
	Database.save_painting("Coloring", filepath, current_template.get("id", ""))

	# Show save confirmation
	_show_save_confirmation()

## Private Functions ##

# Set up the coloring canvas
func _setup_canvas() -> void:
	canvas = TextureRect.new()
	canvas.custom_minimum_size = Vector2(CANVAS_WIDTH, CANVAS_HEIGHT)
	canvas.z_index = 0
	canvas.mouse_filter = Control.MOUSE_FILTER_PASS
	canvas.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL

	# Create initial white canvas
	canvas_image = Image.create(CANVAS_WIDTH, CANVAS_HEIGHT, false, Image.FORMAT_RGBA8)
	canvas_image.fill(Color.WHITE)

	canvas_texture = ImageTexture.new()
	canvas_texture.set_image(canvas_image)
	canvas.texture = canvas_texture

	$GameContainer/GameContent.add_child(canvas)

	# Center canvas
	canvas.position = Vector2(
		($GameContainer/GameContent.size.x - CANVAS_WIDTH) / 2,
		150  # Below template selector
	)

# Set up template selector at top
func _setup_template_selector() -> void:
	template_list = $GameContainer/GameContent/TemplateSelector/TemplateScroll/TemplateList

	# Create template buttons
	for template_data in TEMPLATES:
		var btn = TextureButton.new()
		btn.custom_minimum_size = Vector2(100, 100)
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		btn.ignore_texture_size = true

		# Load template as thumbnail
		var template_img = Image.new()
		var error = template_img.load(template_data["path"])
		if error == OK:
			var thumb = template_img.duplicate()
			thumb.resize(100, 100, Image.INTERPOLATE_NEAREST)
			var thumb_tex = ImageTexture.new()
			thumb_tex.set_image(thumb)
			btn.texture_normal = thumb_tex

		btn.pressed.connect(_on_template_pressed.bind(template_data))
		template_list.add_child(btn)
		template_buttons.append(btn)

# Set up color palette at bottom
func _setup_color_palette() -> void:
	var palette_container = HBoxContainer.new()
	palette_container.name = "ColorPalette"
	palette_container.position = Vector2(
		($GameContainer/GameContent.size.x - 360) / 2,
		$GameContainer/GameContent.size.y - 80
	)

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

		palette_container.add_child(btn)
		color_buttons.append(btn)

	$GameContainer/GameContent.add_child(palette_container)
	_update_color_buttons()

# Set up undo and save buttons
func _setup_buttons() -> void:
	undo_button = $GameContainer/GameContent/TemplateSelector/UndoButton
	undo_button.pressed.connect(undo)

	save_button = $GameContainer/GameContent/TemplateSelector/SaveButton
	save_button.pressed.connect(save_painting)

# Load template based on child's age
func _load_template_by_age() -> void:
	var age = GameManager.get_child_age()
	var age_group: String

	if age <= 3:
		age_group = "2-3"
	elif age <= 4:
		age_group = "3-4"
	else:
		age_group = "4-5"

	var available_templates = AGE_COMPLEXITY.get(age_group, TEMPLATES)
	if available_templates.size() > 0:
		# Find first matching template
		for template in TEMPLATES:
			if template["id"] in available_templates:
				load_template(template)
				break

# Load template image onto canvas
func _load_template_image(path: String) -> void:
	var error = template_image.load(path)
	if error != OK:
		push_error("Failed to load template: ", path)
		return

	# Resize template to canvas size
	template_image.resize(CANVAS_WIDTH, CANVAS_HEIGHT, Image.INTERPOLATE_NEAREST)

	# Clear canvas and draw template
	canvas_image.fill(Color.WHITE)

	# Copy template to canvas
	for y in range(CANVAS_HEIGHT):
		for x in range(CANVAS_WIDTH):
			var pixel = template_image.get_pixel(x, y)
			canvas_image.set_pixel(x, y, pixel)

	_update_canvas_texture()
	_clear_undo_stack()

# Handle canvas click for flood fill
func _handle_canvas_click(event: InputEventMouseButton) -> void:
	var local_pos = canvas.get_local_mouse_position()

	# Check if within canvas bounds
	if local_pos.x < 0 or local_pos.x >= CANVAS_WIDTH or local_pos.y < 0 or local_pos.y >= CANVAS_HEIGHT:
		return

	var x = int(local_pos.x)
	var y = int(local_pos.y)

	# Save state for undo
	_save_to_undo_stack()

	# Perform flood fill
	_flood_fill(canvas_image, x, y, current_color)
	_update_canvas_texture()

	# Play sound and haptic
	AudioManager.play_sfx("pop_soft.ogg")
	OS.vibrate_msec(30)

	# Record tap
	SessionManager.record_tap()

# Flood fill algorithm
func _flood_fill(image: Image, start_x: int, start_y: int, fill_color: Color) -> void:
	var target_color = image.get_pixel(start_x, start_y)

	# Don't fill if same color
	if _colors_match(target_color, fill_color):
		return

	# Don't fill black outline pixels
	if _colors_match(target_color, Color.BLACK):
		return

	var width = image.get_width()
	var height = image.get_height()

	# Stack-based flood fill
	var stack = [{x = start_x, y = start_y}]
	var visited = {}

	while stack.size() > 0:
		var pos = stack.pop_back()
		var key = str(pos.x) + "," + str(pos.y)

		if visited.has(key):
			continue
		visited[key] = true

		if pos.x < 0 or pos.x >= width or pos.y < 0 or pos.y >= height:
			continue

		var current_color = image.get_pixel(pos.x, pos.y)

		if not _colors_match(current_color, target_color):
			continue

		image.set_pixel(pos.x, pos.y, fill_color)

		# Add neighbors to stack (4-way)
		stack.append({x = pos.x + 1, y = pos.y})
		stack.append({x = pos.x - 1, y = pos.y})
		stack.append({x = pos.x, y = pos.y + 1})
		stack.append({x = pos.x, y = pos.y - 1})

# Check if two colors match (with tolerance)
func _colors_match(c1: Color, c2: Color) -> bool:
	return abs(c1.r - c2.r) < 0.02 and abs(c1.g - c2.g) < 0.02 and abs(c1.b - c2.b) < 0.02

# Update canvas texture from image
func _update_canvas_texture() -> void:
	canvas_texture.set_image(canvas_image)
	canvas.texture = canvas_texture

# Save current state to undo stack
func _save_to_undo_stack() -> void:
	var state = canvas_image.duplicate()
	undo_stack.append(state)

	# Limit undo stack size
	if undo_stack.size() > MAX_UNDO:
		undo_stack.pop_front()

# Clear undo stack
func _clear_undo_stack() -> void:
	undo_stack.clear()

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

# Show save confirmation
func _show_save_confirmation() -> void:
	var label = Label.new()
	label.text = "Gambar Tersimpan!"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color.GREEN)
	label.add_theme_font_size_override("font_size", 24)
	label.size = Vector2(300, 60)
	label.position = Vector2(
		($GameContainer/GameContent.size.x - 300) / 2,
		($GameContainer/GameContent.size.y - 60) / 2
	)
	$GameContainer/GameContent.add_child(label)

	# Hide after 2 seconds
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.timeout.connect(_hide_save_confirmation.bind(timer, label))
	add_child(timer)
	timer.start()

# Hide save confirmation
func _hide_save_confirmation(timer: Timer, label: Label) -> void:
	label.queue_free()
	timer.queue_free()

# Create paintings directory if it doesn't exist
func _create_paintings_directory() -> void:
	var dir = DirAccess.open("user://")
	if dir:
		if not dir.dir_exists("paintings"):
			dir.make_dir("paintings")

## Signal Callbacks ##

# Handle color button press
func _on_color_pressed(color_idx: int) -> void:
	set_color(color_idx)

# Handle template button press
func _on_template_pressed(template_data: Dictionary) -> void:
	load_template(template_data)
