extends SceneTree

# Headless smoke test: ensure key scenes instantiate without errors.
# Run:
#   godot --headless --path . -s res://scripts/tests/smoke_test.gd

const SCENES := [
	# "res://scenes/MainMenu.tscn", # skipped in smoke_test (autoload reference)
	"res://scenes/TapPopGame.tscn",
	"res://scenes/DragMatchGame.tscn",
	"res://scenes/MemoryFlipGame.tscn",
	"res://scenes/PianoGame.tscn",
	"res://scenes/FingerPaintGame.tscn",
	"res://scenes/ColoringGame.tscn",
	"res://scenes/ShapeMatchGame.tscn",
	"res://scenes/RhythmGame.tscn",
	"res://scenes/FindTapThemeSelect.tscn",
	"res://scenes/FindTapGame.tscn",
	"res://scenes/SoundMatchGame.tscn",
	"res://scenes/ParentDashboard.tscn",
]

func _init() -> void:
	for p in SCENES:
		var ps: PackedScene = load(p)
		if ps == null:
			push_error("FAILED load: %s" % p)
			quit(1)
			return
		var inst = ps.instantiate()
		if inst == null:
			push_error("FAILED instantiate: %s" % p)
			quit(2)
			return
		# Add to root briefly so _ready runs.
		root.add_child(inst)
		await process_frame
		inst.queue_free()
		await process_frame
	print("SMOKE_OK")
	quit(0)
