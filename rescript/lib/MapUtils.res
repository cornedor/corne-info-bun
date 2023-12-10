let getExn = (map, key) =>
  switch Map.get(map, key) {
  | Some(v) => v
  | None => raise(Not_found)
  }
