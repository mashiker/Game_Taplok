extends Control

# GameSceneBase - Base template for all mini-game scenes
# Provides common UI elements (back button, wayang mascot) and game lifecycle

class_name GameSceneBase

## Signals ##
signal game_exited()

## Variables ##
var game_name: String = ""
var is_active: bool = false

## Built-in Functions ##
func _ready() -> void:
	_setup_ui()
	_connect_signals()
	_on_game_start()

func _exit_tree() -> void:
	_on_game_end()

## Virtual Functions (Override in derived games) ##

# Called when game starts - override for game-specific initialization
func _on_game_start() -> void:
	is_active = true
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm:
		gm.start_game(game_name)
	print("Game started: ", game_name)

# Called when game ends - override for cleanup
func _on_game_end() -> void:
	is_active = false
	var metrics = _get_game_metrics()
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm:
		gm.end_game(metrics)
	print("Game ended: ", game_name, " metrics: ", metrics)

# Get game metrics for session tracking - override as needed
func _get_game_metrics() -> Dictionary:
	return {"duration": 0, "actions": 0}

## Private Functions ##

# Set up UI elements with translations
func _setup_ui() -> void:
	var back_button = $GameContainer/TopBar/BackButton
	if back_button:
		var tm: Node = get_node_or_null("/root/TranslationManager")
		back_button.text = tm.get_text("back") if tm else "Back"

# Connect button signals
func _connect_signals() -> void:
	var back_button = $GameContainer/TopBar/BackButton
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

## Signal Callbacks ##

# Handle back button press
func _on_back_pressed() -> void:
	game_exited.emit()
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm:
		gm.fade_to_scene("res://scenes/MainMenu.tscn")
