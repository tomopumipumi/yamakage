import math


def calculate_grid(num_icons: int) -> tuple[int, int]:
    cols = math.ceil(math.sqrt(num_icons))
    rows = math.ceil(num_icons / cols)
    return cols, rows
