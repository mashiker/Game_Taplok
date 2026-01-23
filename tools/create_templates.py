"""
Create simple coloring template images for the Coloring Book game.
Run with: python tools/create_templates.py
"""

from PIL import Image, ImageDraw
import os

def create_directory():
    """Create the templates directory if it doesn't exist."""
    os.makedirs("assets/textures/coloring_templates", exist_ok=True)

def draw_rectangle(img, draw, x, y, w, h, color, thickness=3):
    """Draw a rectangle outline."""
    for i in range(thickness):
        draw.rectangle([x+i, y+i, x+w-i, y+h-i], outline=color, width=1)

def draw_circle_outline(img, draw, cx, cy, radius, color, thickness=3):
    """Draw a circle outline."""
    for i in range(thickness):
        bbox = [cx-radius+i, cy-radius+i, cx+radius-i, cy+radius-i]
        draw.ellipse(bbox, outline=color, width=1)

def draw_ellipse_outline(img, draw, cx, cy, rx, ry, color, thickness=3):
    """Draw an ellipse outline."""
    for i in range(thickness):
        factor = 1 - (i / thickness)
        bbox = [cx-int(rx*factor), cy-int(ry*factor), cx+int(rx*factor), cy+int(ry*factor)]
        draw.ellipse(bbox, outline=color, width=1)

def draw_triangle_outline(img, draw, cx, cy, size, color, thickness=3):
    """Draw a triangle outline."""
    p1 = (cx, cy - size)
    p2 = (cx - size, int(cy + size * 0.7))
    p3 = (cx + size, int(cy + size * 0.7))

    for i in range(thickness):
        draw.polygon([p1, p2, p3], outline=color)

def draw_diamond(img, draw, cx, cy, size, color, thickness=3):
    """Draw a diamond shape."""
    p1 = (cx, cy - size)
    p2 = (cx + size, cy)
    p3 = (cx, cy + size)
    p4 = (cx - size, cy)

    for _ in range(thickness):
        draw.polygon([p1, p2, p3, p4], outline=color)

