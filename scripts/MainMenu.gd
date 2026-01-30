extends Control

# MainMenu - Main menu scene with game selection
# Displays game buttons, wayang mascot, and tap count

## Built-in Functions ##
func _ready() -> void:
	_setup_ui()
	_connect_signals()
	_update_tap_count()
	_apply_responsive_layout()
	# Keep layout stable when window/orientation changes (desktop/testing)
	get_viewport().size_changed.connect(_apply_responsive_layout)

## Private Functions ##

# Set up UI elements with translations
func _setup_ui() -> void:
	$VBoxContainer/GameGrid/TapPopButton.set_title(TranslationManager.get_text("game_tap_pop_name"))
	$VBoxContainer/GameGrid/DragMatchButton.set_title(TranslationManager.get_text("game_drag_match_name"))
	$VBoxContainer/GameGrid/MemoryFlipButton.set_title(TranslationManager.get_text("game_memory_flip_name"))
	$VBoxContainer/GameGrid/PianoHewanButton.set_title(TranslationManager.get_text("game_piano_hewan_name"))
	$VBoxContainer/GameGrid/FingerPaintButton.set_title(TranslationManager.get_text("game_finger_paint_name"))
	$VBoxContainer/GameGrid/ShapeSilhouetteButton.set_title(TranslationManager.get_text("game_shape_silhouette_name"))
	$VBoxContainer/GameGrid/ColoringBookButton.set_title(TranslationManager.get_text("game_coloring_book_name"))
	$VBoxContainer/GameGrid/MusicRhythmButton.set_title(TranslationManager.get_text("game_music_rhythm_name"))
	$VBoxContainer/GameGrid/FindTapButton.set_title(TranslationManager.get_text("game_find_tap_name"))
	$VBoxContainer/GameGrid/SoundMatchButton.set_title(TranslationManager.get_text("game_sound_match_name"))

# Connect button signals
func _connect_signals() -> void:
	var game_buttons = [
		$VBoxContainer/GameGrid/TapPopButton,
		$VBoxContainer/GameGrid/DragMatchButton,
		$VBoxContainer/GameGrid/MemoryFlipButton,
		$VBoxContainer/GameGrid/PianoHewanButton,
		$VBoxContainer/GameGrid/FingerPaintButton,
		$VBoxContainer/GameGrid/ShapeSilhouetteButton,
		$VBoxContainer/GameGrid/ColoringBookButton,
		$VBoxContainer/GameGrid/MusicRhythmButton,
		$VBoxContainer/GameGrid/FindTapButton,
		$VBoxContainer/GameGrid/SoundMatchButton
	]

	for button in game_buttons:
		if button:
			button.pressed.connect(_on_game_button_pressed.bind(button.name))

	var parent_button = $VBoxContainer/BottomBar/ParentButton
	if parent_button:
		parent_button.pressed.connect(_on_parent_button_pressed)

# Update tap count label
func _update_tap_count() -> void:
	var play_count = Database.get_todays_play_count()
	$VBoxContainer/BottomBar/TapCountLabel.text = TranslationManager.get_text("tap_count_label") % play_count

func _apply_responsive_layout() -> void:
	# The menu was originally authored for portrait. This keeps it readable on 1280x720.
	var vp := get_viewport_rect().size
	var is_landscape := vp.x >= vp.y

	var vbox: VBoxContainer = $VBoxContainer
	var grid: GridContainer = $VBoxContainer/GameGrid

	if is_landscape:
		# Wider container so cards can breathe.
		vbox.offset_left = -560.0
		vbox.offset_right = 560.0
		vbox.offset_top = -300.0
		vbox.offset_bottom = 300.0
		vbox.set("theme_override_constants/separation", 14)

		grid.columns = 5
		grid.set("theme_override_constants/h_separation", 16)
		grid.set("theme_override_constants/v_separation", 16)
	else:
		# Original portrait-ish layout.
		vbox.offset_left = -240.0
		vbox.offset_right = 240.0
		vbox.offset_top = -380.0
		vbox.offset_bottom = 380.0
		vbox.set("theme_override_constants/separation", 18)

		grid.columns = 3
		grid.set("theme_override_constants/h_separation", 14)
		grid.set("theme_override_constants/v_separation", 14)

## Signal Callbacks ##

# Handle game button press
func _on_game_button_pressed(button_name: String) -> void:
	var scene_path = ""
	match button_name:
		"TapPopButton":
			scene_path = "res://scenes/TapPopGame.tscn"
		"DragMatchButton":
			scene_path = "res://scenes/DragMatchGame.tscn"
		"MemoryFlipButton":
			scene_path = "res://scenes/MemoryFlipGame.tscn"
		"PianoHewanButton":
			scene_path = "res://scenes/PianoGame.tscn"
		"FingerPaintButton":
			scene_path = "res://scenes/FingerPaintGame.tscn"
		"ShapeSilhouetteButton":
			scene_path = "res://scenes/ShapeMatchGame.tscn"
		"ColoringBookButton":
			scene_path = "res://scenes/ColoringGame.tscn"
		"MusicRhythmButton":
			scene_path = "res://scenes/RhythmGame.tscn"
		"FindTapButton":
			scene_path = "res://scenes/FindTapThemeSelect.tscn"
		"SoundMatchButton":
			scene_path = "res://scenes/SoundMatchGame.tscn"

	if scene_path != "":
		GameManager.fade_to_scene(scene_path)

# Handle parent button press
func _on_parent_button_pressed() -> void:
	GameManager.fade_to_scene("res://scenes/ParentDashboard.tscn")
