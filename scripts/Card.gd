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
const FLIP_DURATION: float = 0.22
const GLOW_DURATION: float = 0.5

## Node References ##
@onready var card_pivot: Control = $CardPivot
@onready var front: TextureRect = $CardPivot/Front
@onready var back: TextureRect = $CardPivot/Back
@onready var content: TextureRect = $CardPivot/Back/Content
@onready var glow_effect: ColorRect = $CardPivot/GlowEffect

func _ready() -> void:
	# Initial state: show front
	_show_back(false)
	_apply_content_color()
	gui_input.connect(_on_gui_input)

# Set the card content (color for simplicity)
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

	_apply_content_color()

func _apply_content_color() -> void:
	# set_content() can be called before the node enters the scene tree.
	if content:
		content.modulate = content_color

# Flip the card to show content
func flip() -> void:
	if is_flipping or flipped:
		return
	is_flipping = true
	flipped = true

	AudioManager.play_sfx("flip_soft.ogg")

	var tween = create_tween()
	# Shrink X to 0 (edge), swap, expand back
	tween.tween_property(card_pivot, "scale:x", 0.0, FLIP_DURATION * 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_callback(_show_back.bind(true))
	tween.tween_property(card_pivot, "scale:x", 1.0, FLIP_DURATION * 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(_on_flip_complete)

# Flip the card back to hide content
func flip_back() -> void:
	if is_flipping or not flipped:
		return
	is_flipping = true
	flipped = false

	var tween = create_tween()
	tween.tween_property(card_pivot, "scale:x", 0.0, FLIP_DURATION * 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_callback(_show_back.bind(false))
	tween.tween_property(card_pivot, "scale:x", 1.0, FLIP_DURATION * 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(_on_flip_complete)

func show_glow() -> void:
	matched = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var tween = create_tween()
	# Fade in/out glow
	tween.tween_property(glow_effect, "color:a", 0.8, GLOW_DURATION)
	tween.tween_property(glow_effect, "color:a", 0.0, GLOW_DURATION)

	card_pivot.modulate.a = 0.5

func reset() -> void:
	if is_flipping:
		await get_tree().create_timer(FLIP_DURATION).timeout

	flipped = false
	matched = false
	is_flipping = false
	card_pivot.scale = Vector2.ONE
	card_pivot.modulate.a = 1.0
	mouse_filter = Control.MOUSE_FILTER_STOP
	_show_back(false)

# Show/hide the back of the card
func _show_back(show: bool) -> void:
	back.visible = show
	front.visible = not show

	# Also reset alpha to avoid accidental invisibility
	back.modulate.a = 1.0 if show else 1.0
	front.modulate.a = 1.0 if show == false else 1.0

func _on_flip_complete() -> void:
	is_flipping = false
	flip_completed.emit(self)

func _on_gui_input(event: InputEvent) -> void:
	if matched or is_flipping:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		card_clicked.emit(self)
		SessionManager.record_tap()
