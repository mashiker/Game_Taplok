extends Node

# SessionManager - Global singleton for tracking gameplay metrics across all games
# Handles session lifecycle, tap counting, and automatic database logging

## Signals ##
signal session_started(game_name: String, category: String)
signal session_ended(game_name: String, duration: int, metrics: Dictionary)
signal tap_recorded(count: int)

## Variables ##
var current_game: String = ""
var start_time: int = 0  # Unix timestamp
var tap_count: int = 0
var content_category: String = ""  # e.g., "cognitive", "creative", "musical"

var _is_session_active: bool = false
var _session_metrics: Dictionary = {}

## Built-in Functions ##
func _ready() -> void:
	print("SessionManager initialized")

## Public Functions ##

# Start a new game session
# @param game_name: Name of the game being played
# @param category: Content category (optional, defaults to "general")
func start_session(game_name: String, category: String = "general") -> void:
	# End any existing session first
	if _is_session_active:
		end_session()

	current_game = game_name
	content_category = category
	start_time = Time.get_unix_time_from_system()
	tap_count = 0
	_session_metrics = {}
	_is_session_active = true

	print("Session started: ", game_name, " (category: ", category, ")")
	session_started.emit(game_name, category)

# End the current session and save to database
func end_session() -> void:
	if not _is_session_active:
		push_warning("No active session to end")
		return

	var duration = get_session_duration()
	var metrics = _session_metrics.duplicate()
	metrics["tap_count"] = tap_count
	metrics["content_category"] = content_category

	# Save to database
	var start_time_str = Time.get_datetime_string_from_unix_time(start_time)
	Database.log_session(current_game, start_time_str, duration, metrics)

	print("Session ended: ", current_game, " (duration: ", duration, "s, taps: ", tap_count, ")")
	session_ended.emit(current_game, duration, metrics)

	# Reset session state
	current_game = ""
	content_category = ""
	start_time = 0
	tap_count = 0
	_session_metrics = {}
	_is_session_active = false

# Record a tap/action in the current session
func record_tap() -> void:
	if not _is_session_active:
		return

	tap_count += 1
	tap_recorded.emit(tap_count)

# Get the current session duration in seconds
# @return: Duration since session started, or 0 if no active session
func get_session_duration() -> int:
	if not _is_session_active:
		return 0
	return int(Time.get_unix_time_from_system() - start_time)

# Check if a session is currently active
# @return: true if a session is active
func is_session_active() -> bool:
	return _is_session_active

# Get the current game name
# @return: Current game name, or empty string if no session
func get_current_game() -> String:
	return current_game

# Get the current tap count
# @return: Number of taps in current session
func get_tap_count() -> int:
	return tap_count

# Set a custom metric for the current session
# @param key: Metric key
# @param value: Metric value
func set_metric(key: String, value: Variant) -> void:
	if not _is_session_active:
		push_warning("Cannot set metric: no active session")
		return
	_session_metrics[key] = value

# Get a custom metric from the current session
# @param key: Metric key
# @param default: Default value if key doesn't exist
# @return: Metric value or default
func get_metric(key: String, default: Variant = null) -> Variant:
	if _session_metrics.has(key):
		return _session_metrics[key]
	return default

# Get all metrics for the current session
# @return: Dictionary of all custom metrics
func get_all_metrics() -> Dictionary:
	return _session_metrics.duplicate()

## Auto-Session End Conditions ##

# Check and auto-end session if conditions are met
# Call this periodically in game loops
func check_auto_end_conditions() -> void:
	if not _is_session_active:
		return

	# Auto-end after 10 minutes (600 seconds)
	var duration = get_session_duration()
	if duration >= 600:
		print("Session auto-ended after 10 minutes")
		end_session()
		return

	# Auto-end after 60 taps (can be overridden per game)
	if tap_count >= 60:
		print("Session auto-ended after ", tap_count, " taps")
		end_session()
		return

# Set custom auto-end conditions for the current session
# @param max_duration: Maximum session duration in seconds (0 = no limit)
# @param max_taps: Maximum tap count (0 = no limit)
func set_auto_end_conditions(max_duration: int = 0, max_taps: int = 0) -> void:
	set_metric("auto_end_max_duration", max_duration)
	set_metric("auto_end_max_taps", max_taps)

# Check custom auto-end conditions
# @return: true if session should end
func check_custom_auto_end() -> bool:
	if not _is_session_active:
		return false

	var max_duration = get_metric("auto_end_max_duration", 0)
	var max_taps = get_metric("auto_end_max_taps", 0)

	if max_duration > 0 and get_session_duration() >= max_duration:
		return true

	if max_taps > 0 and tap_count >= max_taps:
		return true

	return false
