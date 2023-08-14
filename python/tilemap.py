"""Gets information from a tilemap and turn it into json"""

from json import load, loads, dump
from os import listdir

OPPOSING_SIDES = {"up": "down", "down": "up", "left": "right", "right": "left"}


def next_to(coord_1, coord_2) -> str:
    """Check if two coordinates are adjacent - there's probably a better way to do this"""
    if coord_1[1] == coord_2[1]:
        if coord_1[0] - 1 == coord_2[0]:
            return "left"
        if coord_1[0] + 1 == coord_2[0]:
            return "right"
    if coord_1[0] == coord_2[0]:
        if coord_1[1] - 1 == coord_2[1]:
            return "up"
        if coord_1[1] + 1 == coord_2[1]:
            return "down"
    return ""


with open("assets\\grid_data\\tilemap_data.json", "r", encoding="utf-8") as f:
    wall_data = load(f)


def process_scene(file_path):
    """Process a scene with a gridmap inside it"""
    name = file_path.split("\\")[-1].split(".")[0]

    with open(file_path, "r", encoding="utf-8") as scene:
        scene_text = scene.read()
        if not "layer_0/tile_data" in scene_text:
            return
        res = loads(
            "["
            + scene_text.split("layer_0/tile_data = PackedInt32Array(", 1)[-1].split(
                ")", 1
            )[0]
            + "]"
        )

    tiles = {}

    for i in range(0, len(res), 3):
        map_coords = (res[i] & ((2**16) - 1), res[i] >> 16)
        atlas_coords = (res[i + 1] >> 16, res[i + 2] & ((2**16) - 1))
        if (res[i + 1] & ((2**16) - 1)) != 1 or (res[i + 2] >> 16) != 0:
            continue
        tile_id = f"{name}_{len(tiles)}"
        requirements = {}
        for coord, tile in tiles.items():
            tile_coords = (int(coord.split("_")[0]), int(coord.split("_")[1]))
            direction = next_to(map_coords, tile_coords)
            if direction:
                requirements[tile["id"]] = direction
                if "required" in tile:
                    tile["required"][tile_id] = OPPOSING_SIDES[direction]
                else:
                    tile["required"] = {tile_id: OPPOSING_SIDES[direction]}
        sides = {"id": tile_id}
        sides.update(wall_data[f"{atlas_coords[0]}_{atlas_coords[1]}"])
        if len(requirements) > 0:
            sides["required"] = requirements
        tiles[f"{map_coords[0]}_{map_coords[1]}"] = sides

    with open(f"assets\\grid_data\\tiles\\{name}.json", "w", encoding="utf-8") as scene:
        dump(list(tiles.values()), scene, indent=4)


for file in listdir("scenes\\room_layouts"):
    process_scene("scenes\\room_layouts\\" + file)

compiled_tiles = []

for file in listdir("assets\\grid_data\\tiles"):
    with open(f"assets\\grid_data\\tiles\\{file}", "r", encoding="utf-8") as f:
        compiled_tiles.extend(load(f))

with open("assets\\grid_data\\tiles.json", "w", encoding="utf-8") as f:
    dump(compiled_tiles, f, indent=4)
