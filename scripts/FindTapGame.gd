extends Control

# FindTapGame - toddler find-and-tap game.
# Shows a target item name; kid taps the matching icon.

const THEME_PATHS := [
	"res://assets/data/themes/animals_id.json",
	"res://assets/data/themes/transport_id.json",
]
const TARGET_PER_ROUND := 5

@onready var grid: GridContainer = $GameContainer/Grid
@onready var objective_label: Label = $GameContainer/TopBar/ObjectiveLabel
@onready var progress_label: Label = $GameContainer/TopBar/ProgressLabel
@onready var background: TextureRect = $Background

var theme: Dictionary = {}
var items: Array = []
var target_id: String = ""
var progress: int = 0

var _id_to_button: Dictionary = {}
var _is_animating: bool = false

func _ready() -> void:
	# If user selected a theme via popup, use it; otherwise random.
	if GameManager.findtap_theme_path != "":
		_load_theme(GameManager.findtap_theme_path)
	else:
		_load_theme_random()
	_build_grid()
	_apply_responsive_layout()
	get_viewport().size_changed.connect(_apply_responsive_layout)

	await _shuffle_grid_animation()
	_new_target()
	_update_hud()

	$GameContainer/TopBar/BackButton.pressed.connect(func():
		GameManager.fade_to_scene("res://scenes/MainMenu.tscn")
	)

func _load_theme_random() -> void:
	if THEME_PATHS.is_empty():
		return
	var path: String = THEME_PATHS.pick_random()
	_load_theme(path)

func _load_theme(path: String) -> void:
	if not FileAccess.file_exists(path):
		push_error("Theme not found: %s" % path)
		return
	var f = FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(f.get_as_text())
	if typeof(data) == TYPE_DICTIONARY:
		theme = data
		items = theme.get("items", [])
		# Optional background override per theme
		var bg_path: String = theme.get("background", "")
		if background and not bg_path.is_empty() and ResourceLoader.exists(bg_path):
			background.texture = load(bg_path)

func _build_grid() -> void:
	# Clear old
	for c in grid.get_children():
		c.queue_free()
	_id_to_button.clear()

	# Build buttons
	for it in items:
		var id: String = it.get("id", "")
		var b := Button.new()
		b.custom_minimum_size = Vector2(180, 180) # will be overridden by _apply_responsive_layout
		b.text = ""
		b.flat = true
		b.focus_mode = Control.FOCUS_NONE

		var icon_path: String = it.get("icon", "")
		if not icon_path.is_empty() and ResourceLoader.exists(icon_path):
			b.icon = load(icon_path)
			b.expand_icon = true

		b.pressed.connect(_on_item_pressed.bind(id))
		grid.add_child(b)
		_id_to_button[id] = b

func _apply_responsive_layout() -> void:
	var vp := get_viewport_rect().size
	var is_landscape := vp.x >= vp.y

	# Keep it readable on 1280x720.
	if is_landscape:
		grid.theme_override_constants.h_separation = 18
		grid.theme_override_constants.v_separation = 18
		# If we have few items, keep them on one row. Otherwise wrap.
		grid.columns = clampi(items.size(), 4, 6)
		_set_button_min_size(Vector2(160, 160))
	else:
		grid.theme_override_constants.h_separation = 16
		grid.theme_override_constants.v_separation = 16
		grid.columns = clampi(items.size(), 3, 5)
		_set_button_min_size(Vector2(180, 180))

func _set_button_min_size(sz: Vector2) -> void:
	for c in grid.get_children():
		if c is Button:
			(c as Button).custom_minimum_size = sz

func _new_target() -> void:
	if items.is_empty():
		return
	var pool := items.duplicate()
	pool.shuffle()
	target_id = pool[0].get("id", "")

func _update_hud() -> void:
	if progress_label:
		progress_label.text = "%d/%d" % [progress, TARGET_PER_ROUND]
	if objective_label:
		var label = _label_for_id(target_id)
		objective_label.text = "Tap: %s" % label
		# Prompt voice (best-effort, currently transport phrases)
		var voice_path = "words/id/transport/tap_%s.wav" % target_id
		AudioManager.play_voice(voice_path)

