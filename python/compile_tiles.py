"""Convert the lists of tiles into one list of available tiles"""

from json import load, dump
from os import listdir

tiles = []

for file in listdir("assets\\grid_data\\tiles"):
    with open(f"assets\\grid_data\\tiles\\{file}", "r", encoding="utf-8") as f:
        tiles.extend(load(f))

with open("assets\\grid_data\\tiles.json", "w", encoding="utf-8") as f:
    dump(tiles, f, indent=4)
