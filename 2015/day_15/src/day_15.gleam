import gleam/pair
import gleam/result
import gleam/int
import gleam/list
import gleam/string

pub type Ingredient {
  Ingredient(
    name: String,
    capacity: Int,
    durability: Int,
    flavor: Int,
    texture: Int,
    calories: Int,
  )
}

pub fn parse_ingredient(from str: String) -> Ingredient {
  let assert [
    name,
    "capacity",
    scapacity,
    "durability",
    sdurability,
    "flavor",
    sflavor,
    "texture",
    stexture,
    "calories",
    scalories,
  ] =
    str
    |> string.replace(each: ":", with: "")
    |> string.replace(with: "", each: ",")
    |> string.split(" ")
  let assert Ok(capacity) = int.parse(scapacity)
  let assert Ok(durability) = int.parse(sdurability)
  let assert Ok(flavor) = int.parse(sflavor)
  let assert Ok(texture) = int.parse(stexture)
  let assert Ok(calories) = int.parse(scalories)
  Ingredient(name:, capacity:, durability:, flavor:, texture:, calories:)
}

pub fn compositions(target: Int, parts_left: Int) -> List(List(Int)) {
  case parts_left {
    1 -> [[target]]
    _ -> {
      int.range(from: 0, to: target + 1, with: [], run: fn(acc, v) {
        let sub_compositions = compositions(target - v, parts_left - 1)
        let mapped = list.map(sub_compositions, fn(rest) { [v, ..rest] })
        list.append(acc, mapped)
      })
    }
  }
}

pub fn mult_ingredient(ingredient: Ingredient, val: Int) -> #(Int, Int, Int, Int, Int) {
  let Ingredient(_, capacity, durability, flavor, texture, calories) = ingredient
  #(val * capacity, val * durability, val * flavor, val * texture, val * calories)
}

pub fn calculate_item(c1, c2, c3, c4) {
  case c1 + c2 + c3 + c4 {
    n if n <= 0 -> 0
    n -> n
  }
}

pub fn apply_element(spoons: List(Int), ingredients: List(Ingredient)) -> #(Int, Int) {
  let assert [n1, n2, n3, n4] = spoons
  let assert [i1, i2, i3, i4] = ingredients
  let #(c11, c12, c13, c14, c15) = mult_ingredient(i1, n1)
  let #(c21, c22, c23, c24, c25) = mult_ingredient(i2, n2)
  let #(c31, c32, c33, c34, c35) = mult_ingredient(i3, n3)
  let #(c41, c42, c43, c44, c45) = mult_ingredient(i4, n4)
  let capacity = calculate_item(c11, c21, c31, c41)
  let durability = calculate_item(c12, c22, c32, c42)
  let flavor = calculate_item(c13, c23, c33, c43)
  let texture = calculate_item(c14, c24, c34, c44)
  let calories = calculate_item(c15, c25, c35, c45)
  #(capacity * durability * flavor * texture, calories)
}

pub fn main() {
  let result = compositions(100, 4)
  echo result |> list.length
  let elements =
    [
      "Frosting: capacity 4, durability -2, flavor 0, texture 0, calories 5",
      "Candy: capacity 0, durability 5, flavor -1, texture 0, calories 8",
      "Butterscotch: capacity -1, durability 0, flavor 5, texture 0, calories 6",
      "Sugar: capacity 0, durability 0, flavor -2, texture 2, calories 1",
    ] |> list.map(parse_ingredient)
    echo elements
  echo result |> list.map(apply_element(_, elements)) |> list.map(pair.first) |> list.reduce(int.max) |> result.unwrap(0)
  echo result |> list.map(apply_element(_, elements)) |> list.filter(fn (a) {a.1 == 500}) |> list.map(pair.first) |> list.reduce(int.max) |> result.unwrap(0)
}
