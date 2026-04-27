import gleam/dict
import gleam/result
import gleam/int
import gleam/list
import gleam/string
import graph.{type Undirected,type Graph,type Node,Context,Node}
import simplifile
import gleam/io

pub fn add_edge(to gr: Graph(Undirected, String, Int), add val: String) {
  let id = graph.nodes(gr) |> list.length
  graph.insert_node(gr, Node(id, val))
}

pub fn find_ids_for_graph(from gr: Graph(Undirected, String, Int), find val: String) -> Result(Int, Nil) {
  graph.nodes(gr) |> list.find(fn (n) { n.value == val }) |> result.map(fn (n) { n.id })
}

pub fn add_nodes_and_edge(to gr: Graph(Undirected, String, Int), add val: String) {
  let assert [node1, "to", node2, "=", svalue] = val |> string.split(" ")
  let assert Ok(value) = int.parse(svalue)
  case find_ids_for_graph(gr, node1), find_ids_for_graph(gr, node2) {
    Error(Nil), _ -> add_nodes_and_edge(add_edge(gr, node1), val)
    _, Error(Nil) -> add_nodes_and_edge(add_edge(gr, node2), val)
    Ok(n1), Ok(n2) -> graph.insert_undirected_edge(gr, value, n1, n2)
  }
}

pub fn create_graph(inputs: List(String)) -> Graph(Undirected, String, Int) {
  list.fold(over: inputs, with: add_nodes_and_edge, from: graph.new() )
}

pub fn calculate_path_distance(with routes: Graph(Undirected, String, Int), path path: List(Node(String))) {
  case path {
    [] -> 0
    [_] -> 0
    [Node(id1, _), Node(id2, v), ..rest] -> {
      let assert Ok(#(Context(_, _, outgoing), _)) = graph.match(routes, id1)
      let assert Ok(value) = dict.get(outgoing, id2)
      value + calculate_path_distance(routes, [Node(id2, v), ..rest])
    }
  }
}

pub fn main() -> Nil {
  io.println("Hello from day_9!")
  let assert Ok(input) = simplifile.read(from: "input/input")
  let routes = create_graph(input |> string.trim |> string.split("\n"))
  let distances = graph.nodes(routes) |> list.permutations |> list.map(calculate_path_distance(routes, _))
  echo distances |> list.reduce(int.min) |> result.unwrap(0)
  echo distances |> list.reduce(int.max) |> result.unwrap(0)
  Nil
}
