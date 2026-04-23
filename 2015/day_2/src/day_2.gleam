import gleam/int
import gleam/io
import simplifile
import gleam/string
import gleam/list

pub type Box {
  Box(length: Int, width: Int, height: Int)
}

pub fn parse_box(str: String) -> Result(Box, String) {
  case string.split(str, on: "x") {
    [l, w, h] -> {
      let assert Ok(length) = int.parse(l) as "length not an integer for line"
      let assert Ok(width) = int.parse(w) as "width not an integer for line"
      let assert Ok(height) = int.parse(h) as "height not an integer for line"
      Ok(Box(length:, width:, height:))
    }
    _ -> Error("The line" <> str <> "doesn't match what was expected")
  }
}

pub fn remove_single_max(numbers: List(Int)) -> #(Int, Int) {
  let assert [sm1, sm2, ..] = list.sort(numbers, int.compare)
  #(sm1, sm2)
}

pub fn step(box box: Box) -> Int {
  let Box(l, w, h) = box
  let lw = l * w
  let wh = w * h
  let hl = h * l
  let slack = int.min(lw, wh) |> int.min(hl)
  2 * lw + 2 * wh + 2 * hl + slack
}

pub fn solve_part_1(input input: String) -> Int {
  input
  |> string.split("\n")
  |> list.filter_map(parse_box)
  |> list.fold(0, fn (acc, box) { acc + step(box) })
}

pub fn step2(box box: Box) -> Int {
    let Box(l, w, h) = box
    let #(sm1, sm2) = remove_single_max([l, w, h])
    2 * sm1 + 2 * sm2 + l * w * h
}


pub fn solve_part_2(input input: String) -> Int {
  input
  |> string.split("\n")
  |> list.filter_map(parse_box)
  |> list.fold(0, fn (acc, box) { acc + step2(box) })
}

pub fn main() -> Nil {
  io.println("Hello from day_2!")
  let assert Ok(input) = simplifile.read(from: "input/input") as "Something went wrong while reading the file"
  echo solve_part_1(input)
  echo solve_part_2(input)
  Nil
}
