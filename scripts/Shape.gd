extends Control

# Shape - Draggable shape object for Drag Match game
# Handles drag input, visual feedback, and drop validation

class_name Shape

## Signals ##
signal shape_drag_started(shape: Shape)
signal shape_drag_ended(shape: Shape, slot: Slot)
signal shape_matched(shape: Shape)

## Constants ##
const DRAG_DEADZONE: float = 10.0  # Pixels to move before drag activates
const DRAG_OPACITY: float = 0.7
const DRAG_SCALE: float = 1.1

const SHAPE_TEXTURES := {
	"circle": preload("res://assets/textures/games/drag_match/shapes/circle.png"),
	"square": preload("res://assets/textures/games/drag_match/shapes/square.png"),
	"triangle": preload("res://assets/textures/games/drag_match/shapes/triangle.png"),
	"star": preload("res://assets/textures/games/drag_match/shapes/star.png"),
	"heart": preload("res://assets/textures/games/drag_match/shapes/heart.png"),
}

## Variables ##
@export var shape_type: String = ""  # "circle", "square", "triangle", "star", "heart"
@export var shape_color: Color = Color(1, 1, 1, 1)

var is_dragging: bool = false
var is_matched: bool = false
var drag_start_position: Vector2 = Vector2.ZERO
var original_position: Vector2 = Vector2.ZERO
var has_exceeded_deadzone: bool = false

## Node References ##
@onready var icon: TextureRect = $Icon
@onready var area: Area2D = $Area2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D

## Built-in Functions ##
func _ready() -> void:
	_setup_shape()
	_connect_signals()

func _gui_input(event: InputEvent) -> void:
	if is_matched:
		return

	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_start_drag(event.position)
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_end_drag()
	elif event is InputEventMouseMotion and is_dragging:
		_update_drag(event.position)

## Public Functions ##

# Set the shape type and update visuals
func set_shape_type(type: String) -> void:
	shape_type = type
	_setup_shape()

# Set the shape color (tints the texture)
func set_shape_color(color: Color) -> void:
	shape_color = color
	if icon:
		icon.modulate = color

# Mark shape as matched and prepare for removal
func mark_matched() -> void:
	is_matched = true
	is_dragging = false
	shape_matched.emit(self)

# Reset shape to original position
func reset_position() -> void:
	if is_matched:
		return

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position", original_position, 0.3)

	# Reset visual state
	modulate.a = 1.0
	scale = Vector2(1, 1)

## Private Functions ##

# Set up the shape visual based on type
func _setup_shape() -> void:
	if not icon:
		return

	# Use kid-friendly pastel textures (flat style)
	if SHAPE_TEXTURES.has(shape_type):
		icon.texture = SHAPE_TEXTURES[shape_type]
		icon.modulate = Color(1, 1, 1, 1)
	else:
		icon.texture = null
		icon.modulate = Color(1, 1, 1, 1)

# Connect signals
func _connect_signals() -> void:
	if area:
		area.area_entered.connect(_on_area_entered)
		area.area_exited.connect(_on_area_exited)

# Start dragging the shape
func _start_drag(event_position: Vector2) -> void:
	drag_start_position = event_position
	original_position = position
	is_dragging = true
	has_exceeded_deadzone = false

# Update drag position
func _update_drag(event_position: Vector2) -> void:
	var delta = event_position - drag_start_position

	# Check if deadzone exceeded
	if not has_exceeded_deadzone:
		if delta.length() >= DRAG_DEADZONE:
			has_exceeded_deadzone = true
			# Apply drag visual effects
			modulate.a = DRAG_OPACITY
			scale = Vector2(DRAG_SCALE, DRAG_SCALE)
			shape_drag_started.emit(self)
		else:
			return

	# Move shape
	position = original_position + delta

# End dragging and validate drop
func _end_drag() -> void:
	if not is_dragging:
		return

	is_dragging = false

	# Check for overlapping slots
	var overlapping_slots = _get_overlapping_slots()

	if overlapping_slots.is_empty():
		# No slot - reset position
		reset_position()
	else:
		# Found slot - emit signal for validation
		var closest_slot = _get_closest_slot(overlapping_slots)
		shape_drag_ended.emit(self, closest_slot)

# Get all overlapping slots
func _get_overlapping_slots() -> Array:
	var slots = []
	if area:
		var areas = area.get_overlapping_areas()
		for a in areas:
			if a is Slot and not a.is_filled:
				slots.append(a)
	return slots

# Get the closest slot from an array of slots
func _get_closest_slot(slots: Array) -> Slot:
	if slots.is_empty():
		return null

	var closest: Slot = slots[0]
	var closest_dist = global_position.distance_to(closest.global_position)

	for i in range(1, slots.size()):
		var slot: Slot = slots[i]
		var dist = global_position.distance_to(slot.global_position)
		if dist < closest_dist:
			closest = slot
			closest_dist = dist

	return closest

## Signal Callbacks ##

func _on_area_entered(other_area: Area2D) -> void:
	# Visual feedback when hovering over valid slot
	if other_area.get_parent() is Slot:
		var slot = other_area.get_parent() as Slot
		if not slot.is_filled:
			slot.highlight(true)

func _on_area_exited(other_area: Area2D) -> void:
	# Remove highlight when leaving slot
	if other_area.get_parent() is Slot:
		var slot = other_area.get_parent() as Slot
		slot.highlight(false)
