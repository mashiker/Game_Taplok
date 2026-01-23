extends Control

# ParentDashboard - PIN-protected parent control panel
# Handles child profile, statistics, gallery, settings, and legal info

## Constants ##
const DEFAULT_PIN: String = "1234"
const SETTINGS_PATH: String = "user://settings.json"
const CHILD_PROFILE_PATH: String = "user://child_profile.json"
const APP_SETTINGS_PATH: String = "user://app_settings.json"
const LEGAL_PRIVACY_PATH: String = "res://assets/legal/privacy_policy_id.txt"
const LEGAL_TERMS_PATH: String = "res://assets/legal/terms_id.txt"

## Variables ##
var current_pin: String = ""
var child_profile: Dictionary = {}
var app_settings: Dictionary = {}
var is_authenticated: bool = false
var session_stats: Dictionary = {}
var paintings_data: Array = []

## Built-in Functions ##
func _ready() -> void:
	_load_settings()
	_load_child_profile()
	_load_app_settings()
	_show_pin_login()

## Private Functions ##

# Load PIN from settings
func _load_settings() -> void:
	if FileAccess.file_exists(SETTINGS_PATH):
		var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
		if file:
			var data = JSON.parse_string(file.get_as_text())
			if data and data.has("pin"):
				current_pin = data.pin
			file.close()

	if current_pin.is_empty():
		current_pin = DEFAULT_PIN
		_save_settings()

# Save PIN to settings
func _save_settings() -> void:
	var data = {"pin": current_pin}
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

# Load child profile
func _load_child_profile() -> void:
	if FileAccess.file_exists(CHILD_PROFILE_PATH):
		var file = FileAccess.open(CHILD_PROFILE_PATH, FileAccess.READ)
		if file:
			var data = JSON.parse_string(file.get_as_text())
			if data:
				child_profile = data
			file.close()
	else:
		child_profile = {
			"name": "",
			"age": 3,
			"preferences": {
				"tap_pop": true,
				"drag_match": true,
				"memory_flip": true,
				"piano_hewan": true,
				"finger_paint": true,
				"shape_silhouette": true,
				"coloring_book": true,
				"music_rhythm": true
			}
		}

# Save child profile
func _save_child_profile() -> void:
	var file = FileAccess.open(CHILD_PROFILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(child_profile))
		file.close()

# Load app settings
func _load_app_settings() -> void:
	if FileAccess.file_exists(APP_SETTINGS_PATH):
		var file = FileAccess.open(APP_SETTINGS_PATH, FileAccess.READ)
		if file:
			var data = JSON.parse_string(file.get_as_text())
			if data:
				app_settings = data
			file.close()
	else:
		app_settings = {
			"language": "id",
			"background_volume": -8.0,
			"sfx_volume": -3.0,
			"voice_volume": -4.0,
			"screen_timeout": 10,
			"app_size": "lite"
		}

# Save app settings
func _save_app_settings() -> void:
	var file = FileAccess.open(APP_SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(app_settings))
		file.close()

# Show PIN login panel
func _show_pin_login() -> void:
	$PINLoginPanel.visible = true
	$DashboardContent.visible = false
	_clear_pin_inputs()
	$PINLoginPanel/PINVBox/PINErrorLabel.visible = false

# Hide PIN login and show dashboard
func _show_dashboard() -> void:
	$PINLoginPanel.visible = false
	$DashboardContent.visible = true
	_refresh_dashboard()

# Clear PIN input fields
func _clear_pin_inputs() -> void:
	$PINLoginPanel/PINVBox/PINContainer/PIN1.text = ""
	$PINLoginPanel/PINVBox/PINContainer/PIN2.text = ""
	$PINLoginPanel/PINVBox/PINContainer/PIN3.text = ""
	$PINLoginPanel/PINVBox/PINContainer/PIN4.text = ""
	$PINLoginPanel/PINVBox/PINContainer/PIN1.grab_focus()

# Get entered PIN from LineEdit nodes
func _get_entered_pin() -> String:
	return (
		$PINLoginPanel/PINVBox/PINContainer/PIN1.text +
		$PINLoginPanel/PINVBox/PINContainer/PIN2.text +
		$PINLoginPanel/PINVBox/PINContainer/PIN3.text +
		$PINLoginPanel/PINVBox/PINContainer/PIN4.text
	)