def draw_simple_flower(img, draw, cx, cy, size, color, thickness=3):
    """Draw a simple 8-petal flower."""
    for i in range(8):
        angle = (6.28 * i) / 8
        import math
        px = cx + int(math.cos(angle) * size)
        py = cy + int(math.sin(angle) * size)
        draw_ellipse_outline(img, draw, px, py, size // 2, size // 3, color, thickness)
    draw_circle_outline(img, draw, cx, cy, size // 3, color, thickness)

def create_batik_template():
    """Create batik pattern template."""
    img = Image.new("RGBA", (1200, 900), (255, 255, 255, 255))
    draw = ImageDraw.Draw(img)

    # Main border
    draw_rectangle(img, draw, 50, 50, 1100, 800, (0, 0, 0, 255), 5)
    draw_rectangle(img, draw, 100, 100, 1000, 700, (0, 0, 0, 255), 3)

    # Diamond pattern center
    draw_diamond(img, draw, 600, 450, 200, (0, 0, 0, 255), 3)

    # Corner patterns
    draw_simple_flower(img, draw, 150, 150, 60, (0, 0, 0, 255), 3)
    draw_simple_flower(img, draw, 1050, 150, 60, (0, 0, 0, 255), 3)
    draw_simple_flower(img, draw, 150, 750, 60, (0, 0, 0, 255), 3)
    draw_simple_flower(img, draw, 1050, 750, 60, (0, 0, 0, 255), 3)

    # Side patterns
    for i in range(3):
        y = 250 + i * 200
        draw_circle_outline(img, draw, 150, y, 30, (0, 0, 0, 255), 2)
        draw_circle_outline(img, draw, 1050, y, 30, (0, 0, 0, 255), 2)

    img.save("assets/textures/coloring_templates/batik.png")
    print("Created batik.png")

def create_komodo_template():
    """Create komodo dragon template."""
    img = Image.new("RGBA", (1200, 900), (255, 255, 255, 255))
    draw = ImageDraw.Draw(img)

    # Body
    draw_ellipse_outline(img, draw, 600, 500, 300, 150, (0, 0, 0, 255), 4)

    # Head
    draw_ellipse_outline(img, draw, 850, 450, 100, 80, (0, 0, 0, 255), 4)

    # Snout
    draw_rectangle(img, draw, 930, 440, 150, 40, (0, 0, 0, 255), 4)

    # Legs
    draw_ellipse_outline(img, draw, 450, 600, 60, 100, (0, 0, 0, 255), 4)
    draw_ellipse_outline(img, draw, 550, 600, 60, 100, (0, 0, 0, 255), 4)
    draw_ellipse_outline(img, draw, 700, 600, 60, 100, (0, 0, 0, 255), 4)
    draw_ellipse_outline(img, draw, 800, 600, 60, 100, (0, 0, 0, 255), 4)

    # Tail
    draw_rectangle(img, draw, 300, 480, 250, 40, (0, 0, 0, 255), 4)

    # Eye
    draw_circle_outline(img, draw, 880, 430, 15, (0, 0, 0, 255), 3)

    # Spots on body
    for i in range(5):
        x = 400 + i * 80
        draw_circle_outline(img, draw, x, 500, 20, (0, 0, 0, 255), 2)

    img.save("assets/textures/coloring_templates/komodo.png")
    print("Created komodo.png")

def create_anggrek_template():
    """Create orchid flower template."""
    img = Image.new("RGBA", (1200, 900), (255, 255, 255, 255))
    draw = ImageDraw.Draw(img)

    # Stem
    draw_rectangle(img, draw, 590, 700, 20, 200, (0, 0, 0, 255), 3)

    # Leaves
    draw_ellipse_outline(img, draw, 500, 750, 120, 50, (0, 0, 0, 255), 3)
    draw_ellipse_outline(img, draw, 700, 750, 120, 50, (0, 0, 0, 255), 3)

    # Flower petals
    draw_ellipse_outline(img, draw, 600, 400, 80, 150, (0, 0, 0, 255), 3)
    draw_ellipse_outline(img, draw, 500, 450, 80, 120, (0, 0, 0, 255), 3)
    draw_ellipse_outline(img, draw, 700, 450, 80, 120, (0, 0, 0, 255), 3)
    draw_ellipse_outline(img, draw, 550, 300, 60, 100, (0, 0, 0, 255), 3)
    draw_ellipse_outline(img, draw, 650, 300, 60, 100, (0, 0, 0, 255), 3)

    # Center
    draw_circle_outline(img, draw, 600, 450, 40, (0, 0, 0, 255), 3)
    draw_circle_outline(img, draw, 600, 450, 15, (0, 0, 0, 255), 2)

    img.save("assets/textures/coloring_templates/anggrek.png")
    print("Created anggrek.png")

def create_joglo_template():
    """Create Joglo house template."""
    img = Image.new("RGBA", (1200, 900), (255, 255, 255, 255))
    draw = ImageDraw.Draw(img)

    # Main roof pyramid
    draw_triangle_outline(img, draw, 600, 200, 350, (0, 0, 0, 255), 4)

    # Lower tier
    draw_triangle_outline(img, draw, 600, 300, 400, (0, 0, 0, 255), 4)

    # Base
    draw_rectangle(img, draw, 200, 450, 800, 350, (0, 0, 0, 255), 4)

    # Door
    draw_rectangle(img, draw, 550, 550, 100, 250, (0, 0, 0, 255), 3)

    # Windows
    draw_rectangle(img, draw, 300, 500, 80, 80, (0, 0, 0, 255), 3)
    draw_rectangle(img, draw, 820, 500, 80, 80, (0, 0, 0, 255), 3)

    # Decorative elements
    draw_rectangle(img, draw, 250, 450, 700, 20, (0, 0, 0, 255), 3)
    draw_rectangle(img, draw, 300, 500, 600, 20, (0, 0, 0, 255), 2)

    # Pillars
    draw_rectangle(img, draw, 300, 500, 30, 300, (0, 0, 0, 255), 3)
    draw_rectangle(img, draw, 870, 500, 30, 300, (0, 0, 0, 255), 3)

    img.save("assets/textures/coloring_templates/joglo.png")
    print("Created joglo.png")

def create_melati_template():
    """Create jasmine flower template."""
    img = Image.new("RGBA", (1200, 900), (255, 255, 255, 255))
    draw = ImageDraw.Draw(img)
    import math

    # Stem
    draw_rectangle(img, draw, 590, 600, 20, 300, (0, 0, 0, 255), 3)

    # Leaves
    draw_ellipse_outline(img, draw, 480, 650, 100, 40, (0, 0, 0, 255), 3)
    draw_ellipse_outline(img, draw, 720, 700, 100, 40, (0, 0, 0, 255), 3)
    draw_ellipse_outline(img, draw, 520, 750, 90, 35, (0, 0, 0, 255), 3)

    # Jasmine flowers (multiple small flowers)
    def draw_jasmine_flower(cx, cy):
        # Small jasmine flower with 6 petals
        for i in range(6):
            angle = (6.28 * i) / 6
            px = cx + int(math.cos(angle) * 25)
            py = cy + int(math.sin(angle) * 25)
            draw_circle_outline(img, draw, px, py, 20, (0, 0, 0, 255), 2)
        # Center
        draw_circle_outline(img, draw, cx, cy, 15, (0, 0, 0, 255), 2)

    draw_jasmine_flower(600, 400)
    draw_jasmine_flower(520, 480)
    draw_jasmine_flower(680, 450)

    img.save("assets/textures/coloring_templates/melati.png")
    print("Created melati.png")

def main():
    """Create all template images."""
    create_directory()

    print("Creating coloring templates...")
    create_batik_template()
    create_komodo_template()
    create_anggrek_template()
    create_joglo_template()
    create_melati_template()

    print("All templates created successfully!")

if __name__ == "__main__":
    main()
