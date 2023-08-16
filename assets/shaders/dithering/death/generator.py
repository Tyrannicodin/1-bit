"""Generate random palettes with one dark colour and one random colour"""
from random import randint, seed
from PIL import Image

PALETTES = 64
DARK_COLOUR = (62, 19, 56)

seed(1)

def random_colour():
    """Generate a random colour"""
    return tuple(randint(0, 255) for i in range(3))

for i in range(PALETTES):
    palette_image = Image.new("RGB", (2, 1), DARK_COLOUR)
    palette_image.putpixel((1, 0), random_colour())
    palette_image.save(f"palette_{i}.png")