# Verify PIN
func _verify_pin(pin: String) -> bool:
	return pin == current_pin

# Shake animation for incorrect PIN
func _shake_pin_panel() -> void:
	var tween = create_tween()
	var panel = $PINLoginPanel
	var original_pos = panel.position
	tween.set_parallel(false)
	tween.tween_property(panel, "position", original_pos + Vector2(10, 0), 0.05)
	tween.tween_property(panel, "position", original_pos + Vector2(-10, 0), 0.05)
	tween.tween_property(panel, "position", original_pos + Vector2(10, 0), 0.05)
	tween.tween_property(panel, "position", original_pos + Vector2(-10, 0), 0.05)
	tween.tween_property(panel, "position", original_pos, 0.05)

# Refresh all dashboard data
func _refresh_dashboard() -> void:
	_refresh_child_profile_ui()
	_refresh_statistics()
	_refresh_gallery()
	_refresh_settings_ui()

# Refresh child profile UI
func _refresh_child_profile_ui() -> void:
	var vbox = $DashboardContent/TabContainer/ChildProfile/ChildProfileScroll/ChildProfileVBox
	vbox.get_node("NameInput").text = child_profile.get("name", "")

	var age = child_profile.get("age", 3)
	vbox.get_node("AgeSlider").value = age
	vbox.get_node("AgeLabel").text = TranslationManager.get_text("pd_child_age") + ": " + str(age) + " " + TranslationManager.get_text("pd_child_age_years")
	vbox.get_node("AgeValueLabel").text = str(age)

	var prefs = child_profile.get("preferences", {})
	var prefs_grid = vbox.get_node("PrefsGrid")
	var games = ["PrefTapPop", "PrefDragMatch", "PrefMemoryFlip", "PrefPiano",
				 "PrefFingerPaint", "PrefShape", "PrefColoring", "PrefRhythm"]
	var game_keys = ["tap_pop", "drag_match", "memory_flip", "piano_hewan",
					 "finger_paint", "shape_silhouette", "coloring_book", "music_rhythm"]

	for i in range(games.size()):
		var checkbox = prefs_grid.get_node(games[i])
		if checkbox:
			checkbox.button_pressed = prefs.get(game_keys[i], true)

# Refresh statistics data
func _refresh_statistics() -> void:
	session_stats = Database.get_session_stats(7)

	var vbox = $DashboardContent/TabContainer/Statistics/StatisticsScroll/StatisticsVBox

	# Update today's label
	var today_seconds = session_stats.get("by_date", {}).get(OS.get_date()["string"], 0)
	var today_hours = today_seconds / 3600.0
	var today_plays = 0
	for date in session_stats.get("by_date", {}):
		if date == OS.get_date()["string"]:
			today_plays += 1

	vbox.get_node("TodayLabel").text = TranslationManager.get_text("pd_today") + ": %.1f %s (%d %s)" % [
		today_hours,
		TranslationManager.get_text("pd_hours"),
		today_plays,
		TranslationManager.get_text("pd_plays")
	]

	# Update games list
	var games_list = vbox.get_node("GamesList")
	games_list.clear()
	var game_counts = session_stats.get("game_counts", {})
	if game_counts.is_empty():
		games_list.add_item(TranslationManager.get_text("pd_no_data"))
	else:
		for game_type in game_counts:
			var count = game_counts[game_type]
			var display_name = TranslationManager.get_text("game_" + game_type + "_name")
			games_list.add_item(display_name + ": " + str(count) + " " + TranslationManager.get_text("pd_plays"))

	# Trigger chart redraw
	vbox.get_node("ChartPanel/ChartDraw").queue_redraw()

# Refresh gallery
func _refresh_gallery() -> void:
	paintings_data = Database.get_paintings()

	var vbox = $DashboardContent/TabContainer/Gallery/GalleryScroll/GalleryVBox
	var grid = vbox.get_node("GalleryGrid")

	# Clear existing items (except label)
	for child in grid.get_children():
		if child.name != "NoPaintingsLabel":
			child.queue_free()

	await get_tree().process_frame

	if paintings_data.is_empty():
		grid.get_node("NoPaintingsLabel").visible = true
	else:
		grid.get_node("NoPaintingsLabel").visible = false
		for painting in paintings_data:
			var painting_entry = _create_painting_entry(painting)
			grid.add_child(painting_entry)

