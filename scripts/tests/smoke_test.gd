extends SceneTree

# Headless smoke test: ensure key scenes instantiate without errors.
# Run:
#   godot --headless --path . -s res://scripts/tests/smoke_test.gd

const SCENES := [
	"res://scenes/DragMatchGame.tscn",
	"res://scenes/MemoryFlipGame.tscn",
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
