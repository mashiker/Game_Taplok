extends Node

# TranslationManager - Global singleton for handling localization
# Supports Indonesian (id) and English (en) languages

## Signals ##
signal language_changed(lang_code: String)

## Constants ##
const DEFAULT_LOCALE: String = "id"
const SUPPORTED_LOCALES: PackedStringArray = ["id", "en"]

## Variables ##
var _current_locale: String = DEFAULT_LOCALE
var _translations: Dictionary = {}

## Built-in Functions ##
func _ready() -> void:
	_load_translations()

## Public Functions ##

# Get translated text for the given key
# @param key: Translation key in snake_case format (e.g., "game_tap_pop_name")
# @return: Translated string, or the key itself if not found
func get_text(key: String) -> String:
	if _translations.has(_current_locale) and _translations[_current_locale].has(key):
		return _translations[_current_locale][key]
	return key

# Set the current locale
# @param locale: Locale code (e.g., "id", "en")
func set_locale(locale: String) -> void:
	if locale in SUPPORTED_LOCALES:
		_current_locale = locale
		language_changed.emit(locale)
		print("Language changed to: ", locale)
	else:
		push_warning("Unsupported locale: ", locale, ". Using default: ", DEFAULT_LOCALE)
		_current_locale = DEFAULT_LOCALE

# Get the current locale
# @return: Current locale code
func get_locale() -> String:
	return _current_locale

# Check if a translation key exists
# @param key: Translation key to check
# @return: true if the key exists in current locale
func has_key(key: String) -> bool:
	return _translations.has(_current_locale) and _translations[_current_locale].has(key)

## Private Functions ##

# Load translation files from assets/locales/
func _load_translations() -> void:
	for locale in SUPPORTED_LOCALES:
		var file_path: String = "res://assets/locales/" + locale + ".json"
		if FileAccess.file_exists(file_path):
			var file = FileAccess.open(file_path, FileAccess.READ)
			if file:
				var json_text = file.get_as_text()
				file.close()
				var json = JSON.new()
				var parse_result = json.parse(json_text)
				if parse_result == OK:
					_translations[locale] = json.data
					print("Loaded translations for locale: ", locale)
				else:
					push_error("Failed to parse translation file: ", file_path)
			else:
				push_error("Failed to open translation file: ", file_path)
		else:
			push_warning("Translation file not found: ", file_path)
