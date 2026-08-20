import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub type Compound {
  Children(n: Int)
  Cats(n: Int)
  Samoyeds(n: Int)
  Pomeranians(n: Int)
  Akitas(n: Int)
  Vizslas(n: Int)
  GoldFish(n: Int)
  Trees(n: Int)
  Cars(n: Int)
  Perfumes(n: Int)
}

pub type AuntSue {
  AuntSue(name: String, chars: List(Compound))
}

const obj = AuntSue(
  name: "Objetivo",
  chars: [
    Children(3),
    Cats(7),
    Samoyeds(2),
    Pomeranians(3),
    Akitas(0),
    Vizslas(0),
    GoldFish(5),
    Trees(3),
    Cars(2),
    Perfumes(1),
  ],
)

fn token_compound(name: String, with: String) -> Compound {
  let assert Ok(n) = int.parse(with)
  case name {
    "children" -> Children
    "cats" -> Cats
    "samoyeds" -> Samoyeds
    "pomeranians" -> Pomeranians
    "akitas" -> Akitas
    "vizslas" -> Vizslas
    "goldfish" -> GoldFish
    "trees" -> Trees
    "cars" -> Cars
    "perfumes" -> Perfumes
    _ -> panic as "There is an unrecognizable compound"
  }(n)
}

fn parse_chars(elems: List(String)) -> List(Compound) {
  case elems {
    [] -> []
    [name, with, ..rest] -> [token_compound(name, with), ..parse_chars(rest)]
    _ -> panic as "Incorrect number of elements"
  }
}

fn parse_aunt_sue(aunt: List(String)) -> AuntSue {
  let assert ["Sue", name, ..elems] = aunt
  let chars = parse_chars(elems)
  AuntSue(name:, chars:)
}

fn parse_aunts(input: String) -> List(AuntSue) {
  input
  |> string.trim
  |> string.split(on: "\n")
  |> list.map(fn(a) {
    string.trim(a)
    |> string.replace(each: ":", with: "")
    |> string.replace(",", "")
    |> string.split(" ")
  })
  |> list.map(parse_aunt_sue)
}

fn sublist(this list1: List(a), of_that list2: List(a)) -> Bool {
  case list1 {
    [] -> True
    [el, ..rest] -> list.contains(list2, el) && sublist(rest, list2)
  }
}

fn conditions(comp: Compound) -> Bool {
  case comp {
    Cats(n) -> n > 7
    Trees(n) -> n > 3
    Pomeranians(n) -> n < 3
    GoldFish(n) -> n < 5
    n -> list.contains(obj.chars, n)
  }
}

fn fulfills(this aunt: AuntSue) -> Nil {
  case aunt.chars |> list.fold(True, fn(b, comp) { b && conditions(comp) }) {
    True -> io.println("We found the aunt: " <> aunt.name)
    False -> Nil
  }
}

fn check_if_obj(aunt: AuntSue) -> Nil {
  case sublist(aunt.chars, obj.chars) {
    True -> io.println("We found the aunt: " <> aunt.name)
    False -> Nil
  }
}

pub fn main() -> Nil {
  let assert Ok(input) = simplifile.read(from: "input/input")
  let aunts = parse_aunts(input)
  list.each(aunts, check_if_obj)
  list.each(aunts, fulfills)
}
