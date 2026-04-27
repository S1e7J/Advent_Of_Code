import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/dict.{type Dict}
import simplifile

type Source {
  Integer(Int)
  Identifier(String)
}

type Operation {
  Value(Source)
  Not(Source)
  And(Source, Source)
  Or(Source, Source)
  LShift(to: Source, places: Int)
  RShift(to: Source, places: Int)
}

fn parse_source(name) {
  case int.parse(name) {
    Ok(n) -> Integer(n)
    Error(_) -> Identifier(name)
  }
}

fn parse_operation(from input: String) -> Result(Operation, Nil) {
  let tokens =
    input
    |> string.trim
    |> string.split(" ")
    |> list.filter(fn(token) { token != "" })
  case tokens {
    [name] -> Ok(Value(parse_source(name)))
    ["NOT", name] -> Ok(Not(parse_source(name)))
    [id1, "AND", id2] -> Ok(And(parse_source(id1), parse_source(id2)))
    [id1, "OR", id2] -> Ok(Or(parse_source(id1), parse_source(id2)))
    [id1, "LSHIFT", n] ->
      case int.parse(n) {
        Ok(n) -> Ok(LShift(parse_source(id1), n))
        Error(_) -> Error(Nil)
      }
    [id1, "RSHIFT", n] ->
      case int.parse(n) {
        Ok(n) -> Ok(RShift(parse_source(id1), n))
        Error(_) -> Error(Nil)
      }
    _ -> Error(Nil)
  }
}

type Instruction {
  Instruction(operation: Operation, end_wire: Source)
}

fn parse_instruction(from values: #(String, String)) -> Result(Instruction, Nil) {
  let #(operation, obj) = values
  case parse_operation(operation), parse_source(obj) {
    Ok(op), Identifier(n) -> Ok(Instruction(op, Identifier(n)))
    _, _ -> Error(Nil)
  }
}

fn mask16(x: Int) -> Int {
  int.bitwise_and(x, 0xFFFF)
}

fn find_value_cached(
  instructions: List(Instruction),
  source: Source,
  cache: Dict(String, Int),
) -> #(Int, Dict(String, Int)) {
  case source {
    Integer(n) -> #(mask16(n), cache)
    Identifier(name) -> {
      case dict.get(cache, name) {
        Ok(value) -> #(value, cache)
        Error(Nil) -> {
          let assert Ok(Instruction(operation, _)) =
            instructions
            |> list.find(fn(inst) { inst.end_wire == source })
          let #(result, new_cache) = case operation {
            Value(Integer(n)) -> #(mask16(n), cache)
            Value(Identifier(n)) ->
              find_value_cached(instructions, Identifier(n), cache)
            Not(s) -> {
              let #(v, c) = find_value_cached(instructions, s, cache)
              #(mask16(int.bitwise_not(v)), c)
            }

            And(s1, s2) -> {
              let #(v1, c1) = find_value_cached(instructions, s1, cache)
              let #(v2, c2) = find_value_cached(instructions, s2, c1)
              #(mask16(int.bitwise_and(v1, v2)), c2)
            }

            Or(s1, s2) -> {
              let #(v1, c1) = find_value_cached(instructions, s1, cache)
              let #(v2, c2) = find_value_cached(instructions, s2, c1)
              #(mask16(int.bitwise_or(v1, v2)), c2)
            }

            LShift(s, places) -> {
              let #(v, c) = find_value_cached(instructions, s, cache)
              #(mask16(int.bitwise_shift_left(v, places)), c)
            }

            RShift(s, places) -> {
              let #(v, c) = find_value_cached(instructions, s, cache)
              #(mask16(int.bitwise_shift_right(v, places)), c)
            }
          }
          #(result, dict.insert(new_cache, name, result))
        }
      }
    }
  }
}

fn find_value(instructions: List(Instruction), source: Source) -> Int {
  let #(value, _) = find_value_cached(instructions, source, dict.new())
  value
}

pub fn main() -> Nil {
  io.println("Hello from day_7!")
  let assert Ok(input) = simplifile.read(from: "input/input")
  let assert Ok(commands) =
    input
    |> string.trim
    |> string.split("\n")
    |> list.map(string.split_once(_, " -> "))
    |> result.all
    |> result.try(fn(a) { a |> list.map(parse_instruction) |> result.all })
  echo commands
  echo find_value(commands, Identifier("a"))
  let new_commands = commands |> list.map(fn (a) {
      case a {
        Instruction(_, Identifier("b"))  -> Instruction(Value(Integer(46065)), Identifier("b"))
        n -> n
      }
    })
  echo find_value(new_commands, Identifier("a"))
  Nil
}
