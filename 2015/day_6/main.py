import numpy as np
from typing import Tuple, Callable

board = np.zeros((1000, 1000), dtype=int)

point = Tuple[int, int]
callable_change = Callable[[int, int, int, int], None]



def change_for_square(coord1 : point, coord2 : point, apply_function : callable_change)  -> None:
    r1, c1 = coord1
    r2, c2 = coord2
    r_min, r_max = sorted([r1, r2])
    c_min, c_max = sorted([c1, c2])
    apply_function(r_min, r_max, c_min, c_max)

def turn_off(cord1 : point, cord2 : point) -> None:
    def turn_off_aux(rmin, rmax, cmin, cmax) -> None:
        board[rmin:rmax + 1, cmin:cmax + 1] = 0
    change_for_square(cord1, cord2, turn_off_aux)

def turn_on(cord1 : point, cord2 : point) -> None:
    def turn_on_aux(rmin, rmax, cmin, cmax) -> None:
        board[rmin:rmax + 1, cmin:cmax + 1] = 1
    change_for_square(cord1, cord2, turn_on_aux)

def toggle(cord1 : point, cord2 : point) -> None:
    def toogle_aux(r_min, r_max, c_min, c_max) -> None:
        submatriz = board[r_min:r_max+1, c_min:c_max+1]
        board[r_min:r_max+1, c_min:c_max+1] = 1 - submatriz
    change_for_square(cord1, cord2, toogle_aux)

def read_line(line) -> str:
    values = line.strip().replace("turn on", "turn_on").replace("turn off", "turn_off").split(" ")
    return(f"{values[0]}(({values[1]}), ({values[3]}))")

def main():
    with open("input") as file:
        for line in file:
            command = read_line(line)
            eval(command)



if __name__ == "__main__":
    print(50 * "=")
    print(board)
    print(np.count_nonzero(board))
    print(50 * "=")
    main()
    print(50 * "=")
    print(board)
    print(np.count_nonzero(board))
    print(50 * "=")
