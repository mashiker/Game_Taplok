extends Control

# FindTapThemeSelect - popup selector for Find & Tap themes.

const THEMES := [
	{"id": "animals_id", "name_key": "theme_animals", "path": "res://assets/data/themes/animals_id.json", "preview": "res://assets/textures/games/find_tap/bg_findtap_animals_1920x1080.png"},
	{"id": "transport_id", "name_key": "theme_transport", "path": "res://assets/data/themes/transport_id.json", "preview": "res://assets/textures/games/find_tap/bg_findtap_transport_1920x1080.png"},
]

@onready var title_label: Label = $Panel/VBox/Title
@onready var buttons_grid: GridContainer = $Panel/VBox/Grid

func _ready() -> void:
	if title_label:
		title_label.text = TranslationManager.get_text("choose_theme")

	_build_buttons()

	$Panel/VBox/TopRow/BackButton.pressed.connect(func():
		GameManager.fade_to_scene("res://scenes/MainMenu.tscn")
	)

func _build_buttons() -> void:
	for c in buttons_grid.get_children():
		c.queue_free()

	for t in THEMES:
		var card = preload("res://scenes/ui/GameCardButton.tscn").instantiate()
		card.enable_pulse = false
		card.set_title(TranslationManager.get_text(t["name_key"]))
		# Use same icon as FindTap for now (we can make theme icons later)
		card.set_icon_path("res://assets/textures/ui/icons/icon_find_tap_512.png")
		card.base_color = Color(0.35, 0.7, 0.9, 1)

		card.pressed.connect(func():
			GameManager.findtap_theme_path = String(t["path"])
			GameManager.fade_to_scene("res://scenes/FindTapGame.tscn")
		)

		buttons_grid.add_child(card)
