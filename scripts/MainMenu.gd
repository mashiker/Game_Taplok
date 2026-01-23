extends Control

# MainMenu - Main menu scene with game selection
# Displays game buttons, wayang mascot, and tap count

## Built-in Functions ##
func _ready() -> void:
	_setup_ui()
	_connect_signals()
	_update_tap_count()

## Private Functions ##

# Set up UI elements with translations
func _setup_ui() -> void:
	$VBoxContainer/BottomBar/TapCountLabel.text = TranslationManager.get_text("app_name")

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
		$VBoxContainer/GameGrid/MusicRhythmButton
	]

	for button in game_buttons:
		if button:
			button.pressed.connect(_on_game_button_pressed.bind(button.name))

	var parent_button = $VBoxContainer/BottomBar/ParentButton
	if parent_button:
		parent_button.pressed.connect(_on_parent_button_pressed)

# Update tap count label
func _update_tap_count() -> void:
	# TODO: Get actual tap count from database/session
	$VBoxContainer/BottomBar/TapCountLabel.text = "Main 0x hari ini"

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

	if scene_path != "":
		GameManager.fade_to_scene(scene_path)

# Handle parent button press
func _on_parent_button_pressed() -> void:
	GameManager.fade_to_scene("res://scenes/ParentDashboard.tscn")
