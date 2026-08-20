import gleam/option.{type Option, None, Some}
import gleam/order.{type Order}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

fn power_set(of xs: List(a)) -> List(List(a)) {
  case xs {
    [] -> [[]]
    [x, ..rest] -> {
      let powi = power_set(rest)
      list.append(powi, list.map(powi, fn(subset) { [x, ..subset] }))
    }
  }
}

fn parse_input() -> List(Int) {
  let assert Ok(input) = simplifile.read("input/input")
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(int.parse)
  |> result.values
}

fn minimum(of ls: List(a), with order: fn(a, a) -> Order ) -> Option(a) {
  case ls |> list.sort(order) {
    [] -> None
    [fs, ..] -> Some(fs)
  }
}

pub fn main() -> Nil {
  let containers = parse_input()
  let posibilities = power_set(containers)
    |> list.filter(fn(ls) { list.fold(ls, 0, fn(a, b) { a + b }) == 150 })
  echo posibilities |> list.length
  let lenghts = posibilities |> list.map(list.length)
  let min = lenghts |> minimum(int.compare) |> option.unwrap(0)
  echo lenghts |> list.filter(fn (a) { a == min }) |> list.length
  Nil
}