# Create a painting entry for gallery
func _create_painting_entry(painting: Dictionary) -> Control:
	var container = VBoxContainer.new()
	container.custom_minimum_size = Vector2(120, 150)

	# Thumbnail
	var texture_rect = TextureRect.new()
	texture_rect.custom_minimum_size = Vector2(100, 100)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_SCALE

	if FileAccess.file_exists(painting.filepath):
		var image = Image.new()
		if image.load(painting.filepath) == OK:
			var texture = ImageTexture.create_from_image(image)
			texture_rect.texture = texture

	texture_rect.gui_input.connect(_on_painting_clicked.bind(painting))
	container.add_child(texture_rect)

	# Date label
	var date_label = Label.new()
	var datetime = Dictionary()
	if painting.has("created_at") and painting.created_at != null:
		datetime = Time.get_datetime_dict_from_datetime_string(painting.created_at, false)
	date_label.text = "%02d/%02d/%04d" % [datetime.day, datetime.month, datetime.year]
	date_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(date_label)

	# Buttons
	var btn_container = HBoxContainer.new()
	btn_container.alignment = BoxContainer.ALIGNMENT_CENTER

	var download_btn = Button.new()
	download_btn.text = TranslationManager.get_text("pd_download")
	download_btn.pressed.connect(_on_download_painting.bind(painting))
	download_btn.custom_minimum_size = Vector2(50, 30)
	btn_container.add_child(download_btn)

	var delete_btn = Button.new()
	delete_btn.text = TranslationManager.get_text("pd_delete")
	delete_btn.pressed.connect(_on_delete_painting.bind(painting, container))
	delete_btn.custom_minimum_size = Vector2(50, 30)
	btn_container.add_child(delete_btn)

	container.add_child(btn_container)

	return container

# Refresh settings UI
func _refresh_settings_ui() -> void:
	var vbox = $DashboardContent/TabContainer/Settings/SettingsScroll/SettingsVBox

	# Language
	var lang_option = vbox.get_node("LanguageOption")
	lang_option.selected = 0 if app_settings.get("language", "id") == "id" else 1

	# Audio volumes
	vbox.get_node("AudioSection/BgVolSlider").value = app_settings.get("background_volume", -8.0)
	vbox.get_node("AudioSection/SfxVolSlider").value = app_settings.get("sfx_volume", -3.0)
	vbox.get_node("AudioSection/VoiceVolSlider").value = app_settings.get("voice_volume", -4.0)

	# Timeout
	var timeout = app_settings.get("screen_timeout", 10)
	var timeout_idx = 0
	match timeout:
		5: timeout_idx = 0
		10: timeout_idx = 1
		15: timeout_idx = 2
		_: timeout_idx = 3
	vbox.get_node("TimeoutOption").selected = timeout_idx

	# App size
	var app_size = app_settings.get("app_size", "lite")
	vbox.get_node("AppSizeOption").selected = 0 if app_size == "lite" else 1

## Signal Callbacks ##

# PIN entered - handle focus movement
func _on_pin_entered(text: String) -> void:
	var sender = get_viewport().gui_get_focus_owner()
	if sender == $PINLoginPanel/PINVBox/PINContainer/PIN1 and text.length() == 1:
		$PINLoginPanel/PINVBox/PINContainer/PIN2.grab_focus()
	elif sender == $PINLoginPanel/PINVBox/PINContainer/PIN2 and text.length() == 1:
		$PINLoginPanel/PINVBox/PINContainer/PIN3.grab_focus()
	elif sender == $PINLoginPanel/PINVBox/PINContainer/PIN3 and text.length() == 1:
		$PINLoginPanel/PINVBox/PINContainer/PIN4.grab_focus()
	elif sender == $PINLoginPanel/PINVBox/PINContainer/PIN4 and text.length() == 1:
		_verify_and_show_dashboard()

# Cancel PIN login
func _on_pin_cancel_pressed() -> void:
	GameManager.fade_to_scene("res://scenes/MainMenu.tscn")

# Verify PIN and show dashboard
func _verify_and_show_dashboard() -> void:
	var entered_pin = _get_entered_pin()
	if _verify_pin(entered_pin):
		is_authenticated = true
		_show_dashboard()
	else:
		_shake_pin_panel()
		_clear_pin_inputs()
		$PINLoginPanel/PINVBox/PINErrorLabel.visible = true

