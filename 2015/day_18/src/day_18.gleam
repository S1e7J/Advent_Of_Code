import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub type State {
  On
  OnNext
  OffNext
  Off
}

pub type CountState {
  CountState(on: Int, off: Int)
}

pub type Board =
  Dict(#(Int, Int), State)

pub type Point =
  #(Int, Int)

const neighbors = [
  #(-1, -1),
  #(0, -1),
  #(1, -1),
  #(-1, 0),
  #(1, 0),
  #(-1, 1),
  #(0, 1),
  #(1, 1),
]

fn token_state(from st: String) -> State {
  case st {
    "." -> Off
    "#" -> On
    _ -> panic as "There is an error parsing"
  }
}

fn get_neighbors(in state: Board, with pos: Point) -> List(State) {
  let #(x, y) = pos
  neighbors
  |> list.map(fn(ab) {
    let #(a, b) = ab
    #(a + x, b + y)
  })
  |> list.map(fn(a) { dict.get(state, a) |> result.unwrap(Off) })
}

fn count_on_off_neighbors(in state: Board, on pos: Point) -> CountState {
  let on_neighbors =
    get_neighbors(state, pos)
    |> list.filter(fn(a) { a == On || a == OffNext })
    |> list.length
  CountState(on: on_neighbors, off: list.length(neighbors) - on_neighbors)
}

fn update_position(in state: Board, with pos: Point) -> Board {
  let st = dict.get(state, pos)
  case st, count_on_off_neighbors(state, pos) {
    Ok(On), CountState(n, _) if n == 2 || n == 3 -> state
    Ok(On), _ -> dict.insert(state, pos, OffNext)
    Ok(Off), CountState(3, _) -> dict.insert(state, pos, OnNext)
    _, _ -> state
  }
}

fn update_position_v2(in state: Board, with pos: Point) -> Board {
  case pos {
    #(0, 0) -> state
    #(0, 99) -> state
    #(99, 0) -> state
    #(99, 99) -> state
    _ -> update_position(state, pos)
  }
}

fn clean_position(in state: Board, with pos: Point) -> Board {
  case dict.get(state, pos) {
    Ok(OnNext) -> dict.insert(state, pos, On)
    Ok(OffNext) -> dict.insert(state, pos, Off)
    _ -> state
  }
}

fn travel_board(state: Board, fun: fn(Board, Point) -> Board) -> Board {
  int.range(from: 0, to: 100, with: state, run: fn(state_i, i) {
    int.range(from: 0, to: 100, with: state_i, run: fn(state_j, j) {
      fun(state_j, #(i, j))
    })
  })
}

fn make_step(in state: Board) -> Board {
  state
  |> travel_board(update_position)
  |> travel_board(clean_position)
}

fn make_step_v2(in state: Board) -> Board {
  state
  |> travel_board(update_position_v2)
  |> travel_board(clean_position)
}

fn from_list_list_rec(
  ls: List(List(State)),
  pos_x: Int,
  pos_y: Int,
  state: Board,
) -> Board {
  case ls {
    [] -> state
    [[], ..rest] -> from_list_list_rec(rest, 0, pos_y + 1, state)
    [[n, ..restl], ..rest] ->
      from_list_list_rec(
        [restl, ..rest],
        pos_x + 1,
        pos_y,
        dict.insert(state, #(pos_x, pos_y), n),
      )
  }
}

fn from_list_list(from ls: List(List(State))) -> Board {
  let state = dict.new()
  from_list_list_rec(ls, 0, 0, state)
}

fn parse() -> Board {
  let assert Ok(input) = simplifile.read("input/input")
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(a) { string.to_graphemes(a) |> list.map(token_state) })
  |> from_list_list
}

pub fn main() -> Nil {
  let state = parse()
  echo int.range(0, 100, state, fn(n_state, _) { make_step(n_state) })
    |> dict.filter(fn(_, n) { n == On })
    |> dict.size
  echo [#(0, 0), #(0, 99), #(99, 0), #(99, 99)]
    |> list.fold(state, fn(st, pos) { dict.insert(st, pos, On) })
    |> int.range(0, 100, _, fn(n_state, _) { make_step_v2(n_state) })
    |> dict.filter(fn(_, n) { n == On })
    |> dict.size
  Nil
}
