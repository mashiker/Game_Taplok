extends Control

# SoundMatchGame - toddler sound match game.
# Plays a prompt sound/voice, kid taps the matching icon.

const THEME_PATH := "res://assets/data/themes/transport_id.json"
const OPTIONS_PER_ROUND := 4

@onready var background: TextureRect = $Background
@onready var grid: GridContainer = $GameContainer/Grid
@onready var objective_label: Label = $GameContainer/TopBar/ObjectiveLabel
@onready var progress_label: Label = $GameContainer/TopBar/ProgressLabel

var theme_data: Dictionary = {}
var items: Array = []

var _target_id: String = ""
var _round: int = 0
var _id_to_button: Dictionary = {}
var _is_animating: bool = false

func _ready() -> void:
	_load_theme()
	_build_grid()
	_new_round()
	_update_hud()

	$GameContainer/TopBar/BackButton.pressed.connect(func():
		GameManager.fade_to_scene("res://scenes/MainMenu.tscn")
	)

func _load_theme() -> void:
	if not FileAccess.file_exists(THEME_PATH):
		push_error("Theme not found: %s" % THEME_PATH)
		return
	var f := FileAccess.open(THEME_PATH, FileAccess.READ)
	var data = JSON.parse_string(f.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Invalid theme JSON: %s" % THEME_PATH)
		return

	theme_data = data
	items = theme_data.get("items", [])

	var bg_path: String = theme_data.get("background", "")
	if background and not bg_path.is_empty() and ResourceLoader.exists(bg_path):
		background.texture = load(bg_path)

func _build_grid() -> void:
	for c in grid.get_children():
		c.queue_free()
	_id_to_button.clear()

	# Pre-create fixed number of option buttons; we swap icons/ids each round.
	for i in range(OPTIONS_PER_ROUND):
		var b := Button.new()
		b.custom_minimum_size = Vector2(220, 220)
		b.text = ""
		b.flat = true
		b.focus_mode = Control.FOCUS_NONE
		b.expand_icon = true
		b.pressed.connect(_on_option_pressed.bind(i))
		grid.add_child(b)

func _new_round() -> void:
	if items.is_empty():
		return

	_round += 1
	# Pick options
	var pool := items.duplicate()
	pool.shuffle()
	var options := pool.slice(0, min(OPTIONS_PER_ROUND, pool.size()))
	_target_id = options.pick_random().get("id", "")

	# Apply to buttons
	for i in range(grid.get_child_count()):
		var b := grid.get_child(i) as Button
		if not b:
			continue
		if i >= options.size():
			b.visible = false
			continue

		b.visible = true
		b.disabled = false
		b.modulate = Color.WHITE
		b.scale = Vector2.ONE
		b.rotation = 0.0

		var it: Dictionary = options[i]
		b.set_meta("item_id", it.get("id", ""))
		var icon_path: String = it.get("icon", "")
		if not icon_path.is_empty() and ResourceLoader.exists(icon_path):
			b.icon = load(icon_path)
		else:
			b.icon = null

	_update_hud()
	_play_prompt()

func _update_hud() -> void:
	if progress_label:
		progress_label.text = str(_round)
	if objective_label:
		objective_label.text = "Dengar suaranya, lalu tap yang benar"  # simple + kid friendly

func _play_prompt() -> void:
	# Prompt is SFX-first (A). If a specific SFX is missing, fallback to TTS so the game stays playable.
	if _target_id.is_empty():
		return

	var sfx_map := {
		"mobil": "sfx/transport/mobil_vroom.ogg",
		"bus": "sfx/transport/klakson.ogg",
		"kereta": "sfx/transport/kereta_whistle.wav",
		"pesawat": "sfx/transport/pesawat_whoosh.wav",
		"kapal": "sfx/transport/kapal_splash.ogg",
		"sepeda": "sfx/transport/sepeda_bell.wav",
	}

	var sfx_path: String = sfx_map.get(_target_id, "")
	if not sfx_path.is_empty():
		AudioManager.play_sfx(sfx_path)
		return

	# Fallback: TTS prompt
	var voice_path := "words/id/transport/cari_%s.wav" % _target_id
	AudioManager.play_voice(voice_path)

func _on_option_pressed(index: int) -> void:
	if _is_animating:
		return
	var b := grid.get_child(index) as Button
	if not b:
		return
	var id: String = str(b.get_meta("item_id", ""))

	if id == _target_id:
		RewardSystem.reward_success(get_viewport().get_mouse_position(), 1.2)
		AudioManager.play_voice("words/id/transport/pintar.wav")
		await _celebrate_correct(b)
		_new_round()
	else:
		RewardSystem.reward_error(get_viewport().get_mouse_position())
		AudioManager.play_voice("words/id/transport/coba_lagi.wav")
		await _highlight_correct_target()

func _celebrate_correct(b: Button) -> void:
	_is_animating = true
	_set_buttons_disabled(true)
	b.pivot_offset = b.size * 0.5
	var t := create_tween()
	t.tween_property(b, "scale", Vector2(1.12, 1.12), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(b, "rotation", deg_to_rad(6), 0.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await t.finished
	await get_tree().create_timer(0.25).timeout
	_set_buttons_disabled(false)
	_is_animating = false

func _highlight_correct_target() -> void:
	_is_animating = true
	_set_buttons_disabled(true)
	for i in range(grid.get_child_count()):
		var b := grid.get_child(i) as Button
		if not b or not b.visible:
			continue
		var id: String = str(b.get_meta("item_id", ""))
		if id == _target_id:
			b.pivot_offset = b.size * 0.5
			var t := create_tween()
			t.tween_property(b, "scale", Vector2(1.08, 1.08), 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			t.parallel().tween_property(b, "modulate", Color(1.0, 1.0, 0.6, 1.0), 0.10)
			await t.finished
			await get_tree().create_timer(0.25).timeout
			var t2 := create_tween()
			t2.tween_property(b, "scale", Vector2.ONE, 0.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			t2.parallel().tween_property(b, "modulate", Color.WHITE, 0.12)
			await t2.finished
			break

	_set_buttons_disabled(false)
	_is_animating = false

func _set_buttons_disabled(disabled: bool) -> void:
	for c in grid.get_children():
		if c is Button:
			(c as Button).disabled = disabled
