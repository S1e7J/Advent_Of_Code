import numpy as np
from typing import Tuple, Callable
import matplotlib.pyplot as plt

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
        board[rmin:rmax+1, cmin:cmax+1] -= 1
        np.clip(board, 0, None, board)
    change_for_square(cord1, cord2, turn_off_aux)

def turn_on(cord1 : point, cord2 : point) -> None:
    def turn_on_aux(rmin, rmax, cmin, cmax) -> None:
        board[rmin:rmax + 1, cmin:cmax + 1] += 1
    change_for_square(cord1, cord2, turn_on_aux)

def toggle(cord1 : point, cord2 : point) -> None:
    def toogle_aux(r_min, r_max, c_min, c_max) -> None:
        board[r_min:r_max+1, c_min:c_max+1] += 2
    change_for_square(cord1, cord2, toogle_aux)

def read_line(line) -> str:
    values = line.strip().replace("turn on", "turn_on").replace("turn off", "turn_off").split(" ")
    return(f"{values[0]}(({values[1]}), ({values[3]}))")

def main():
    with open("input") as file:
        for line in file:
            command = read_line(line)
            eval(command)

def show():
    plt.figure(figsize=(10, 10))
    plt.imshow(board, cmap='hot', interpolation='nearest')
    plt.colorbar(label='Valor')
    plt.title('Visualización del tablero Advent Of Code 2015 - dia 6')
    plt.show()


if __name__ == "__main__":
    main()
    show()