func _label_for_id(id: String) -> String:
	for it in items:
		if it.get("id", "") == id:
			return it.get("label_id", id)
	return id

func _on_item_pressed(id: String) -> void:
	if _is_animating:
		return

	if id == target_id:
		progress += 1
		RewardSystem.reward_success(get_viewport().get_mouse_position(), 1.2)
		# Voice reward (best-effort)
		AudioManager.play_voice("words/id/transport/pintar.wav")
		_update_hud()

		if progress >= TARGET_PER_ROUND:
			await _celebrate_round_complete()
			progress = 0

		await _shuffle_grid_animation()
		_new_target()
		_update_hud()
	else:
		RewardSystem.reward_error(get_viewport().get_mouse_position())
		AudioManager.play_voice("words/id/transport/coba_lagi.wav")
		await _highlight_correct_target()

func _shuffle_grid_animation() -> void:
	if grid.get_child_count() <= 1:
		return

	_is_animating = true
	_set_grid_buttons_disabled(true)

	# Small "shuffle" wiggle + scale, then reorder children.
	var buttons: Array[Button] = []
	for c in grid.get_children():
		if c is Button:
			buttons.append(c)

	# Wiggle animation.
	for b in buttons:
		b.pivot_offset = b.size * 0.5
		b.rotation = 0.0
		b.scale = Vector2.ONE

	var t := create_tween()
	t.set_parallel(true)
	for b in buttons:
		var s := 0.9 + randf() * 0.15
		t.tween_property(b, "scale", Vector2(s, s), 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		t.tween_property(b, "rotation", deg_to_rad(-6 + randf() * 12), 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await t.finished

	# Reorder children.
	buttons.shuffle()
	for i in range(buttons.size()):
		grid.move_child(buttons[i], i)

	# Settle back.
	var t2 := create_tween()
	t2.set_parallel(true)
	for b in buttons:
		t2.tween_property(b, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t2.tween_property(b, "rotation", 0.0, 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await t2.finished

	_set_grid_buttons_disabled(false)
	_is_animating = false

func _set_grid_buttons_disabled(disabled: bool) -> void:
	for c in grid.get_children():
		if c is Button:
			(c as Button).disabled = disabled

func _highlight_correct_target() -> void:
	var b: Button = _id_to_button.get(target_id, null)
	if not b:
		return

	# Brief highlight so kids learn by feedback.
	b.pivot_offset = b.size * 0.5
	var original := b.modulate

	var t := create_tween()
	t.tween_property(b, "scale", Vector2(1.08, 1.08), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(b, "modulate", Color(1.0, 1.0, 0.6, 1.0), 0.08)
	await t.finished

	await get_tree().create_timer(0.25).timeout

	var t2 := create_tween()
	t2.tween_property(b, "scale", Vector2.ONE, 0.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t2.parallel().tween_property(b, "modulate", original, 0.12)
	await t2.finished

func _celebrate_round_complete() -> void:
	_is_animating = true
	_set_grid_buttons_disabled(true)

	RewardSystem.reward_success(get_viewport().get_visible_rect().size / 2.0, 2.0)
	AudioManager.play_voice("words/id/transport/pintar.wav")

	# Quick bounce for all icons.
	var buttons: Array[Button] = []
	for c in grid.get_children():
		if c is Button:
			buttons.append(c)

	var t := create_tween()
	t.set_parallel(true)
	for b in buttons:
		b.pivot_offset = b.size * 0.5
		t.tween_property(b, "scale", Vector2(1.12, 1.12), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.tween_property(b, "rotation", deg_to_rad(-4 + randf() * 8), 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await t.finished

	var t2 := create_tween()
	t2.set_parallel(true)
	for b in buttons:
		t2.tween_property(b, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		t2.tween_property(b, "rotation", 0.0, 0.14).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await t2.finished

	await get_tree().create_timer(0.25).timeout
	_set_grid_buttons_disabled(false)
	_is_animating = false