# Back to menu button
func _on_back_button_pressed() -> void:
	GameManager.fade_to_scene("res://scenes/MainMenu.tscn")

# Child profile - age slider changed
func _on_age_slider_changed(value: float) -> void:
	var age = int(value)
	$DashboardContent/TabContainer/ChildProfile/ChildProfileScroll/ChildProfileVBox/AgeLabel.text = (
		TranslationManager.get_text("pd_child_age") + ": " + str(age) + " " + TranslationManager.get_text("pd_child_age_years")
	)
	$DashboardContent/TabContainer/ChildProfile/ChildProfileScroll/ChildProfileVBox/AgeValueLabel.text = str(age)

# Save child profile
func _on_child_profile_save() -> void:
	var vbox = $DashboardContent/TabContainer/ChildProfile/ChildProfileScroll/ChildProfileVBox

	child_profile["name"] = vbox.get_node("NameInput").text
	child_profile["age"] = int(vbox.get_node("AgeSlider").value)

	var prefs = {}
	var prefs_grid = vbox.get_node("PrefsGrid")
	prefs["tap_pop"] = prefs_grid.get_node("PrefTapPop").button_pressed
	prefs["drag_match"] = prefs_grid.get_node("PrefDragMatch").button_pressed
	prefs["memory_flip"] = prefs_grid.get_node("PrefMemoryFlip").button_pressed
	prefs["piano_hewan"] = prefs_grid.get_node("PrefPiano").button_pressed
	prefs["finger_paint"] = prefs_grid.get_node("PrefFingerPaint").button_pressed
	prefs["shape_silhouette"] = prefs_grid.get_node("PrefShape").button_pressed
	prefs["coloring_book"] = prefs_grid.get_node("PrefColoring").button_pressed
	prefs["music_rhythm"] = prefs_grid.get_node("PrefRhythm").button_pressed
	child_profile["preferences"] = prefs

	_save_child_profile()
	GameManager.set_child_age(child_profile["age"])

	# Show feedback
	AudioManager.play_sfx("success.ogg")

# Volume drag started - prevent slider from immediately jumping
func _on_volume_drag_started() -> void:
	pass

# Background volume changed
func _on_bg_volume_changed(value: float) -> void:
	var vbox = $DashboardContent/TabContainer/Settings/SettingsScroll/SettingsVBox
	vbox.get_node("AudioSection/BgVolLabel").text = TranslationManager.get_text("pd_audio_bg") + ": %.0f dB" % value
	AudioManager.set_volume("Background", value)

# SFX volume changed
func _on_sfx_volume_changed(value: float) -> void:
	var vbox = $DashboardContent/TabContainer/Settings/SettingsScroll/SettingsVBox
	vbox.get_node("AudioSection/SfxVolLabel").text = TranslationManager.get_text("pd_audio_sfx") + ": %.0f dB" % value
	AudioManager.set_volume("SFX", value)

# Voice volume changed
func _on_voice_volume_changed(value: float) -> void:
	var vbox = $DashboardContent/TabContainer/Settings/SettingsScroll/SettingsVBox
	vbox.get_node("AudioSection/VoiceVolLabel").text = TranslationManager.get_text("pd_audio_voice") + ": %.0f dB" % value
	AudioManager.set_volume("Voice", value)

# Save settings
func _on_settings_save() -> void:
	var vbox = $DashboardContent/TabContainer/Settings/SettingsScroll/SettingsVBox

	# Language
	var lang_idx = vbox.get_node("LanguageOption").selected
	app_settings["language"] = "id" if lang_idx == 0 else "en"
	TranslationManager.set_locale(app_settings["language"])

	# Audio
	app_settings["background_volume"] = vbox.get_node("AudioSection/BgVolSlider").value
	app_settings["sfx_volume"] = vbox.get_node("AudioSection/SfxVolSlider").value
	app_settings["voice_volume"] = vbox.get_node("AudioSection/VoiceVolSlider").value

	# Timeout
	var timeout_idx = vbox.get_node("TimeoutOption").selected
	match timeout_idx:
		0: app_settings["screen_timeout"] = 5
		1: app_settings["screen_timeout"] = 10
		2: app_settings["screen_timeout"] = 15
		3: app_settings["screen_timeout"] = -1

	# App size (informational only)
	var size_idx = vbox.get_node("AppSizeOption").selected
	app_settings["app_size"] = "lite" if size_idx == 0 else "full"

	_save_app_settings()
	AudioManager.play_sfx("success.ogg")

