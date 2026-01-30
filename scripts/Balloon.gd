extends Area2D

# Balloon - Interactive balloon object for Tap Pop game
# Handles tap detection and pop animation

## Signals ##
signal balloon_popped(color_name: String)

## Constants ##
const POP_DURATION: float = 0.18
const BALLOON_RADIUS: int = 44

## Variables ##
var balloon_color: Color = Color(0.91, 0.29, 0.24, 1)  # Default red
var color_name: String = "red"
var is_popping: bool = false

## Built-in Functions ##
func _ready() -> void:
	# Connect input event for tap detection
	input_event.connect(_on_input_event)

	# Pick random color
	_set_random_color()

	# Spawn animation
	scale = Vector2.ZERO
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

## Public Functions ##

# Set the balloon color (kept for backwards-compat), also selects sprite texture
func set_balloon_color(color: Color, name: String) -> void:
	balloon_color = color
	color_name = name
	_update_visuals()

func _update_visuals() -> void:
	var sprite = $Sprite
	if not sprite:
		return

	# Prefer textures for TapPop
	var tex_path := "res://assets/textures/games/tappop/balloon_%s_256.png" % color_name
	if ResourceLoader.exists(tex_path):
		sprite.texture = load(tex_path)
		sprite.modulate = Color.WHITE
	else:
		# Fallback to tint if texture missing
		sprite.modulate = balloon_color

# Get the current color name
# @return: The color name
func get_color_name() -> String:
	return color_name

# Trigger the pop animation
func pop() -> void:
	if is_popping:
		return

	is_popping = true

	# Pop animation: scale down to 0
	var tween = create_tween()
	tween.set_parallel(true)
	# Pop: slightly up then vanish
	tween.tween_property(self, "scale", Vector2.ONE * 1.15, POP_DURATION * 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ZERO, POP_DURATION * 0.65).set_delay(POP_DURATION * 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, POP_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(_on_pop_complete).set_delay(POP_DURATION)

## Private Functions ##

# Set a random color from the available options
func _set_random_color() -> void:
	var colors = [
		{"color": Color(0.91, 0.29, 0.24, 1), "name": "red"},    # #E84A3D
		{"color": Color(0.22, 0.74, 0.97, 1), "name": "blue"},   # #38BDF8
		{"color": Color(0.98, 0.75, 0.14, 1), "name": "yellow"}, # #FBBF24
		{"color": Color(0.2, 0.83, 0.6, 1), "name": "green"}    # #34D399
	]

	var random_color = colors.pick_random()
	set_balloon_color(random_color.color, random_color.name)

# Handle input event (tap/click)
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if is_popping:
		return

	# Check if this is a tap/press event
	if event is InputEventMouseButton and event.pressed:
		pop()

# Callback when pop animation completes
func _on_pop_complete() -> void:
	# Emit signal before being removed
	balloon_popped.emit(color_name)

	# Provide haptic feedback
	Input.vibrate_handheld(50)
