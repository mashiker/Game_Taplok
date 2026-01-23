extends Control

# Card - Individual card for Memory Flip game
# Handles flip animation, content display, and user interaction

class_name Card

## Signals ##
signal card_clicked(card: Card)
signal flip_completed(card: Card)

## Variables ##
var flipped: bool = false
var matched: bool = false
var content_id: int = 0
var content_color: Color = Color.WHITE
var is_flipping: bool = false

## Constants ##
const FLIP_DURATION: float = 0.3
const GLOW_DURATION: float = 0.5

## Node References ##
@onready var card_pivot: Control = $CardPivot
@onready var front: ColorRect = $CardPivot/Front
@onready var back: ColorRect = $CardPivot/Back
@onready var content: ColorRect = $CardPivot/Back/Content
@onready var glow_effect: ColorRect = $CardPivot/GlowEffect
@onready var question_icon: Label = $CardPivot/Front/QuestionIcon

## Built-in Functions ##
func _ready() -> void:
	# Set initial state - back is hidden (rotated 180)
	back.rotation_degrees.y = 180
	back.modulate.a = 0
	gui_input.connect(_on_gui_input)

## Public Functions ##

# Set the card content (color for simplicity)
# @param id: Content ID (0 = red, 1 = blue, 2 = yellow, 3 = green, 4 = pink, 5 = orange)
func set_content(id: int) -> void:
	content_id = id
	match id:
		0: content_color = Color.RED
		1: content_color = Color.BLUE
		2: content_color = Color.YELLOW
		3: content_color = Color.GREEN
		4: content_color = Color(1, 0.4, 0.7)  # Pink
		5: content_color = Color.ORANGE
		_: content_color = Color.WHITE

	content.color = content_color

# Flip the card to show content
func flip() -> void:
	if is_flipping or flipped:
		return

	is_flipping = true
	flipped = true

	# Play flip sound
	AudioManager.play_sfx("flip_soft.ogg")

	# Create flip animation
	var tween = create_tween()
	tween.set_parallel(false)

	# Rotate to 90 degrees (show edge)
	tween.tween_property(card_pivot, "rotation_degrees:y", 90, FLIP_DURATION / 2.0)
	tween.tween_callback(_show_back.bind(true))
	tween.tween_property(card_pivot, "rotation_degrees:y", 180, FLIP_DURATION / 2.0)
	tween.tween_callback(_on_flip_complete)

# Flip the card back to hide content
func flip_back() -> void:
	if is_flipping or not flipped:
		return

	is_flipping = true
	flipped = false

	# Create flip back animation
	var tween = create_tween()
	tween.set_parallel(false)

	# Rotate back to 0 degrees
	tween.tween_property(card_pivot, "rotation_degrees:y", 90, FLIP_DURATION / 2.0)
	tween.tween_callback(_show_back.bind(false))
	tween.tween_property(card_pivot, "rotation_degrees:y", 0, FLIP_DURATION / 2.0)
	tween.tween_callback(_on_flip_complete)

# Show glow effect for matched cards
func show_glow() -> void:
	matched = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # Disable further clicks

	var tween = create_tween()
	tween.set_parallel(false)

	# Fade in glow
	tween.tween_property(glow_effect, "color:a", 0.8, GLOW_DURATION)
	tween.tween_property(glow_effect, "color:a", 0.0, GLOW_DURATION)

	# Set cards to 50% opacity
	card_pivot.modulate.a = 0.5

# Reset card to initial state
func reset() -> void:
	if is_flipping:
		await get_tree().create_timer(FLIP_DURATION).timeout

	flipped = false
	matched = false
	is_flipping = false
	card_pivot.rotation_degrees.y = 0
	card_pivot.modulate.a = 1.0
	mouse_filter = Control.MOUSE_FILTER_STOP
	_show_back(false)

## Private Functions ##

# Show/hide the back of the card
func _show_back(show: bool) -> void:
	back.modulate.a = 1.0 if show else 0.0
	front.modulate.a = 0.0 if show else 1.0

# Called when flip animation completes
func _on_flip_complete() -> void:
	is_flipping = false
	flip_completed.emit(self)

## Signal Callbacks ##

# Handle touch/click input
func _on_gui_input(event: InputEvent) -> void:
	if matched or is_flipping:
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			card_clicked.emit(self)
			SessionManager.record_tap()
