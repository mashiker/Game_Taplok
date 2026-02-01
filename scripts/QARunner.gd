extends Control

# QARunner - in-app automated sanity checks for assets/scenes.
# Intended for parent/debug usage before production builds.

const SOUND_ROOT := "res://assets/sounds/"

const SCENES_TO_TEST := [
	"res://scenes/TapPopGame.tscn",
	"res://scenes/DragMatchGame.tscn",
	"res://scenes/MemoryFlipGame.tscn",
	"res://scenes/PianoGame.tscn",
	"res://scenes/FingerPaintGame.tscn",
	"res://scenes/ColoringGame.tscn",
	"res://scenes/ShapeMatchGame.tscn",
	"res://scenes/RhythmGame.tscn",
	"res://scenes/FindTapThemeSelect.tscn",
	"res://scenes/FindTapGame.tscn",
	"res://scenes/SoundMatchGame.tscn",
]

const THEME_JSONS := [
	"res://assets/data/themes/animals_id.json",
	"res://assets/data/themes/transport_id.json",
]

# Minimal must-have audio (we treat missing as FAIL)
const REQUIRED_AUDIO := [
	"res://assets/sounds/sfx/transport/mobil_vroom.ogg",
	"res://assets/sounds/sfx/transport/klakson.ogg",
	"res://assets/sounds/sfx/transport/kereta_whistle.wav",
	"res://assets/sounds/sfx/transport/pesawat_whoosh.wav",
	"res://assets/sounds/sfx/transport/kapal_splash.ogg",
	"res://assets/sounds/sfx/transport/sepeda_bell.wav",
	
	"res://assets/sounds/words/id/warna_merah.wav",
	"res://assets/sounds/words/id/warna_biru.wav",
	"res://assets/sounds/words/id/warna_kuning.wav",
	"res://assets/sounds/words/id/warna_hijau.wav",
	
	"res://assets/sounds/music/twinkle_twinkle.wav",
	"res://assets/sounds/music/cicak_cicak.wav",
	"res://assets/sounds/music/lihat_lihat_penyu.wav",
]

@onready var status_label: Label = $VBox/Status
@onready var log_text: TextEdit = $VBox/Log
@onready var run_button: Button = $VBox/Buttons/RunButton
@onready var save_button: Button = $VBox/Buttons/SaveButton
@onready var back_button: Button = $VBox/Buttons/BackButton

var _lines: Array[String] = []
var _fail_count := 0

func _ready() -> void:
	status_label.text = "QA Runner siap."
	log_text.text = ""
	save_button.disabled = true

	run_button.pressed.connect(func():
		await run_all()
	)
	save_button.pressed.connect(_save_report)
	back_button.pressed.connect(func():
		GameManager.fade_to_scene("res://scenes/ParentDashboard.tscn")
	)

func _log(line: String) -> void:
	_lines.append(line)
	log_text.text = "\n".join(_lines)
	log_text.scroll_vertical = 999999

func _fail(line: String) -> void:
	_fail_count += 1
	_log("[FAIL] " + line)

func _ok(line: String) -> void:
	_log("[OK] " + line)

func _warn(line: String) -> void:
	_log("[WARN] " + line)

func run_all() -> void:
	run_button.disabled = true
	save_button.disabled = true
	_lines.clear()
	_fail_count = 0

	status_label.text = "Menjalankan QA..."
	_log("QA Runner started: %s" % Time.get_datetime_string_from_system())
	_log("Platform: %s" % OS.get_name())
	_log("---")

	_check_required_audio()
	await _check_themes()
	await _check_scenes()

	_log("---")
	if _fail_count == 0:
		status_label.text = "QA PASS (0 fail)"
		_ok("QA PASS")
	else:
		status_label.text = "QA FAIL (%d fail)" % _fail_count
		_fail("QA FAIL")

	save_button.disabled = false
	run_button.disabled = false

func _check_required_audio() -> void:
	_log("[SECTION] Audio required")
	for p in REQUIRED_AUDIO:
		if not ResourceLoader.exists(p):
			_fail("Missing audio file: %s" % p)
			continue
		var s = load(p)
		if s == null:
			_fail("Failed to load audio resource: %s" % p)
		else:
			_ok("Audio ok: %s" % p)

func _check_themes() -> void:
	_log("[SECTION] Theme JSON")
	for theme_path in THEME_JSONS:
		if not FileAccess.file_exists(theme_path):
			_fail("Missing theme json: %s" % theme_path)
			continue
		var f := FileAccess.open(theme_path, FileAccess.READ)
		var data = JSON.parse_string(f.get_as_text())
		if typeof(data) != TYPE_DICTIONARY:
			_fail("Invalid JSON dict: %s" % theme_path)
			continue

		var bg: String = data.get("background", "")
		if not bg.is_empty():
			if ResourceLoader.exists(bg):
				_ok("Theme bg ok: %s" % bg)
			else:
				_fail("Theme bg missing: %s" % bg)

		var items: Array = data.get("items", [])
		if items.is_empty():
			_warn("Theme has no items: %s" % theme_path)
		for it in items:
			var icon: String = it.get("icon", "")
			if icon.is_empty():
				_fail("Theme item missing icon in %s: %s" % [theme_path, str(it)])
				continue
			if ResourceLoader.exists(icon):
				_ok("Theme icon ok: %s" % icon)
			else:
				_fail("Theme icon missing: %s" % icon)

func _check_scenes() -> void:
	_log("[SECTION] Scene instantiate")
	for p in SCENES_TO_TEST:
		var ps: PackedScene = load(p)
		if ps == null:
			_fail("Failed to load scene: %s" % p)
			continue
		var inst = ps.instantiate()
		if inst == null:
			_fail("Failed to instantiate scene: %s" % p)
			continue

		# Run _ready for a couple frames
		get_tree().root.add_child(inst)
		await get_tree().process_frame
		await get_tree().process_frame

		if is_instance_valid(inst):
			inst.queue_free()
			await get_tree().process_frame
		_ok("Scene ok: %s" % p)

func _save_report() -> void:
	var path := "user://qa_report.txt"
	var f := FileAccess.open(path, FileAccess.WRITE)
	if not f:
		_warn("Could not write report to %s" % path)
		return
	f.store_string(log_text.text)
	f.close()
	_ok("Saved report: %s" % path)
