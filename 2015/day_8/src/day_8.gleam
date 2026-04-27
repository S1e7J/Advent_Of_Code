import gleam/int
import gleam/string
import gleam/io
import gleam/list
import gleam/regexp
import simplifile

fn count_characters(from str: String) -> Int {
  str
  |> string.length
}

fn count_real_characters(from input: String) -> Int {
  input
  |> replace_hex_to_ascii("x")
  |> string.replace(each: "\\\"", with: "\"")
  |> string.replace(each:"\\\\", with: "\\")
  |> count_characters
  |> int.subtract(2)
}

fn replace_hex_to_ascii(from input: String, with def: String) -> String {
  let assert Ok(re) = regexp.from_string("\\\\x([0-9A-Fa-f]{2})")
  regexp.replace(each: re, in: input, with: def)
}

fn solve_part_1(with input: String) -> Int {
  let code_lenght = input |> string.trim |> string.split("\n") |> list.map(count_characters) |> list.fold(0, int.add)
  let real_lenght = input |> string.trim |> string.split("\n") |> list.map(count_real_characters) |> list.fold(0, int.add)
  code_lenght - real_lenght
}


fn count_encoded_characters(from input: String) -> Int {
  input
  |> string.replace(each: "\"", with: "xx")
  |> string.replace(each:"\\\"", with: "xxxx")
  |> string.replace(each:"\\", with: "xx")
  |> count_characters
  |> int.add(2)
}

fn solve_part_2(with input: String) -> Int {
  let code_lenght = input |> string.trim |> string.split("\n") |> list.map(count_characters) |> list.fold(0, int.add)
  let encoded_lenght = input |> string.trim |> string.split("\n") |> list.map(count_encoded_characters) |> list.fold(0, int.add)
  encoded_lenght - code_lenght
}

pub fn main() -> Nil {
  io.println("Hello from day_8!")
  let assert Ok(input) = simplifile.read("input/input")
  echo solve_part_1(input)
  echo solve_part_2(input)
  Nil
}
