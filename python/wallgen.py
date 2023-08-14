"""Generates the walls sprites"""

from math import sqrt, ceil
from json import dump

from PIL import Image, ImageDraw

IMAGES = 3 * 3 * 3 * 3


def get_best_factors(number: int) -> tuple[int, int]:
    """Get the most square factors"""
    x = sqrt(number) // 1
    return ceil(x), ceil(x if number - x**2 == 0 else (number - x**2) / x + x)


factors = get_best_factors(IMAGES)

total_image = Image.new("RGBA", (factors[0] * 60, factors[1] * 60), (0, 0, 0, 0))
colours = [
    (255, 255, 255, 255),
    (0, 0, 0, 255),
    (128, 128, 128, 255),
]
names = ["", "w", "d"]

wall_data = {}
i = 0
for left in range(3):
    for up in range(3):
        for right in range(3):
            for down in range(3):
                im = Image.new("RGBA", (10, 10), (255, 255, 255, 255))
                imD = ImageDraw.Draw(im)
                imD.line((0, 0, 0, 9), colours[left])
                imD.line((0, 0, 9, 0), colours[up])
                imD.line((9, 0, 9, 9), colours[right])
                imD.line((9, 9, 0, 9), colours[down])
                im = im.resize((50, 50))
                total_image.paste(
                    im, ((i % factors[0]) * 60, (i // factors[1]) * 60), im
                )
                wall_data[f"{(i % factors[0])}_{(i // factors[1])}"] = {
                    "left": names[left],
                    "up": names[up],
                    "right": names[right],
                    "down": names[down],
                }
                i += 1

total_image.save("assets\\grid_data\\tilemap.png")
with open("assets\\grid_data\\tilemap_data.json", "w", encoding="utf-8") as f:
    dump(wall_data, f, indent=4)
