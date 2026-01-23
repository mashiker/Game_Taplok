extends SceneTree

# Script to generate simple coloring template images
# Run with: godot --script tools/create_templates.gd --headless

func _init() -> void:
	# Create templates directory
	DirAccess.make_dir_absolute("res://assets/textures/coloring_templates")

	# Create templates
	_create_batik_template()
	_create_komodo_template()
	_create_anggrek_template()
	_create_joglo_template()
	_create_melati_template()

	print("Templates created successfully!")
	quit()

func _create_batik_template() -> void:
	var img = Image.create(1200, 900, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)

	# Draw batik pattern (simple geometric shapes)
	# Main border
	_draw_rectangle(img, 50, 50, 1100, 800, Color.BLACK, 5)
	_draw_rectangle(img, 100, 100, 1000, 700, Color.BLACK, 3)

	# Draw diamond pattern center
	_draw_diamond(img, 600, 450, 200, Color.BLACK, 3)

	# Draw corner patterns
	_draw_flower_simple(img, 150, 150, 60, Color.BLACK, 3)
	_draw_flower_simple(img, 1050, 150, 60, Color.BLACK, 3)
	_draw_flower_simple(img, 150, 750, 60, Color.BLACK, 3)
	_draw_flower_simple(img, 1050, 750, 60, Color.BLACK, 3)

	# Draw side patterns
	for i in range(3):
		var y = 250 + i * 200
		_draw_circle_outline(img, 150, y, 30, Color.BLACK, 2)
		_draw_circle_outline(img, 1050, y, 30, Color.BLACK, 2)

	img.save_png("res://assets/textures/coloring_templates/batik.png")

func _create_komodo_template() -> void:
	var img = Image.create(1200, 900, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)

	# Draw komodo dragon outline (simplified)
	# Body
	_draw_ellipse_outline(img, 600, 500, 300, 150, Color.BLACK, 4)

	# Head
	_draw_ellipse_outline(img, 850, 450, 100, 80, Color.BLACK, 4)

	# Snout
	_draw_rectangle(img, 930, 440, 150, 40, Color.BLACK, 4)

	# Legs (4)
	_draw_ellipse_outline(img, 450, 600, 60, 100, Color.BLACK, 4)
	_draw_ellipse_outline(img, 550, 600, 60, 100, Color.BLACK, 4)
	_draw_ellipse_outline(img, 700, 600, 60, 100, Color.BLACK, 4)
	_draw_ellipse_outline(img, 800, 600, 60, 100, Color.BLACK, 4)

	# Tail
	_draw_rectangle(img, 300, 480, 250, 40, Color.BLACK, 4)

	# Eye
	_draw_circle_outline(img, 880, 430, 15, Color.BLACK, 3)

	# Spots on body
	for i in range(5):
		var x = 400 + i * 80
		_draw_circle_outline(img, x, 500, 20, Color.BLACK, 2)

	img.save_png("res://assets/textures/coloring_templates/komodo.png")

func _create_anggrek_template() -> void:
	var img = Image.create(1200, 900, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)

	# Stem
	_draw_rectangle(img, 590, 700, 20, 200, Color.BLACK, 3)

	# Leaves
	_draw_ellipse_outline(img, 500, 750, 120, 50, Color.BLACK, 3)
	_draw_ellipse_outline(img, 700, 750, 120, 50, Color.BLACK, 3)

	# Flower petals (5 petals for orchid)
	_draw_ellipse_outline(img, 600, 400, 80, 150, Color.BLACK, 3) # Center petal
	_draw_ellipse_outline(img, 500, 450, 80, 120, Color.BLACK, 3) # Left petal
	_draw_ellipse_outline(img, 700, 450, 80, 120, Color.BLACK, 3) # Right petal
	_draw_ellipse_outline(img, 550, 300, 60, 100, Color.BLACK, 3) # Top left
	_draw_ellipse_outline(img, 650, 300, 60, 100, Color.BLACK, 3) # Top right

	# Center of flower
	_draw_circle_outline(img, 600, 450, 40, Color.BLACK, 3)

	# Small details
	_draw_circle_outline(img, 600, 450, 15, Color.BLACK, 2)

	img.save_png("res://assets/textures/coloring_templates/anggrek.png")

func _create_joglo_template() -> void:
	var img = Image.create(1200, 900, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)

	# Joglo house roof (traditional Javanese architecture)
	# Main roof pyramid
	_draw_triangle_outline(img, 600, 200, 350, Color.BLACK, 4)

	# Lower tier
	_draw_triangle_outline(img, 600, 300, 400, Color.BLACK, 4)

	# Base
	_draw_rectangle(img, 200, 450, 800, 350, Color.BLACK, 4)

	# Door
	_draw_rectangle(img, 550, 550, 100, 250, Color.BLACK, 3)

	# Windows
	_draw_rectangle(img, 300, 500, 80, 80, Color.BLACK, 3)
	_draw_rectangle(img, 820, 500, 80, 80, Color.BLACK, 3)

	# Decorative elements
	_draw_rectangle(img, 250, 450, 700, 20, Color.BLACK, 3)
	_draw_rectangle(img, 300, 500, 600, 20, Color.BLACK, 2)

	# Pillars
	_draw_rectangle(img, 300, 500, 30, 300, Color.BLACK, 3)
	_draw_rectangle(img, 870, 500, 30, 300, Color.BLACK, 3)

	img.save_png("res://assets/textures/coloring_templates/joglo.png")

