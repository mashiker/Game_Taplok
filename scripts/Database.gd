extends Node

# Database - SQLite database manager for session and painting storage
# Handles all database operations using user:// directory
# NOTE: Requires gdsqlite plugin (https://github.com/godotot/gdsqlite)

## Constants ##
const DB_PATH: String = "user://playtap.db"

## Variables ##
var db: Object = null  # Will be SQLite object from gdsqlite plugin

## Signals ##
signal database_initialized(success: bool)
signal session_logged(game_type: String)
signal painting_saved(filepath: String)

## Built-in Functions ##
func _ready() -> void:
	_init_database()

## Public Functions ##

# Log a game session to the database
# @param game_type: Type/name of the game played
# @param start_time: Timestamp when session started (ISO format or empty for now)
# @param duration_seconds: Duration of the session in seconds
# @param metrics: Dictionary with additional metrics (will be JSON stringified)
func log_session(game_type: String, start_time: String, duration_seconds: int, metrics: Dictionary = {}) -> void:
	if not db:
		push_error("Database not initialized")
		return

	var metrics_json = JSON.stringify(metrics)
	var query = "INSERT INTO sessions (game_type, start_time, duration_seconds, metrics) VALUES (?, ?, ?, ?)"

	# Using placeholder for SQLite binding (plugin-specific syntax may vary)
	var result = db.execute(query, [game_type, start_time, duration_seconds, metrics_json])

	if result:
		print("Session logged: ", game_type, ", duration: ", duration_seconds, "s")
		session_logged.emit(game_type)
	else:
		push_error("Failed to log session: ", game_type)

# Get all paintings from the database
# @return: Array of painting dictionaries
func get_paintings() -> Array:
	if not db:
		push_error("Database not initialized")
		return []

	var paintings = []
	var query = "SELECT id, source, filepath, created_at FROM paintings ORDER BY created_at DESC"
	var result = db.query(query)

	if result and result is Array:
		for row in result:
			paintings.append({
				"id": row[0],
				"source": row[1],
				"filepath": row[2],
				"created_at": row[3]
			})

	return paintings

# Delete old sessions (older than specified days)
# @param days: Number of days to keep (default 90 days per privacy policy)
func delete_old_sessions(days: int = 90) -> void:
	if not db:
		push_error("Database not initialized")
		return

	var query = "DELETE FROM sessions WHERE date(start_time) < date('now', '-' || ? || ' days')"
	var result = db.execute(query, [days])

	if result:
		print("Deleted sessions older than ", days, " days")
	else:
		push_error("Failed to delete old sessions")

# Save a painting to the database
# @param source: Source of the painting (e.g., "FingerPaint", "Coloring")
# @param filepath: Path to the saved painting file
func save_painting(source: String, filepath: String) -> void:
	if not db:
		push_error("Database not initialized")
		return

	var query = "INSERT INTO paintings (source, filepath, created_at) VALUES (?, ?, datetime('now'))"
	var result = db.execute(query, [source, filepath])

	if result:
		print("Painting saved: ", source, " -> ", filepath)
		painting_saved.emit(filepath)
	else:
		push_error("Failed to save painting")

# Delete a painting from the database and file
# @param painting_id: ID of the painting to delete
func delete_painting(painting_id: int) -> bool:
	if not db:
		push_error("Database not initialized")
		return false

	# First get the filepath to delete the file
	var query = "SELECT filepath FROM paintings WHERE id = ?"
	var result = db.query(query, [painting_id])

	if result and result is Array and result.size() > 0:
		var filepath = result[0][0]

		# Delete the file if it exists
		if FileAccess.file_exists(filepath):
			var dir = DirAccess.open("user://")
			if dir:
				var relative_path = filepath.replace("user://", "")
				if dir.remove(relative_path) != OK:
					push_warning("Failed to delete painting file: ", filepath)

	# Delete the database record
	query = "DELETE FROM paintings WHERE id = ?"
	result = db.execute(query, [painting_id])

	if result:
		print("Painting deleted: ", painting_id)
		return true
	else:
		push_error("Failed to delete painting from database")
		return false

# Get session statistics for a date range
# @param days: Number of days to look back (default 7)
# @return: Dictionary with stats
func get_session_stats(days: int = 7) -> Dictionary:
	if not db:
		push_error("Database not initialized")
		return {}

	var stats = {
		"total_sessions": 0,
		"total_duration": 0,
		"game_counts": {},
		"by_date": {}
	}

	var query = """
		SELECT
			game_type,
			date(start_time) as date,
			COUNT(*) as count,
			SUM(duration_seconds) as total_duration
		FROM sessions
		WHERE start_time >= datetime('now', '-' || ? || ' days')
		GROUP BY game_type, date(start_time)
		ORDER BY date DESC
	"""
	var result = db.query(query, [days])

	if result and result is Array:
		for row in result:
			var game_type = row[0]
			var date = row[1]
			var count = row[2]
			var duration = row[3]

			stats.total_sessions += count
			stats.total_duration += duration

			if not stats.game_counts.has(game_type):
				stats.game_counts[game_type] = 0
			stats.game_counts[game_type] += count

			if not stats.by_date.has(date):
				stats.by_date[date] = 0
			stats.by_date[date] += duration

	return stats

# Get today's play count for the tap counter
# @return: Number of sessions today
func get_todays_play_count() -> int:
	if not db:
		push_error("Database not initialized")
		return 0

	var query = "SELECT COUNT(*) FROM sessions WHERE date(start_time) = date('now')"
	var result = db.query(query)

	if result and result is Array and result.size() > 0:
		return result[0][0]

	return 0

## Private Functions ##

# Initialize the database and create tables
func _init_database() -> void:
	# Check if gdsqlite is available
	if not ClassDB.class_exists("SQLite"):
		push_error("gdsqlite plugin not found. Database features will be disabled.")
		push_error("Install gdsqlite from: https://github.com/godotot/gdsqlite")
		database_initialized.emit(false)
		return

	# Create database instance
	db = SQLite.new()

	# Open or create database
	var full_path = ProjectSettings.globalize_path(DB_PATH)
	var result = db.open(full_path)

	if not result:
		push_error("Failed to open database at: ", DB_PATH)
		database_initialized.emit(false)
		return

	# Create tables if they don't exist
	_create_tables()

	print("Database initialized successfully at: ", DB_PATH)
	database_initialized.emit(true)

# Create database tables
func _create_tables() -> void:
	if not db:
		return

	# Create sessions table
	var sessions_table = """
		CREATE TABLE IF NOT EXISTS sessions (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			game_type TEXT NOT NULL,
			start_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
			duration_seconds INTEGER NOT NULL,
			metrics TEXT
		)
	"""
	db.execute(sessions_table)

	# Create paintings table
	var paintings_table = """
		CREATE TABLE IF NOT EXISTS paintings (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			source TEXT NOT NULL,
			filepath TEXT NOT NULL,
			created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
		)
	"""
	db.execute(paintings_table)

	# Create indexes for better query performance
	db.execute("CREATE INDEX IF NOT EXISTS idx_sessions_start_time ON sessions(start_time)")
	db.execute("CREATE INDEX IF NOT EXISTS idx_paintings_created_at ON paintings(created_at)")

	print("Database tables created/verified")
