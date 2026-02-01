extends CanvasLayer

signal finished

@onready var panel: Panel = $Panel
@onready var mascot_rect: TextureRect = $Panel/VBox/Mascot
@onready var title: Label = $Panel/VBox/Title
@onready var subtitle: Label = $Panel/VBox/Subtitle
@onready var continue_button: Button = $Panel/VBox/ContinueButton

var _auto_close := true
var _mascot_texture := "res://assets/mascot/bear_mascot.png"

func setup(new_level: int, is_max: bool) -> void:
	if mascot_rect and ResourceLoader.exists(_mascot_texture):
		# Load PNG as Texture2D
		mascot_rect.texture = load(_mascot_texture)
	else:
		# Fallback to app icon
		if ResourceLoader.exists("res://icon.svg"):
			mascot_rect.texture = load("res://icon.svg")
	
	var base_title := "Wah hebat kamu!"
	var sub := "Ayo kita coba lagi!"
	if is_max:
		sub = "Keren! Kamu sudah sampai level terakhir!"
	title.text = base_title + "  (Level %d)" % new_level
	subtitle.text = sub

func _ready() -> void:
	continue_button.pressed.connect(_close)
	
	# Simple pop-in animation
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.6, 0.6)
	var t := create_tween()
	t.tween_property(panel, "modulate:a", 1.0, 0.22)
	t.parallel().tween_property(panel, "scale", Vector2(1.0, 1.0), 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	if _auto_close:
		await get_tree().create_timer(2.2).timeout
		_close()

func play_celebrate() -> void:
	if mascot_rect and mascot_rect.texture:
		# Simple bounce animation
		var bounce := create_tween()
		bounce.set_parallel(true)
		bounce.tween_property(mascot_rect, "scale", Vector2(1.15, 1.15), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		bounce.tween_property(mascot_rect, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

func _close() -> void:
	finished.emit()
	queue_free()
