import gleam/int
import gleam/list
import gleam/set
import gleam/string
import simplifile

pub type Conversion {
  Conversion(input: String, output: String)
}

fn token_conversion(from st: String) -> Conversion {
  let assert [input, "=>", output] = st |> string.split(" ")
  Conversion(input, output)
}

fn parse() -> #(List(Conversion), String) {
  let assert Ok(input) = simplifile.read("input/input")
  let assert Ok(#(conversions, input)) = string.split_once(input, "\n\n")
  #(
    conversions |> string.split("\n") |> list.map(token_conversion),
    string.trim(input),
  )
}

fn generate_replacements(
  remaining: String,
  conv: Conversion,
  checked: String,
  acc: List(String),
) -> List(String) {
  let is_match = string.starts_with(remaining, conv.input)

  let new_acc = case is_match {
    True -> {
      let rest = string.drop_start(remaining, string.length(conv.input))
      let new_string = checked <> conv.output <> rest
      [new_string, ..acc]
    }
    False -> acc
  }

  case string.pop_grapheme(remaining) {
    Ok(#(first_char, rest)) -> {
      generate_replacements(rest, conv, checked <> first_char, new_acc)
    }
    Error(Nil) -> new_acc
  }
}

fn count_chars(in input: String, with count: String) -> Int {
  input
  |> string.split(count)
  |> list.length
  |> int.subtract(1)
}

fn second_part(in input: String) -> Int {
  let total_elements =
    input
    |> string.to_graphemes
    |> list.filter(fn(a) { a != string.lowercase(a) })
    |> list.length
  let total_rn_ar =
    { input |> count_chars("Rn") } + { input |> count_chars("Ar") }
  let total_y = input |> count_chars("Y")
  total_elements - total_rn_ar - { 2 * total_y } - 1
}

pub fn main() -> Nil {
  let #(conversions, input) = parse()
  echo conversions
    |> list.flat_map(generate_replacements(input, _, "", []))
    |> set.from_list
    |> set.size
  echo input |> second_part
  Nil
}
