import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import graph.{type Directed, type Graph, type Node, Context, Node}
import simplifile

pub fn add_edge(to gr: Graph(Directed, String, Int), add val: String) {
  let id = graph.nodes(gr) |> list.length
  graph.insert_node(gr, Node(id, val))
}

pub fn find_ids_for_graph(
  from gr: Graph(Directed, String, Int),
  find val: String,
) -> Result(Int, Nil) {
  graph.nodes(gr)
  |> list.find(fn(n) { n.value == val })
  |> result.map(fn(n) { n.id })
}

pub fn add_nodes_and_edge(to gr: Graph(Directed, String, Int), add val: String) {
  let assert [
    node1,
    "would",
    val1,
    val2,
    "happiness",
    "units",
    "by",
    "sitting",
    "next",
    "to",
    node2,
  ] = val |> string.split(" ")
  let assert Ok(nval) = int.parse(val2)
  let modifier = case val1 {
    "lose" -> -1
    "gain" -> 1
    _ -> 0
  }
  let value = modifier * nval
  case find_ids_for_graph(gr, node1), find_ids_for_graph(gr, node2) {
    Error(Nil), _ -> add_nodes_and_edge(add_edge(gr, node1), val)
    _, Error(Nil) -> add_nodes_and_edge(add_edge(gr, node2), val)
    Ok(n1), Ok(n2) -> graph.insert_directed_edge(gr, value, n1, n2)
  }
}

pub fn create_graph(inputs: List(String)) -> Graph(Directed, String, Int) {
  list.fold(over: inputs, with: add_nodes_and_edge, from: graph.new())
}

pub fn aux_calculate_path_distance(
  with routes: Graph(Directed, String, Int),
  path path: List(Node(String)),
  beggining_with first: Int,
) -> Int {
  case path {
    [] -> 0
    [Node(id, _)] -> {
      let assert Ok(#(Context(_, _, outgoing), _)) = graph.match(routes, id)
      let value1 = dict.get(outgoing, first) |> result.unwrap(0)
      let assert Ok(#(Context(_, _, outgoing), _)) = graph.match(routes, first)
      let value2 = dict.get(outgoing, id) |> result.unwrap(0)
      value1 + value2
    }
    [Node(id1, _), Node(id2, v), ..rest] -> {
      let assert Ok(#(Context(_, _, outgoing), _)) = graph.match(routes, id1)
      let value1 = dict.get(outgoing, id2) |> result.unwrap(0)
      let assert Ok(#(Context(_, _, outgoing), _)) = graph.match(routes, id2)
      let value2 = dict.get(outgoing, id1) |> result.unwrap(0)
      value1
      + value2
      + aux_calculate_path_distance(routes, [Node(id2, v), ..rest], first)
    }
  }
}

pub fn calculate_path_distance(
  with routes: Graph(Directed, String, Int),
  path path: List(Node(String)),
) -> Int {
  let assert Ok(Node(first, _)) = list.first(path)
  aux_calculate_path_distance(routes, path, first)
}

pub fn aux_add_myself(
  in routes: Graph(Directed, String, Int),
  add_me me: Int,
  nodes nodes: List(Node(String)),
) -> Graph(Directed, String, Int) {
  case nodes {
    [] -> routes
    [Node(n1, _), ..rest] -> {
      routes
      |> graph.insert_directed_edge(0, n1, me)
      |> graph.insert_directed_edge(0, me, n1)
      |> aux_add_myself(me, rest)
    }
  }
}

pub fn add_myself(
  in routes: Graph(Directed, String, Int),
) -> Graph(Directed, String, Int) {
  let nodes = graph.nodes(routes)
  let id_myself = nodes |> list.length
  let new_routes = graph.insert_node(routes, Node(id_myself, "Myself"))
  aux_add_myself(new_routes, id_myself, nodes)
}

pub fn main() -> Nil {
  io.println("Hello from day_9!")
  let assert Ok(input) = simplifile.read(from: "input/input")
  let routes =
    create_graph(
      input
      |> string.trim
      |> string.replace(each: ".", with: "")
      |> string.split("\n"),
    )
  let distances =
    graph.nodes(routes)
    |> list.permutations
    |> list.map(calculate_path_distance(routes, _))
  echo distances |> list.reduce(int.max) |> result.unwrap(0)
  let new_routes = add_myself(routes)
  let new_distances =
    graph.nodes(new_routes)
    |> list.permutations
    |> list.map(calculate_path_distance(new_routes, _))
  echo new_distances |> list.reduce(int.max) |> result.unwrap(0)
  Nil
}
