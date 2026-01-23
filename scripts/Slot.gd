extends Control

# Slot - Drop target for shapes in Drag Match game
# Accepts shapes of matching type

class_name Slot

## Constants ##
const SLOT_SIZE: Vector2 = Vector2(60, 60)

## Variables ##
@export var slot_type: String = ""  # "circle", "square", "triangle", "star", "heart"
var is_filled: bool = false

## Node References ##
@onready var color_rect: ColorRect = $ColorRect
@onready var area: Area2D = $Area2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D

## Built-in Functions ##
func _ready() -> void:
	_setup_slot()
	_connect_signals()

## Public Functions ##

# Set the slot type
func set_slot_type(type: String) -> void:
	slot_type = type
	_setup_slot()

# Check if a shape can be placed in this slot
func accepts_shape(shape: Shape) -> bool:
	return not is_filled and shape.shape_type == slot_type

# Mark slot as filled
func fill() -> void:
	is_filled = true

# Mark slot as empty
func clear() -> void:
	is_filled = false

# Highlight the slot (visual feedback)
func highlight(enabled: bool) -> void:
	if not color_rect:
		return

	if enabled:
		color_rect.color = Color(0.8, 0.9, 1.0)  # Light blue highlight
	else:
		_reset_color()

# Show success visual on match
func show_success() -> void:
	if not color_rect:
		return

	var tween = create_tween()
	tween.set_parallel(true)

	# Pulse scale
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).set_delay(0.1)

	# Flash color
	var original_color = color_rect.color
	color_rect.color = Color(0.2, 1.0, 0.5)  # Bright green
	tween.tween_property(color_rect, "color", original_color, 0.3).set_delay(0.2)

## Private Functions ##

# Set up the slot visual
func _setup_slot() -> void:
	if not color_rect:
		return

	custom_minimum_size = SLOT_SIZE
	_reset_color()

	# Add border for visibility
	color_rect.color = Color(0.15, 0.15, 0.2)  # Dark outline color

# Reset color to default
func _reset_color() -> void:
	if not color_rect:
		return

	# Dark outline color (placeholder for shape)
	color_rect.color = Color(0.15, 0.15, 0.2)

# Connect signals
func _connect_signals() -> void:
	pass

## Signal Callbacks ##
