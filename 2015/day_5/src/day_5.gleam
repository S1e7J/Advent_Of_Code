import gleam/list
import gleam/string
import gleam/io
import simplifile
import gleam/result

fn first_condition(for val: String) -> Bool {
  val
  |> string.to_graphemes
  |> list.filter(fn (s) {string.contains("aeiou", s)})
  |> list.length()
  >= 3
}

fn aux_second_condition(for val: List(String)) -> Bool {
  case val {
    [] -> False
    [_] ->  False
    [ch1, ch2, .._] if ch1 == ch2 -> True
    [_, ch2, ..rest] -> aux_second_condition([ch2, ..rest])
  }
}

fn second_condition(for val: String) -> Bool {
  aux_second_condition(val |> string.to_graphemes)
}

fn third_condition(for val: String) -> Bool {
  !{ ["ab", "cd", "pq", "xy"] |> list.map(fn (s) {string.contains(val, s)}) |> list.any(fn(a) { a }) }
}

fn check_line(for val: String) -> Bool {
  first_condition(val) && second_condition(val) && third_condition(val)
}

fn solve_part_1(for input: String) -> Int {
  input
  |> string.split(on:"\n")
  |> list.filter(keeping: check_line)
  |> list.length
}

fn has_repeating_pairs(letters: List(String)) -> Bool {
  case letters {
    [a, b, ..rest] -> {
      let pair = a <> b
      let exists_later = string.contains(string.join(rest, ""), pair)

      exists_later || has_repeating_pairs([b, ..rest])
    }
    _ -> False
  }
}


fn has_sandwitched_triple(letters: List(String)) -> Bool {
  letters
  |> list.window(3)
  |> list.any(fn(triple) {
    list.first(triple) == list.last(triple) && result.is_ok(list.first(triple))
  })
}

fn check_line2(for val: String) -> Bool {
  let input = val |> string.to_graphemes
  has_repeating_pairs(input) && has_sandwitched_triple(input)
}


fn solve_part_2(for input: String) -> Int {
  input
  |> string.split(on:"\n")
  |> list.filter(keeping: check_line2)
  |> list.length
}


pub fn main() -> Nil {
  io.println("Hello from day_5!")
  let assert Ok(input) = simplifile.read(from:"input/input") as "Something went wrong reading the file"
  echo solve_part_1(input)
  echo solve_part_2(input)
  Nil
}
