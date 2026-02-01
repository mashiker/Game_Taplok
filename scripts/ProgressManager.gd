extends Node

# ProgressManager - stores per-game level progression and serves level configs.
# Autoload singleton.

const PROGRESS_PATH := "user://progress.json"
const LEVELS_DIR := "res://assets/data/levels/"

# progress schema:
# {
#   "tap_pop": {"level": 1, "max_unlocked": 1},
#   ...
# }
var _progress: Dictionary = {}
var _level_cache: Dictionary = {} # game_id -> Array[Dictionary]

func _ready() -> void:
	_load_progress()
	print("ProgressManager initialized")

func get_level(game_id: String) -> int:
	var rec: Dictionary = _progress.get(game_id, {})
	var lvl: int = int(rec.get("level", 1))
	return max(1, lvl)

func set_level(game_id: String, level: int) -> void:
	var rec: Dictionary = _progress.get(game_id, {})
	rec["level"] = max(1, level)
	rec["max_unlocked"] = max(int(rec.get("max_unlocked", 1)), int(rec["level"]))
	_progress[game_id] = rec
	_save_progress()

func get_max_level(game_id: String) -> int:
	var levels: Array = _load_levels(game_id)
	return max(1, levels.size())

func get_level_config(game_id: String, level: int) -> Dictionary:
	var levels: Array = _load_levels(game_id)
	if levels.is_empty():
		return {}
	var idx: int = int(clamp(level - 1, 0, levels.size() - 1))
	var v = levels[idx]
	return v if typeof(v) == TYPE_DICTIONARY else {}

# Returns {"leveled_up": bool, "new_level": int, "max_level": int}
func complete_level(game_id: String, success: bool) -> Dictionary:
	var lvl: int = get_level(game_id)
	var max_lvl: int = get_max_level(game_id)
	if not success:
		return {"leveled_up": false, "new_level": lvl, "max_level": max_lvl}
	if lvl >= max_lvl:
		return {"leveled_up": false, "new_level": lvl, "max_level": max_lvl}
	set_level(game_id, lvl + 1)
	return {"leveled_up": true, "new_level": lvl + 1, "max_level": max_lvl}

func reset_game(game_id: String) -> void:
	set_level(game_id, 1)

func _load_levels(game_id: String) -> Array:
	if _level_cache.has(game_id):
		return _level_cache[game_id]
	var path := LEVELS_DIR + game_id + ".json"
	if not FileAccess.file_exists(path):
		_level_cache[game_id] = []
		return _level_cache[game_id]
	var f := FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(f.get_as_text())
	if typeof(data) == TYPE_ARRAY:
		_level_cache[game_id] = data
	else:
		_level_cache[game_id] = []
	return _level_cache[game_id]

func _load_progress() -> void:
	if not FileAccess.file_exists(PROGRESS_PATH):
		_progress = {}
		return
	var f := FileAccess.open(PROGRESS_PATH, FileAccess.READ)
	if not f:
		_progress = {}
		return
	var data = JSON.parse_string(f.get_as_text())
	_progress = data if typeof(data) == TYPE_DICTIONARY else {}
	f.close()

func _save_progress() -> void:
	var f := FileAccess.open(PROGRESS_PATH, FileAccess.WRITE)
	if not f:
		push_warning("ProgressManager: failed to write progress")
		return
	f.store_string(JSON.stringify(_progress))
	f.close()