# Change PIN button pressed
func _on_pin_change_button_pressed() -> void:
	$PINChangeDialog.popup_centered()

# Confirm PIN change
func _on_pin_change_confirmed() -> void:
	var vbox = $PINChangeDialog/PINChangeVBox
	var old_pin = vbox.get_node("OldPINInput").text
	var new_pin = vbox.get_node("NewPINInput").text
	var confirm_pin = vbox.get_node("ConfirmPINInput").text

	if old_pin != current_pin:
		vbox.get_node("PINErrorLabel2").text = TranslationManager.get_text("pd_pin_incorrect")
		vbox.get_node("PINErrorLabel2").visible = true
		return

	if new_pin.length() != 4:
		vbox.get_node("PINErrorLabel2").text = TranslationManager.get_text("pd_pin_new") + " must be 4 digits"
		vbox.get_node("PINErrorLabel2").visible = true
		return

	if new_pin != confirm_pin:
		vbox.get_node("PINErrorLabel2").text = TranslationManager.get_text("pd_pin_mismatch")
		vbox.get_node("PINErrorLabel2").visible = true
		return

	current_pin = new_pin
	_save_settings()
	$PINChangeDialog.hide()

	# Clear inputs
	vbox.get_node("OldPINInput").text = ""
	vbox.get_node("NewPINInput").text = ""
	vbox.get_node("ConfirmPINInput").text = ""
	vbox.get_node("PINErrorLabel2").visible = false

	AudioManager.play_sfx("success.ogg")

# Privacy policy button
func _on_privacy_button_pressed() -> void:
	_show_legal_document(LEGAL_PRIVACY_PATH, TranslationManager.get_text("pd_privacy_policy"))

# Terms button
func _on_terms_button_pressed() -> void:
	_show_legal_document(LEGAL_TERMS_PATH, TranslationManager.get_text("pd_terms"))

# Show legal document in dialog
func _show_legal_document(path: String, title: String) -> void:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()

			$LegalDialog.title = title
			$LegalDialog/LegalDialogScroll/LegalDialogText.text = content
			$LegalDialog.popup_centered()

# Legal dialog close
func _on_legal_dialog_close() -> void:
	$LegalDialog.hide()

# Painting clicked - show full size
func _on_painting_clicked(painting: Dictionary, event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if FileAccess.file_exists(painting.filepath):
			var image = Image.new()
			if image.load(painting.filepath) == OK:
				var texture = ImageTexture.create_from_image(image)
				$ImagePopup/ImageTexture.texture = texture
				$ImagePopup.popup_centered()

# Image popup close
func _on_image_popup_close() -> void:
	$ImagePopup.hide()

# Download painting
func _on_download_painting(painting: Dictionary) -> void:
	# For Android, copy to Downloads directory
	if FileAccess.file_exists(painting.filepath):
		var source_file = FileAccess.open(painting.filepath, FileAccess.READ)
		if source_file:
			var data = source_file.get_buffer(source_file.get_length())
			source_file.close()

			# Create download path based on OS
			var download_path = ""
			if OS.has_feature("android"):
				download_path = "user://downloads/" + painting.filepath.get_file()
			else:
				download_path = "user://downloads/" + painting.filepath.get_file()

			# Ensure downloads directory exists
			DirAccess.open("user://").make_dir("downloads")

			var dest_file = FileAccess.open(download_path, FileAccess.WRITE)
			if dest_file:
				dest_file.store_buffer(data)
				dest_file.close()
				AudioManager.play_sfx("success.ogg")

# Delete painting
func _on_delete_painting(painting: Dictionary, container: Control) -> void:
	# Show confirmation (simplified - in real app use confirmation dialog)
	Database.delete_painting(painting.id)
	container.queue_free()
	AudioManager.play_sfx("success.ogg")
	_refresh_gallery()

# Draw chart for statistics
func _on_chart_draw() -> void:
	var control = $DashboardContent/TabContainer/Statistics/StatisticsScroll/StatisticsVBox/ChartPanel/ChartDraw
	if not control or not control.is_visible_in_tree():
		return

	control.queue_redraw()
