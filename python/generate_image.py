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

size = (8, 8)

grid = [[None for _1 in range(size[0])] for _2 in range(size[1])]


def get_walled(options, side):
    """Get valid options from list when a wall is required on a side"""
    valid_options = []
    for option in options:
        if option[side] == "w":
            valid_options.append(option)
    return valid_options


def valid_position(cell, side):
    """Check if a cell's side is a valid position"""
    if side == "up":
        return cell[1] > 0
    if side == "down":
        return cell[1] < size[1] - 1
    if side == "left":
        return cell[0] > 0
    if side == "right":
        return cell[0] < size[0] - 1
    return ""


def check_required(outcome, cell, stop=None) -> tuple[bool, list[str]]:
    """Check if the required squares can be placed"""
    if stop is None:
        stop = []

    if "required" in outcome:
        stop.append(outcome["id"])
        for square_id, side in outcome["required"].items():
            if valid_position(cell, side):
                selected_square = next((sq for sq in square if sq["id"] == square_id))
                if square_id in stop:  # If we have already check it, ignore
                    continue
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


def get_possibilities(x, y, x_change, y_change, side):
    """Get possibilities for a cell"""
    if valid_position((x, y), side):
        if grid[y + y_change][x + x_change]:
            target_cell = grid[y + y_change][x + x_change]
            final_outcome = []
            for cell in square:
                if "required" in target_cell and side in target_cell["required"]:
                    if (
                        cell["id"] == target_cell["required"][side]
                        and cell[OPPOSING_SIDES[side]] == target_cell["id"]
                        and valid_position((x + x_change, y + y_change), side)
                        and (
                            grid[y + y_change * 2][x + x_change * 2] is None
                            or grid[y + y_change * 2][x + x_change * 2]["id"]
                            == target_cell["required"][side]
                        )
                    ):
                        final_outcome.append(cell)
                elif (
                    cell[side] == grid[y + y_change][x + x_change][OPPOSING_SIDES[side]]
                ):
                    final_outcome.append(cell)
                return final_outcome
        else:
            return square
    else:
        return get_walled(square, side)


def get_entropy(x, y):
    """Get the possibilities a tile can be"""
    final_outcome = [[], [], [], [], []]
    final_outcome[0] = get_possibilities(x, y, -1, 0, "left")
    final_outcome[1] = get_possibilities(x, y, 1, 0, "right")
    final_outcome[2] = get_possibilities(x, y, 0, -1, "up")
    final_outcome[3] = get_possibilities(x, y, 0, 1, "down")
    for outcome in final_outcome[3]:
        if (
            outcome in final_outcome[2]
            and outcome in final_outcome[1]
            and outcome in final_outcome[0]
            and check_required(outcome, (x, y))[0]
        ):
            final_outcome[4].append(outcome)
    return final_outcome[4]


def place_required(chosen_square, chosen_lock, stop=None):
    """Place required squares around a square"""
    if stop is None:
        stop = []
    stop.append(chosen_lock)

    if "required" in chosen_square:
        # if len(stop) > 4:
        #    return stop
        for square_id, side in chosen_square["required"].items():
            new_lock = (
                chosen_lock[0] + SIDE_VECTORS[side][0],
                chosen_lock[1] + SIDE_VECTORS[side][1],
            )
            if new_lock in stop:  # If we have already placed something here, ignore
                continue
            selected_square = next((sq for sq in square if sq["id"] == square_id))
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
            if BOX in options and option_count > 1:
                options.remove(BOX)
                option_count -= 0.9
            if option_count == min_entropy:
                min_options.append((x, y))
            elif min_entropy > option_count > 0:
                min_entropy = option_count
                min_options = [(x, y)]
    if not min_options:
        return
    chosen_lock = choice(min_options)
    ent = get_entropy(chosen_lock[0], chosen_lock[1])
    if BOX in ent and len(ent) > 1:
        ent.remove(BOX)
    chosen_square = choice(ent)
    place_required(chosen_square, chosen_lock)
    grid[chosen_lock[1]][chosen_lock[0]] = chosen_square


seed(int(input()))

for i in range(12):
    lock_square()

im = Image.new("RGB", (size[0] * 100, size[1] * 100))
imD = ImageDraw.Draw(im)

for y in range(size[1]):
    for x in range(size[0]):
        imD.rectangle(
            (x * 100, y * 100, (x + 1) * 100, (y + 1) * 100),
            tuple(grid[y][x]["colour"]) if grid[y][x] else (0, 0, 0),
        )
im.save("out.png")
