import gleam/int
import gleam/io
import gleam/crypto

pub type Target {
  FiveZeros
  SixZeros
}

pub fn is_match(from encode: BitArray, with target: Target) -> Bool {
  case encode, target {
    <<0:size(16), 0:size(4), _:bits>>, FiveZeros -> True
    <<0:size(16), 0:size(8), _:bits>>, SixZeros -> True
    _, _ -> False
  }
}

pub fn find_result(secret secret: String, nunlock nunlock: Int, with target: Target) -> String {
  let value = int.to_string(nunlock)
  case crypto.hash(crypto.Md5, <<secret:utf8, value:utf8>>) |> is_match(with: target) {
    True -> secret <> value
    False -> find_result(secret:, nunlock: {nunlock + 1}, with: target)
  }
}

pub fn main() -> Nil {
  io.println("Hello from day_4!")
  echo find_result("yzbqklnj", 0, FiveZeros)
  echo find_result("yzbqklnj", 0, SixZeros)
  Nil
}
