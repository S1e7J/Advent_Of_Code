import gleam/set
import gleam/list
import gleam/string
import gleam/io
import simplifile

pub type Point {
  Point(x: Int, y: Int)
}

pub type Direction {
  Up
  Down
  Left
  Right
}

pub type Turn {
  Santa
  RoboSanta
}

pub fn apply_direction_to_point(from: Point, in_direction direction: Direction) -> Point {
  let Point(x, y) = from
  case direction {
    Up -> Point(x, y + 1)
    Down -> Point(x, y - 1)
    Left -> Point(x + 1, y)
    Right -> Point(x - 1, y)
  }
}

pub fn parse_direction(str: String) -> Result(Direction, String) {
  case str {
    "^" -> Ok(Up)
    ">" -> Ok(Left)
    "v" -> Ok(Down)
    "<" -> Ok(Right)
    _ -> Error("The value " <> str <> " does not correspond to any known direction")
  }
}

pub fn resolve(directions: List(Direction), positions: List(Point)) -> List(Point) {
  case directions {
    [] -> positions
    [hd, ..tl] -> {
      let assert [ps, ..] = positions as "There must be at least one initial position"
      resolve(tl, [apply_direction_to_point(ps, hd), ..positions])
    }
  }
}

pub fn solve_part_1(input: String) -> Int {
  input
  |> string.to_graphemes
  |> list.filter_map(parse_direction)
  |> resolve([Point(0, 0)])
  |> set.from_list
  |> set.size
}

pub fn apply_turn(position: #(Point, Point), direction: Direction, turn: Turn) -> #(Point, Point) {
      let #(santa_ps, robo_ps) = position
      case turn {
        Santa -> #(apply_direction_to_point(santa_ps, direction), robo_ps)
        RoboSanta -> #(santa_ps, apply_direction_to_point(robo_ps, direction))
      }
}

pub fn oposite_turn(turn: Turn) -> Turn {
  case turn {
    Santa -> RoboSanta
    RoboSanta -> Santa
  }
}


pub fn resolve2(directions: List(Direction), positions: List(#(Point, Point)), its_turn_of turn: Turn) -> List(#(Point, Point)) {
  case directions {
    [] -> positions
      [hd, ..tl] -> {
        let assert [ps, ..] = positions as "There must be at least one initial position"
          resolve2(tl, [apply_turn(ps, hd, turn), ..positions], oposite_turn(turn))
      }
  }
}

pub fn flatten(from: List(#(a, a)), acc: List(a)) -> List(a) {
  case from {
    [] -> acc
    [#(a, b), ..tl] -> flatten(tl, [a, b, ..acc])
  }
}

pub fn solve_part_2(input: String) -> Int {
  input
    |> string.to_graphemes
    |> list.filter_map(parse_direction)
    |> resolve2([#(Point(0, 0), Point(0, 0))], Santa)
    |> flatten([])
    |> set.from_list
    |> set.size
}

pub fn main() -> Nil {
  io.println("Hello from day_3!")
    let assert Ok(input) = simplifile.read(from: "input/input")
    echo solve_part_1(input)
    echo solve_part_2(input)
    Nil
}
