import gleam/string
import gleam/io
import gleam/list

const valid_letters = [
  "a",
  "b",
  "c",
  "d",
  "e",
  "f",
  "g",
  "h",
  "i",
  "j",
  "k",
  "l",
  "m",
  "n",
  "o",
  "p",
  "q",
  "r",
  "s",
  "t",
  "u",
  "v",
  "w",
  "x",
  "y",
  "z",
]

fn find_next(letter) -> Result(String, Nil) {
  valid_letters
  |> list.drop_while(fn(a) { a != letter })
  |> list.drop(1)
  |> list.first
}

fn increment(password: List(String)) -> List(String) {
  case list.last(password) {
    Error(Nil) -> ["a"]
    Ok(last) -> {
      let unchange = list.take(password, list.length(password) - 1)
      let new_last = find_next(last)
      case new_last {
        Ok(n) -> unchange |> list.append([n])
        Error(Nil) -> increment(unchange) |> list.append(["a"])
      }
    }
  }
}

fn check_tree_values(password: List(String)) -> Bool {
  let letters = valid_letters |> string.join("")
  case password {
    [] -> False
    [_] -> False
    [_, _] -> False
    [n1, n2, n3, ..rest] -> string.contains(letters, n1 <> n2 <> n3) || check_tree_values([n2, n3, ..rest])
  }
}

fn check_pairs(password: List(String), number_of_pairs: Int) -> Bool {
  case password {
    [] -> number_of_pairs >= 2
    [_] -> number_of_pairs >= 2
    [n1, n2, ..rest] if n1 == n2 -> check_pairs(rest, number_of_pairs + 1)
    [_, n2, ..rest] -> check_pairs([n2, ..rest], number_of_pairs)
  }
}

fn check_for_invalid_chars(password: List(String)) -> Bool {
  ! { list.contains(password, "i") || list.contains(password, "l") || list.contains(password, "o") }
}

fn check_if_valid(password: List(String)) -> Bool {
  check_for_invalid_chars(password) && check_tree_values(password) && check_pairs(password, 0)

}


fn find_next_valid(password: List(String)) -> List(String) {
  let next_password = password |> increment
  case check_if_valid(next_password) {
    True -> next_password
    False -> find_next_valid(next_password)
  }
}

pub fn main() -> Nil {
  io.println("Hello from day_11!")
  echo valid_letters
  echo find_next_valid("hepxcrrq" |> string.to_graphemes) |> string.join("")
  echo find_next_valid("hepxxyzz" |> string.to_graphemes) |> string.join("")
  Nil
}