func _create_melati_template() -> void:
	var img = Image.create(1200, 900, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)

	# Stem
	_draw_rectangle(img, 590, 600, 20, 300, Color.BLACK, 3)

	# Leaves
	_draw_ellipse_outline(img, 480, 650, 100, 40, Color.BLACK, 3)
	_draw_ellipse_outline(img, 720, 700, 100, 40, Color.BLACK, 3)
	_draw_ellipse_outline(img, 520, 750, 90, 35, Color.BLACK, 3)

	# Jasmine flowers (multiple small flowers)
	# Main flower cluster
	_draw_flower_jasmine(img, 600, 400)
	_draw_flower_jasmine(img, 520, 480)
	_draw_flower_jasmine(img, 680, 450)

	img.save_png("res://assets/textures/coloring_templates/melati.png")

func _draw_flower_jasmine(img: Image, cx: int, cy: int) -> void:
	# Small jasmine flower with 5-6 petals
	for i in range(6):
		var angle = (PI * 2 * i) / 6
		var px = cx + int(cos(angle) * 25)
		var py = cy + int(sin(angle) * 25)
		_draw_circle_outline(img, px, py, 20, Color.BLACK, 2)

	# Center
	_draw_circle_outline(img, cx, cy, 15, Color.BLACK, 2)

func _draw_rectangle(img: Image, x: int, y: int, w: int, h: int, color: Color, thickness: int) -> void:
	for i in range(thickness):
		# Top
		for px in range(x, x + w):
			img.set_pixel(px, y + i, color)
		# Bottom
		for px in range(x, x + w):
			img.set_pixel(px, y + h - i, color)
		# Left
		for py in range(y, y + h):
			img.set_pixel(x + i, py, color)
		# Right
		for py in range(y, y + h):
			img.set_pixel(x + w - i, py, color)

func _draw_circle_outline(img: Image, cx: int, cy: int, radius: int, color: Color, thickness: int) -> void:
	for angle in range(0, 360, 2):
		var rad = deg_to_rad(float(angle))
		for t in range(thickness):
			var r = radius - t
			var x = cx + int(cos(rad) * r)
			var y = cy + int(sin(rad) * r)
			if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
				img.set_pixel(x, y, color)

func _draw_ellipse_outline(img: Image, cx: int, cy: int, rx: int, ry: int, color: Color, thickness: int) -> void:
	for angle in range(0, 360, 2):
		var rad = deg_to_rad(float(angle))
		for t in range(thickness):
			var factor = 1.0 - (float(t) / float(thickness))
			var x = cx + int(cos(rad) * rx * factor)
			var y = cy + int(sin(rad) * ry * factor)
			if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
				img.set_pixel(x, y, color)

func _draw_triangle_outline(img: Image, cx: int, cy: int, size: int, color: Color, thickness: int) -> void:
	# Triangle points
	var p1 = Vector2(cx, cy - size)
	var p2 = Vector2(cx - size, cy + size * 0.7)
	var p3 = Vector2(cx + size, cy + size * 0.7)

	_draw_line(img, p1, p2, color, thickness)
	_draw_line(img, p2, p3, color, thickness)
	_draw_line(img, p3, p1, color, thickness)

func _draw_line(img: Image, from: Vector2, to: Vector2, color: Color, thickness: int) -> void:
	var dist = from.distance_to(to)
	var steps = int(dist)
	for i in range(steps + 1):
		var t = float(i) / float(steps)
		var pos = from.lerp(to, t)
		for t_idx in range(thickness):
			var offset_x = int((float(t_idx) - float(thickness) / 2) * (to.y - from.y) / dist)
			var offset_y = int((float(t_idx) - float(thickness) / 2) * (from.x - to.x) / dist)
			var x = int(pos.x) + offset_x
			var y = int(pos.y) + offset_y
			if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
				img.set_pixel(x, y, color)

func _draw_diamond(img: Image, cx: int, cy: int, size: int, color: Color, thickness: int) -> void:
	var p1 = Vector2(cx, cy - size)
	var p2 = Vector2(cx + size, cy)
	var p3 = Vector2(cx, cy + size)
	var p4 = Vector2(cx - size, cy)

	_draw_line(img, p1, p2, color, thickness)
	_draw_line(img, p2, p3, color, thickness)
	_draw_line(img, p3, p4, color, thickness)
	_draw_line(img, p4, p1, color, thickness)

func _draw_flower_simple(img: Image, cx: int, cy: int, size: int, color: Color, thickness: int) -> void:
	# Simple 8-petal flower
	for i in range(8):
		var angle = (PI * 2 * i) / 8
		var px = cx + int(cos(angle) * size)
		var py = cy + int(sin(angle) * size)
		_draw_ellipse_outline(img, px, py, size / 2, size / 3, color, thickness)

	# Center
	_draw_circle_outline(img, cx, cy, size / 3, color, thickness)
