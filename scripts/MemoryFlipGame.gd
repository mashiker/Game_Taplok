extends Control

# MemoryFlipGame - Memory card matching game
# Children flip cards to find matching pairs

class_name MemoryFlipGame

## Constants ##
const MATCH_DELAY: float = 0.5
const RESET_DELAY: float = 0.5
const WIN_DELAY: float = 3.0

const CARD_SCENE: PackedScene = preload("res://scenes/Card.tscn")

## State Enums ##
enum GameState {
	IDLE,
	FLIPPING,
	WAITING,
	RESET,
	WON
}

## Variables ##
var game_name: String = "Memory Flip"
var cards: Array[Card] = []
var flipped_cards: Array[Card] = []
var game_state: GameState = GameState.IDLE
var child_age: int = 3  # Default age
var grid_rows: int = 2
var grid_cols: int = 2
var total_pairs: int = 0
var matched_pairs: int = 0

## Node References ##
@onready var game_scene_base: Control = $GameSceneBase
@onready var card_container: GridContainer = $GameSceneBase/CardContainer
@onready var win_label: Label = $GameSceneBase/WinLabel
@onready var check_timer: Timer = $CheckTimer
@onready var reset_timer: Timer = $ResetTimer
@onready var win_timer: Timer = $WinTimer

## Built-in Functions ##
func _ready() -> void:
	# Load child age from settings
	_load_child_age()
	_setup_game()
	_connect_signals()

## Virtual Function Overrides ##

# Override from GameSceneBase
func _on_game_start() -> void:
	is_active = true
	GameManager.start_game(game_name)
	SessionManager.start_session(game_name, "cognitive")
	SessionManager.set_auto_end_conditions(600, 0)  # 10 min max, no tap limit

# Override from GameSceneBase
func _on_game_end() -> void:
	is_active = false
	SessionManager.end_session()

# Override from GameSceneBase
func _get_game_metrics() -> Dictionary:
	return {
		"pairs_matched": matched_pairs,
		"total_pairs": total_pairs,
		"child_age": child_age
	}

## Private Functions ##

# Load child age from settings file
func _load_child_age() -> void:
	var settings_path = "user://child_profile.json"
	if FileAccess.file_exists(settings_path):
		var file = FileAccess.open(settings_path, FileAccess.READ)
		if file:
			var json_str = file.get_as_text()
			file.close()
			var json = JSON.new()
			if json.parse(json_str) == OK:
				var data = json.data
				if data.has("age"):
					child_age = data["age"]

	# Set grid size based on age
	if child_age >= 4:
		grid_rows = 2
		grid_cols = 3  # 6 cards for ages 4+
	else:
		grid_rows = 2
		grid_cols = 2  # 4 cards for ages 2-3

	total_pairs = (grid_rows * grid_cols) / 2

# Set up the game board
func _setup_game() -> void:
	# Configure grid container
	card_container.columns = grid_cols

	# Calculate container size based on card count
	var card_width = 60
	var card_spacing = 10
	var container_width = (grid_cols * card_width) + ((grid_cols - 1) * card_spacing)
	var container_height = (grid_rows * card_width) + ((grid_rows - 1) * card_spacing)

	# Center the container
	card_container.offset_left = -container_width / 2
	card_container.offset_right = container_width / 2
	card_container.offset_top = -container_height / 2
	card_container.offset_bottom = container_height / 2

	# Create card content pairs
	var content_pairs: Array[int] = []
	for i in range(total_pairs):
		content_pairs.append(i)
		content_pairs.append(i)

	# Shuffle pairs
	content_pairs.shuffle()

	# Create card instances
	for i in content_pairs.size():
		var card: Card = CARD_SCENE.instantiate()
		card.set_content(content_pairs[i])
		card.card_clicked.connect(_on_card_clicked)
		cards.append(card)
		card_container.add_child(card)

# Connect timer signals
func _connect_signals() -> void:
	check_timer.timeout.connect(_on_match_check)
	reset_timer.timeout.connect(_on_reset_cards)
	win_timer.timeout.connect(_on_win_transition)

# Handle card click
func _on_card_clicked(card: Card) -> void:
	if game_state != GameState.IDLE:
		return

	if card.flipped or card.matched:
		return

	# Flip the card
	game_state = GameState.FLIPPING
	card.flip()
	flipped_cards.append(card)

	# Check if we have 2 cards flipped
	if flipped_cards.size() == 2:
		game_state = GameState.WAITING
		check_timer.start()

# Check for match after delay
func _on_match_check() -> void:
	if flipped_cards.size() != 2:
		game_state = GameState.IDLE
		return

	var card1: Card = flipped_cards[0]
	var card2: Card = flipped_cards[1]

	if card1.content_id == card2.content_id:
		# Match found!
		_on_match_found(card1, card2)
	else:
		# No match - flip back
		_on_no_match(card1, card2)

# Handle matched cards
func _on_match_found(card1: Card, card2: Card) -> void:
	matched_pairs += 1

	# Play match success sound
	AudioManager.play_sfx("match_success.ogg")

	# Play word callout based on color
	var word_key = ""
	match card1.content_id:
		0: word_key = "color_red"
		1: word_key = "color_blue"
		2: word_key = "color_yellow"
		3: word_key = "color_green"
		4: word_key = "color_pink"
		5: word_key = "color_orange"

	if word_key != "":
		var word = TranslationManager.get_text(word_key)
		AudioManager.play_voice("words/id/warna_" + word + ".ogg")

	# Show glow effect
	card1.show_glow()
	card2.show_glow()

	# Clear flipped cards
	flipped_cards.clear()

	# Check for win
	if matched_pairs >= total_pairs:
		_on_game_won()
	else:
		game_state = GameState.IDLE

# Handle non-matched cards
func _on_no_match(card1: Card, card2: Card) -> void:
	game_state = GameState.RESET

	# Play gentle SFX for no match
	AudioManager.play_sfx("match_fail.ogg")

	# Flip back after delay
	reset_timer.start()

# Reset flipped cards
func _on_reset_cards() -> void:
	for card in flipped_cards:
		card.flip_back()

	flipped_cards.clear()
	game_state = GameState.IDLE

# Handle game won
func _on_game_won() -> void:
	game_state = GameState.WON

	# Play celebration sound
	AudioManager.play_sfx("celebration.ogg")

	# Show win message
	win_label.modulate = Color(1, 1, 1, 1)
	win_label.text = TranslationManager.get_text("message_wah_hebat")

	# Auto-transition after delay
	win_timer.start()

# Transition to menu after win
func _on_win_transition() -> void:
	GameManager.fade_to_scene("res://scenes/MainMenu.tscn")
