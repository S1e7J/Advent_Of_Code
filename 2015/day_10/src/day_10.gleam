import gleam/list
import gleam/io

pub fn aux_look_and_say(values: List(Int), currently: #(Int, Int) ,aux: List(Int)) {
  let #(value, n_elements)  = currently
  case values {
    [] -> list.reverse([value, n_elements, ..aux])
    [n1, ..rest] if n1 == value -> aux_look_and_say(rest, #(value, n_elements + 1), aux)
    [n1, ..rest] -> aux_look_and_say(rest, #(n1, 1), [value, n_elements, ..aux])
  }
}

pub fn look_and_say(values: List(Int)) {
  let assert [n1, ..rest] = values as "It must have at least 1 element"
  aux_look_and_say(rest, #(n1, 1), [])
}

pub fn apply_look_and_say_n_times(values: List(Int), times: Int) {
  case times {
    0 -> values
    n -> values |> look_and_say |> apply_look_and_say_n_times(n - 1)
  }
}

pub fn main() -> Nil {
  io.println("Hello from day_10!")
  echo apply_look_and_say_n_times([1, 1, 1, 3, 1, 2, 2, 1, 1,3], 40) |> list.length()
  echo apply_look_and_say_n_times([1, 1, 1, 3, 1, 2, 2, 1, 1,3], 50) |> list.length()
  Nil
}
