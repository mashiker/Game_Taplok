extends Control

# Slot - Drop target for shapes in Drag Match game
# Accepts shapes of matching type

class_name Slot

## Constants ##
const SLOT_SIZE: Vector2 = Vector2(60, 60)

const SLOT_TEXTURES := {
	"circle": preload("res://assets/textures/games/drag_match/slots/circle.png"),
	"square": preload("res://assets/textures/games/drag_match/slots/square.png"),
	"triangle": preload("res://assets/textures/games/drag_match/slots/triangle.png"),
	"star": preload("res://assets/textures/games/drag_match/slots/star.png"),
	"heart": preload("res://assets/textures/games/drag_match/slots/heart.png"),
}

## Variables ##
@export var slot_type: String = ""  # "circle", "square", "triangle", "star", "heart"
var is_filled: bool = false

## Node References ##
@onready var icon: TextureRect = $Icon
@onready var highlight_rect: ColorRect = $Highlight
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
	if not highlight_rect:
		return

	highlight_rect.color.a = 0.35 if enabled else 0.0

# Show success visual on match
func show_success() -> void:
	var tween = create_tween()
	tween.set_parallel(true)

	# Pulse scale
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).set_delay(0.1)

	# Flash highlight + brighten icon briefly
	if highlight_rect:
		highlight_rect.color = Color(0.2, 1.0, 0.5, 0.45)
		tween.tween_property(highlight_rect, "color:a", 0.0, 0.35).set_delay(0.15)
	if icon:
		icon.modulate = Color(1.1, 1.1, 1.1, 1.0)
		tween.tween_property(icon, "modulate", Color(1, 1, 1, 1), 0.35)

## Private Functions ##

# Set up the slot visual
func _setup_slot() -> void:
	custom_minimum_size = SLOT_SIZE
	_reset_color()

# Reset visuals to default
func _reset_color() -> void:
	if icon:
		icon.modulate = Color(1, 1, 1, 1)
		icon.texture = SLOT_TEXTURES.get(slot_type, null)
	if highlight_rect:
		highlight_rect.color = Color(0.65, 0.85, 1.0, 0.0)

# Connect signals
func _connect_signals() -> void:
	pass

## Signal Callbacks ##
