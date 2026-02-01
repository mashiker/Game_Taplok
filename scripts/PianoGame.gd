extends "res://scripts/GameSceneBase.gd"

# PianoGame - Animal piano game with multi-touch support
# Children tap keys to hear animal sounds

class_name PianoGame

## Constants ##
const KEY_WIDTH: int = 50
const KEY_HEIGHT: int = 150
const KEY_SPACING: int = 2
const INACTIVITY_TIMEOUT: float = 900.0  # 15 minutes in seconds
const MAX_POLYPHONY: int = 3  # Maximum simultaneous sounds

## Key Mappings ##
const KEY_DATA: Dictionary = {
	"C4": {
		"animal": "Komodo",
		"sound": "animals/komodo.ogg",
		"color": Color(0.92, 0.3, 0.24)  # Red #E84A3D
	},
	"D4": {
		"animal": "Orangutan",
		"sound": "animals/orangutan.ogg",
		"color": Color(0.22, 0.74, 0.97)  # Blue #38BDF8
	},
	"E4": {
		"animal": "Burung",
		"sound": "animals/burung.ogg",
		"color": Color(0.98, 0.75, 0.14)  # Yellow #FBBF24
	},
	"F4": {
		"animal": "Paus",
		"sound": "animals/paus.ogg",
		"color": Color(0.2, 0.83, 0.6)  # Green #34D399
	},
	"G4": {
		"animal": "Belalang",
		"sound": "animals/belalang.ogg",
		"color": Color(1, 0.6, 0)  # Orange
	}
}

## Variables ##
var piano_keys: Array[PianoKey] = []
var active_sounds: int = 0
var inactivity_timer: float = 0.0
var wayang_dancing: bool = false

var _unique_keys_pressed := {} # key_id -> true
var _target_unique := 5
var _goal_rewarded := false
const GAME_ID := "piano_hewan"
const SCENE_PATH := "res://scenes/PianoGame.tscn"
var current_level: int = 1
var sequence_length: int = 1
var animals_in_pool: Array[String] = []

## Node References ##
var keys_container: HBoxContainer = null
var wayang_sprite: AnimatedSprite2D = null

## Built-in Functions ##
func _ready() -> void:
	# Set game name before calling parent _ready
	game_name = "Piano Hewan"
	super._ready()

	# HUD
	_update_hud()

	# Set up the piano game
	_apply_level_config()
	_setup_piano()
	_start_inactivity_timer()

func _process(delta: float) -> void:
	if not is_active:
		return

	# Update inactivity timer
	_update_inactivity_timer(delta)

	# Update wayang dance animation
	_update_wayang_dance()

## Virtual Functions Overrides ##

func _on_game_start() -> void:
	super._on_game_start()
	# Start session tracking
	SessionManager.start_session(game_name)
	SessionManager.set_metric("content_category", "musical")

func _on_game_end() -> void:
	super._on_game_end()
	# Stop all sounds
	_stop_all_sounds()
	# End session
	SessionManager.end_session()

## Private Functions ##

func _apply_level_config() -> void:
	var pm: Node = get_node_or_null("/root/ProgressManager")
	current_level = int(pm.get_level(GAME_ID)) if pm else 1
	var cfg: Dictionary = pm.get_level_config(GAME_ID, current_level) if pm else {}
	if cfg.is_empty():
		# Default level 1 values
		sequence_length = 1
		animals_in_pool = ["kucing"]
	else:
		sequence_length = int(cfg.get("sequence_length", sequence_length))
		var pool = cfg.get("animals_in_pool", [])
		if typeof(pool) == TYPE_ARRAY and pool.size() > 0:
			animals_in_pool.clear()
			for a in pool:
				animals_in_pool.append(str(a))

# Set up the piano keyboard
func _setup_piano() -> void:
	# Get the game content container
	var game_content = $GameContainer/GameContent
	if not game_content:
		push_error("PianoGame._setup_piano: GameContent node not found")
		return

	# Create main container for piano
	var main_container = VBoxContainer.new()
	main_container.name = "PianoContainer"
	main_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.add_theme_constant_override("separation", 20)
	game_content.add_child(main_container)

	# Add spacer at top
	var top_spacer = Control.new()
	top_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.add_child(top_spacer)

	# Create keys container
	keys_container = HBoxContainer.new()
	keys_container.name = "KeysContainer"
	keys_container.alignment = BoxContainer.ALIGNMENT_CENTER
	keys_container.add_theme_constant_override("separation", KEY_SPACING)
	main_container.add_child(keys_container)

	# Create piano keys (only from animals_in_pool for this level)
	for key_id in KEY_DATA.keys():
		var animal_name: String = KEY_DATA[key_id].animal
		if animals_in_pool.has(animal_name):
			_create_piano_key(key_id)

	# Add spacer at bottom
	var bottom_spacer = Control.new()
	bottom_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.add_child(bottom_spacer)

# Create a single piano key
func _create_piano_key(key_id: String) -> void:
	var key_data = KEY_DATA[key_id]

	# Load PianoKey scene
	var key_scene = load("res://scenes/PianoKey.tscn")
	if not key_scene:
		push_error("PianoGame._create_piano_key: failed to load PianoKey.tscn")
		return

	var key_instance = key_scene.instantiate() as PianoKey
	if not key_instance:
		push_error("PianoGame._create_piano_key: failed to instantiate PianoKey")
		return

	# Set key properties
	key_instance.key_id = key_id
	key_instance.animal_name = key_data.animal
	key_instance.sound_path = key_data.sound
	key_instance.base_color = key_data.color

	# Connect signals
	key_instance.key_pressed.connect(_on_key_pressed.bind(key_id))
	key_instance.key_released.connect(_on_key_released.bind(key_id))

	# Add to container
	keys_container.add_child(key_instance)
	piano_keys.append(key_instance)

