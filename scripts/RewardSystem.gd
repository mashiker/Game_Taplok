extends Node

## RewardSystem (autoload)
## Central place for kid-friendly feedback: sparkle + pop (+ optional confetti)

const LAYER := 200

var _canvas: CanvasLayer
var _root: Node2D
var _sparkle_tex: Texture2D

func _ready() -> void:
	_canvas = CanvasLayer.new()
	_canvas.layer = LAYER
	add_child(_canvas)

	_root = Node2D.new()
	_canvas.add_child(_root)

	_sparkle_tex = _make_sparkle_texture(64)

func reward_success(global_pos: Vector2, intensity: float = 1.0) -> void:
	_spawn_pop_sparkle(global_pos, intensity)
	_spawn_confetti(global_pos, int(14 * clampf(intensity, 0.8, 2.0)))

func reward_tap(global_pos: Vector2) -> void:
	_spawn_pop_sparkle(global_pos, 0.6)

func reward_error(global_pos: Vector2) -> void:
	# Soft feedback: a small red pulse
	_spawn_pop_sparkle(global_pos, 0.5, Color(1.0, 0.5, 0.5, 1.0))

# ------------------------
# Internals
# ------------------------

func _spawn_pop_sparkle(pos: Vector2, intensity: float, tint: Color = Color(1,1,1,1)) -> void:
	var s := Sprite2D.new()
	s.texture = _sparkle_tex
	s.position = pos
	s.modulate = tint
	s.scale = Vector2.ONE * 0.2
	s.z_index = 1000
	_root.add_child(s)

	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(s, "scale", Vector2.ONE * (1.1 * intensity), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(s, "rotation", randf_range(-0.4, 0.4), 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(s, "modulate:a", 0.0, 0.28).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_callback(s.queue_free).set_delay(0.3)

func _spawn_confetti(pos: Vector2, count: int) -> void:
	var colors := [
		Color(0.91, 0.29, 0.24),
		Color(0.22, 0.74, 0.97),
		Color(0.98, 0.75, 0.14),
		Color(0.2, 0.83, 0.6),
		Color(1.0, 0.41, 0.71),
	]

	for i in range(count):
		var p := Sprite2D.new()
		p.texture = _make_rect_texture(10, 10, colors.pick_random())
		p.position = pos
		p.rotation = randf_range(-3.14, 3.14)
		p.z_index = 900
		_root.add_child(p)

		var angle = randf_range(-3.14, 3.14)
		var dist = randf_range(60.0, 160.0)
		var drift = Vector2(cos(angle), sin(angle)) * dist
		var fall = Vector2(0, randf_range(120.0, 220.0))

		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(p, "position", pos + drift + fall, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(p, "rotation", p.rotation + randf_range(-6.0, 6.0), 0.7).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(p, "modulate:a", 0.0, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_callback(p.queue_free)

func _make_rect_texture(w: int, h: int, color: Color) -> Texture2D:
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)

func _make_sparkle_texture(size: int) -> Texture2D:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0,0,0,0))
	var c := size / 2
	for y in range(size):
		for x in range(size):
			var dx = abs(x - c)
			var dy = abs(y - c)
			# simple 8-point star: cross + diagonals
			var on = (dx <= 2 and dy < size/2) or (dy <= 2 and dx < size/2) or (abs(dx - dy) <= 2)
			if on:
				img.set_pixel(x, y, Color(1,1,1,1))
	return ImageTexture.create_from_image(img)
