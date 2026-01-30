extends Button

## Reusable kid-friendly menu card button (icon + title + bouncy interactions)

@export var title: String = "Game"
@export var icon_path: String = ""
@export var base_color: Color = Color(0.22, 0.74, 0.97, 1)
@export var corner_radius: int = 22
@export var enable_pulse: bool = true

@onready var _title_label: Label = $Margin/VBox/Title
@onready var _icon_rect: TextureRect = $Margin/VBox/Icon

var _original_scale: Vector2
var _tween: Tween
var _pulse_tween: Tween

func _ready() -> void:
	_original_scale = scale
	_apply_style()
	_apply_content()

	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_exit)
	button_down.connect(_on_pressed)
	button_up.connect(_on_released)

	if enable_pulse:
		_start_pulse()

func set_title(t: String) -> void:
	title = t
	if _title_label:
		_title_label.text = t

func set_icon_path(path: String) -> void:
	icon_path = path
	_apply_icon()

func set_base_color(c: Color) -> void:
	base_color = c
	_apply_style()

# ------------------------

func _apply_content() -> void:
	if _title_label:
		_title_label.text = title
	_apply_icon()

func _apply_icon() -> void:
	if not _icon_rect:
		return
	if icon_path.is_empty() or not ResourceLoader.exists(icon_path):
		_icon_rect.texture = null
		return
	_icon_rect.texture = load(icon_path)

func _apply_style() -> void:
	# Normal
	var normal := StyleBoxFlat.new()
	normal.bg_color = base_color
	normal.set_corner_radius_all(corner_radius)
	normal.shadow_size = 6
	normal.shadow_offset = Vector2(0, 6)

	# Hover
	var hover := normal.duplicate()
	hover.bg_color = base_color.lightened(0.08)

	# Pressed
	var pressed := normal.duplicate()
	pressed.bg_color = base_color.darkened(0.08)
	pressed.shadow_size = 0

	add_theme_stylebox_override("normal", normal)
	add_theme_stylebox_override("hover", hover)
	add_theme_stylebox_override("pressed", pressed)
	add_theme_stylebox_override("focus", hover)

	add_theme_color_override("font_color", Color.WHITE)
	add_theme_constant_override("outline_size", 2)
	add_theme_color_override("font_outline_color", Color(0,0,0,0.25))

# Animations

func _kill_tween() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()

func _animate_scale(target_scale: Vector2, duration: float, trans := Tween.TRANS_CUBIC, ease := Tween.EASE_OUT) -> void:
	_kill_tween()
	_tween = create_tween()
	_tween.set_trans(trans)
	_tween.set_ease(ease)
	_tween.tween_property(self, "scale", target_scale, duration)

func _on_hover() -> void:
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.pause()
	_animate_scale(_original_scale * 1.06, 0.16)

func _on_exit() -> void:
	_animate_scale(_original_scale, 0.18)
	if enable_pulse and _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.play()

func _on_pressed() -> void:
	_animate_scale(_original_scale * 0.94, 0.08, Tween.TRANS_BACK, Tween.EASE_OUT)

func _on_released() -> void:
	if get_global_rect().has_point(get_global_mouse_position()):
		_animate_scale(_original_scale * 1.06, 0.10)
	else:
		_animate_scale(_original_scale, 0.12)

func _start_pulse() -> void:
	_pulse_tween = create_tween()
	_pulse_tween.set_loops()
	_pulse_tween.tween_property(self, "scale", _original_scale * 0.99, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_pulse_tween.tween_property(self, "scale", _original_scale * 1.01, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