# Start the inactivity timer
func _start_inactivity_timer() -> void:
	inactivity_timer = 0.0

# Update the inactivity timer
func _update_inactivity_timer(delta: float) -> void:
	inactivity_timer += delta

	# Check if timeout reached
	if inactivity_timer >= INACTIVITY_TIMEOUT:
		_fade_to_menu_on_inactivity()

# Reset the inactivity timer
func _reset_inactivity_timer() -> void:
	inactivity_timer = 0.0

# Fade to menu on inactivity
func _fade_to_menu_on_inactivity() -> void:
	# Show "Sampai jumpa!" message
	print("Piano Hewan: Inactivity timeout - fading to menu")
	GameManager.fade_to_scene("res://scenes/MainMenu.tscn")

# Handle key press
func _on_key_pressed(key_id: String) -> void:
	# Record tap
	SessionManager.record_tap()

	# Reset inactivity timer
	_reset_inactivity_timer()

	# Check polyphony limit
	if active_sounds < MAX_POLYPHONY:
		active_sounds += 1

	# Reward feedback + progress
	var is_new := not _unique_keys_pressed.has(key_id)
	if is_new:
		_unique_keys_pressed[key_id] = true
		RewardSystem.reward_success(_get_key_global_center(key_id), 0.9)
	else:
		RewardSystem.reward_tap(_get_key_global_center(key_id))
	_update_hud()

	# Start wayang dance
	_start_wayang_dance()

	print("Piano Hewan: Key pressed ", key_id, " (", KEY_DATA[key_id].animal, ")")

# Handle key release
func _on_key_released(key_id: String) -> void:
	# Decrease active sound count
	if active_sounds > 0:
		active_sounds -= 1

	print("Piano Hewan: Key released ", key_id)

# Start wayang dance animation
func _start_wayang_dance() -> void:
	wayang_dancing = true

	# Get wayang sprite reference
	if wayang_sprite == null:
		wayang_sprite = $GameContainer/TopBar/WayangMascot

	if wayang_sprite:
		# Start dance animation
		if wayang_sprite.sprite_frames and wayang_sprite.sprite_frames.has_animation("dance"):
			if wayang_sprite.animation != "dance":
				wayang_sprite.play("dance")

# Stop wayang dance animation
func _stop_wayang_dance() -> void:
	wayang_dancing = false

	if wayang_sprite:
		# Return to idle animation
		if wayang_sprite.sprite_frames and wayang_sprite.sprite_frames.has_animation("idle"):
			wayang_sprite.play("idle")

# Update wayang dance based on active sounds
func _update_wayang_dance() -> void:
	# If no sounds are playing, stop dancing
	if wayang_dancing and active_sounds <= 0:
		_stop_wayang_dance()

func _update_hud() -> void:
	var obj := $GameContainer/TopBar/ObjectiveLabel
	var prog := $GameContainer/TopBar/ProgressLabel
	if obj:
		obj.text = "Coba semua hewan"
	if prog:
		prog.text = str(_unique_keys_pressed.size()) + "/" + str(_target_unique)

	if not _goal_rewarded and _unique_keys_pressed.size() >= _target_unique:
		_goal_rewarded = true
		RewardSystem.reward_success(get_viewport().get_visible_rect().size * 0.5, 1.6)
		await _handle_level_complete(true)

func _get_key_global_center(key_id: String) -> Vector2:
	for k in piano_keys:
		if k and k.key_id == key_id:
			return k.global_position + (k.size * 0.5)
	return get_viewport().get_mouse_position()

func _handle_level_complete(success: bool) -> void:
	var pm: Node = get_node_or_null("/root/ProgressManager")
	var res: Dictionary = pm.complete_level(GAME_ID, success) if pm else {"leveled_up": false, "new_level": current_level, "max_level": current_level}
	var leveled_up: bool = bool(res.get("leveled_up", false))
	var new_level: int = int(res.get("new_level", current_level))
	var max_level: int = int(res.get("max_level", pm.get_max_level(GAME_ID) if pm else current_level))

	var overlay_ps: PackedScene = preload("res://scenes/ui/LevelUpOverlay.tscn")
	var overlay = overlay_ps.instantiate()
	get_tree().root.add_child(overlay)
	if overlay.has_method("setup"):
		overlay.setup(new_level, new_level >= max_level)
	await overlay.finished

	if leveled_up:
		var gm: Node = get_node_or_null("/root/GameManager")
		if gm:
			gm.fade_to_scene(SCENE_PATH)
	else:
		await get_tree().create_timer(0.6).timeout
		var gm: Node = get_node_or_null("/root/GameManager")
		if gm:
			gm.fade_to_scene("res://scenes/MainMenu.tscn")

# Stop all sounds
func _stop_all_sounds() -> void:
	for key in piano_keys:
		if key:
			key.stop_sound()
	active_sounds = 0

## Public Functions ##

# Get game metrics for session tracking
func _get_game_metrics() -> Dictionary:
	var base_metrics = super._get_game_metrics()
	base_metrics["keys_pressed"] = SessionManager.get_metric("tap_count", 0)
	base_metrics["polyphonic_events"] = 0  # Could track this if needed
	return base_metrics
