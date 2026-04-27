import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub type Reindeer {
  Reindeer(
    name: String,
    max_velocity: Int,
    stamina: Int,
    rest: Int,
    distance: Int,
    points: Int,
    time_running: Int,
    time_resting: Int,
    is_resting: Bool,
  )
}

pub fn parse_reindeer(from str: String) -> Reindeer {
  let assert [
    name,
    "can",
    "fly",
    smax_velocity,
    "km/s",
    "for",
    sstamina,
    "seconds,",
    "but",
    "then",
    "must",
    "rest",
    "for",
    srest,
    "seconds.",
  ] = str |> string.split(" ")
  let assert Ok(max_velocity) = int.parse(smax_velocity)
  let assert Ok(stamina) = int.parse(sstamina)
  let assert Ok(rest) = int.parse(srest)
  Reindeer(
    name:,
    max_velocity:,
    stamina:,
    rest:,
    distance: 0,
    points: 0,
    time_running: 0,
    time_resting: 0,
    is_resting: False,
  )
}

pub fn calculate_distance(
  time time: Int,
  reindeer reindeer: Reindeer,
  aux aux: Int,
) -> Int {
  case time - reindeer.stamina {
    n if n < 0 ->
      case time {
        n if n > 0 -> aux + { time * reindeer.max_velocity }
        _ -> aux
      }
    0 -> aux
    _ ->
      calculate_distance(
        { time - reindeer.stamina - reindeer.rest },
        reindeer,
        { aux + { reindeer.stamina * reindeer.max_velocity } },
      )
  }
}

pub fn aux_calculate_a_second(reindeer: Reindeer) -> Reindeer {
  case reindeer {
    Reindeer(name, max_vel, stamina, rest, dist, pts, _, time_resting, True)
      if time_resting == rest
    -> {
      Reindeer(name, max_vel, stamina, rest, dist + max_vel, pts, 1, 0, False)
    }
    Reindeer(name, max_vel, stamina, rest, dist, pts, _, time_resting, True) -> {
      Reindeer(
        name,
        max_vel,
        stamina,
        rest,
        dist,
        pts,
        0,
        time_resting + 1,
        True,
      )
    }
    Reindeer(name, max_vel, stamina, rest, dist, pts, time_running, _, False)
      if time_running == stamina
    -> {
      Reindeer(name, max_vel, stamina, rest, dist, pts, 0, 1, True)
    }
    Reindeer(name, max_vel, stamina, rest, dist, pts, time_running, _, False) -> {
      Reindeer(
        name,
        max_vel,
        stamina,
        rest,
        dist + max_vel,
        pts,
        time_running + 1,
        0,
        False,
      )
    }
  }
}

pub fn add_a_point_to_winner(reindeers: List(Reindeer)) -> List(Reindeer) {
  let max_distance =
    reindeers
    |> list.map(fn(r) { r.distance })
    |> list.fold(0, int.max)
  reindeers
  |> list.map(fn(r) {
    case r.distance == max_distance {
      True -> Reindeer(..r, points: r.points + 1)
      False -> r
    }
  })
}

pub fn calculate_a_second(reindeers reindeers: List(Reindeer)) -> List(Reindeer) {
  reindeers
  |> list.map(aux_calculate_a_second)
  |> add_a_point_to_winner
}

pub fn apply_n_times(value: a, n: Int, fun: fn(a) -> a) {
  case n <= 0 {
    True -> value
    False -> apply_n_times(fun(value), n - 1, fun)
  }
}

pub fn main() -> Nil {
  io.println("Hello from day_14!")
  let assert Ok(input) = simplifile.read(from: "input/input")
  let reindeers =
    input |> string.trim |> string.split("\n") |> list.map(parse_reindeer)
  echo reindeers
  echo reindeers
    |> list.map(calculate_distance(2503, _, 0))
    |> list.reduce(int.max)
    |> result.unwrap(0)
  echo [
      "Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.",
      "Dancer can fly 16 km/s for 11 seconds, but then must rest for 162 seconds.",
    ]
    |> list.map(parse_reindeer)
    |> apply_n_times(1000, calculate_a_second)
    |> list.map(fn(r) { r.points })
    |> list.reduce(int.max)
    |> result.unwrap(0)
  echo reindeers
    |> apply_n_times(2503, calculate_a_second)
    |> list.map(fn(r) { r.points })
    |> list.reduce(int.max)
    |> result.unwrap(0)
  Nil
}
