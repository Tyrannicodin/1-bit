"""Generate an image with wave collapse"""
from json import load
from random import seed, choice

from PIL import Image, ImageDraw

OPPOSING_SIDES = {"up": "down", "down": "up", "left": "right", "right": "left"}
SIDE_VECTORS = {"up": (0, -1), "down": (0, 1), "left": (-1, 0), "right": (1, 0)}
BOX = {
    "id": "box",
    "colour": [0, 0, 0],
    "up": "w",
    "down": "w",
    "left": "w",
    "right": "w",
}


with open("assets\\grid_data\\tiles.json", "r", encoding="utf-8") as f:
    square = load(f)

size = (32, 32)

grid = [[None for _1 in range(size[0])] for _2 in range(size[1])]


def get_walled(options, side):
    """Get valid options from list when a wall is required on a side"""
    valid_options = []
    for option in options:
        if option[side] == "w":
            valid_options.append(option)
    return valid_options


def valid_position(loc):
    """Check if a cell's side is a valid position"""
    return 0 <= loc[0] < size[0] and 0 <= loc[1] < size[1]


def check_valid(selected_square, cell):
    """Check if a cell can connect to its side"""
    for side in OPPOSING_SIDES:
        new_lock = (cell[0] + SIDE_VECTORS[side][0], cell[1] + SIDE_VECTORS[side][1])
        if not valid_position(new_lock):
            if selected_square[side] == "w":
                continue
            return False
        if not (
            grid[new_lock[1]][new_lock[0]] is None
            or selected_square[side] == grid[new_lock[1]][new_lock[0]]
        ):
            return False
    return True


def check_required(outcome, cell, stop=None) -> tuple[bool, list[str]]:
    """Check if the required squares can be placed"""
    if stop is None:
        stop = []

    if "required" in outcome:
        stop.append(outcome["id"])
        for square_id, side in outcome["required"].items():
            if square_id in stop:  # If we have already check it, ignore
                continue
            selected_square = square[square_id]
            if check_valid(selected_square, cell):
                require_check = check_required(
                    selected_square,
                    (cell[0] + SIDE_VECTORS[side][0], cell[1] + SIDE_VECTORS[side][1]),
                    stop,
                )  # Check new square
                stop = require_check[1]  # Update searched items
                if require_check[0]:  # If we pass, skip the result false
                    continue
            return False, []
    return True, stop


def get_possibilities(x, y, side, within):
    """Get possibilities for a cell"""
    new_lock = (
        x + SIDE_VECTORS[side][0],
        y + SIDE_VECTORS[side][1],
    )
    if valid_position(new_lock):
        if grid[new_lock[1]][new_lock[0]]:
            final_outcome = []
            for cell in within:
                if (
                    cell[side]
                    == grid[y + SIDE_VECTORS[side][1]][x + SIDE_VECTORS[side][0]][
                        OPPOSING_SIDES[side]
                    ]
                ):
                    final_outcome.append(cell)
            return final_outcome
        else:
            return within
    else:
        return get_walled(within, side)


def get_entropy(x, y):
    """Get the possibilities a tile can be"""
    final_outcome = []
    for i, side in enumerate(OPPOSING_SIDES):
        final_outcome = get_possibilities(
            x, y, side, final_outcome if i > 0 else square.values()
        )
    output = []
    for outcome in final_outcome:
        if check_required(outcome, (x, y))[0]:
            output.append(outcome)
    return output


def place_required(chosen_square, chosen_lock, stop=None):
    """Place required squares around a square"""
    if stop is None:
        stop = []
    stop.append(chosen_lock)

    if "required" in chosen_square:
        for square_id, side in chosen_square["required"].items():
            new_lock = (
                chosen_lock[0] + SIDE_VECTORS[side][0],
                chosen_lock[1] + SIDE_VECTORS[side][1],
            )
            if new_lock in stop:  # If we have already placed something here, ignore
                continue
            selected_square = square[square_id]
            grid[new_lock[1]][new_lock[0]] = selected_square
            stop = place_required(
                selected_square,
                new_lock,
                stop,
            )
    return stop


def lock_square():
    """Lock in one square"""
    min_entropy = 100000
    min_options = []
    for y in range(size[1]):
        for x in range(size[0]):
            if grid[y][x]:
                continue
            options = get_entropy(x, y)
            option_count = len(options)
            if option_count == min_entropy:
                min_options.append((x, y))
            elif min_entropy > option_count > 0:
                min_entropy = option_count
                min_options = [(x, y)]
    if not min_options:
        return True
    chosen_lock = choice(min_options)
    ent = get_entropy(chosen_lock[0], chosen_lock[1])
    if BOX in ent and len(ent) > 1:
        ent.remove(BOX)
    chosen_square = choice(ent)
    place_required(chosen_square, chosen_lock)
    grid[chosen_lock[1]][chosen_lock[0]] = chosen_square
    return False


from time import time

seed(int(input()))

LOCKS = 8
TIMES = []
start_time = time()
i = 0

while True:
    print(f"{i}", end="\r")
    try:
        done = lock_square()
    except KeyboardInterrupt:
        break
    TIMES.append(time() - start_time)
    start_time = time()
    i += 1
    if done:
        break

print(f"Locked {i+1} squares")
print(
    f"Finished with average lock time: {round(sum(TIMES)/len(TIMES))}s and total time of {round(sum(TIMES))}s"
)

im = Image.new("RGB", (size[0] * 100, size[1] * 100))
imD = ImageDraw.Draw(im)

for y in range(size[1]):
    for x in range(size[0]):
        imD.rectangle(
            (x * 100, y * 100, (x + 1) * 100, (y + 1) * 100),
            tuple(grid[y][x]["colour"]) if grid[y][x] else (0, 0, 0),
        )
im.save("out.png")
