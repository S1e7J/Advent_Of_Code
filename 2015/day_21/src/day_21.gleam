import gleam/result
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}

pub type Character {
  Character(hitpoints: Int, damage: Int, armor: Int)
}

pub type Element {
  Element(name: String, cost: Int, damage: Int, armor: Int)
}

pub type Set {
  Set(
    weapon: Element,
    armor: Option(Element),
    ring_left: Option(Element),
    ring_right: Option(Element),
  )
}

pub fn apply_element(to ch: Character, with el: Element) -> Character {
  Character(..ch, damage: ch.damage + el.damage, armor: ch.armor + el.armor)
}

pub fn apply_set(to ch: Character, with st: Set) -> Character {
  let ch_weapon = apply_element(ch, st.weapon)
  [st.ring_right, st.ring_left, st.armor]
  |> list.fold(ch_weapon, fn(acc, el) {
    case el {
      Some(el) -> apply_element(acc, el)
      None -> acc
    }
  })
}

pub fn create_sets() -> List(Set) {
  let rings_opts =
    list.flatten([
      [#(None, None)],
      list.map(rings, fn(r) { #(r, None) }),
      list.combinations(rings, 2)
        |> list.map(fn(pair) {
          let assert [r1, r2] = pair
          #(r1, r2)
        }),
    ])
  list.flat_map(weapons, fn(weapon) {
    list.flat_map(armor, fn(armor) {
      list.map(rings_opts, fn(rings) {
        Set(
          weapon: weapon,
          armor: armor,
          ring_left: rings.0,
          ring_right: rings.1,
        )
      })
    })
  })
}

fn total_cost(of st: Set) -> Int {
  let pc_weapon = st.weapon.cost
  [st.ring_right, st.ring_left, st.armor]
  |> list.fold(pc_weapon, fn(acc, el) {
    case el {
      Some(el) -> acc + el.cost
      None -> acc
    }
  })
}

pub fn can_win(they mc: Character) -> Bool {
  let damage_boss = case boss.damage - mc.armor {
    n if n <= 0 -> 1
    n -> n
  }

  let damage_mc = case mc.damage - boss.armor {
    n if n <= 0 -> 1
    n -> n
  }

  let turns_mc_needs = { boss.hitpoints + damage_mc - 1 } / damage_mc
  let turns_boss_needs = { mc.hitpoints + damage_boss - 1 } / damage_boss

  turns_mc_needs <= turns_boss_needs
}

const boss = Character(104, 8, 1)

const weapons = [
  Element("Dagger", 8, 4, 0),
  Element("ShortSword", 10, 5, 0),
  Element("Warhammer", 25, 6, 0),
  Element("Longsword", 40, 7, 0),
  Element("GreateAxe", 74, 8, 0),
]

const armor = [
  None,
  Some(Element("Leather", 13, 0, 1)),
  Some(Element("Chainmail", 31, 0, 2)),
  Some(Element("Splintmail", 53, 0, 3)),
  Some(Element("Bandedmail", 75, 0, 4)),
  Some(Element("Platemail", 102, 0, 5)),
]

const rings = [
  None,
  Some(Element("Damage +1", 25, 1, 0)),
  Some(Element("Damage +2", 50, 2, 0)),
  Some(Element("Damage +3", 100, 3, 0)),
  Some(Element("Defense +1", 20, 0, 1)),
  Some(Element("Defense +2", 40, 0, 2)),
  Some(Element("Defense +3", 80, 0, 3)),
]

pub fn main() -> Nil {
  let eu = Character(100, 0, 0)
  let sets = create_sets() |> list.sort(fn (a, b) { int.compare(total_cost(a), total_cost(b))})
  let _ = echo sets |> list.find(fn (s) { can_win(apply_set(eu, s)) }) |> result.map(total_cost)
  let rev_sets = create_sets() |> list.sort(fn (a, b) { int.compare(total_cost(b), total_cost(a))})
  let _ = echo rev_sets |> list.find(fn (s) { !can_win(apply_set(eu, s)) }) |> result.map(total_cost)
  Nil
}
