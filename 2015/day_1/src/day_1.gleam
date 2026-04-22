import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn step(c: String) -> Int {
  case c {
    "("  -> 1
    ")" -> -1
    _ -> 0
  }
}

pub fn fold_fun(lst: List(String), acc: Int, step_count: Int) -> Int {
  case acc {
    -1 -> step_count
      _ -> case lst {
        [] -> acc
        [v, ..rest] -> fold_fun(rest, acc + step(v), step_count + 1)
      }
  }
}

pub fn solve_part_1(input: String) -> Int {
    input
    |> string.to_graphemes
    |> list.fold(from: 0, with: fn (acc, char) {acc + step(char)})
}

pub fn solve_part_2(input: String) -> Int {
    input
    |> string.to_graphemes
    |> fold_fun(0, 0)
}

pub fn main() -> Nil {
  io.println("Hello from day_1!")
    let assert Ok(input) = simplifile.read(from: "input/input") as "Something went Wrong while reading the file"
    echo solve_part_1(input)
    echo solve_part_2(input)
    Nil
}
