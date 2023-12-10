let rec last = list =>
  switch list {
  | list{x} => Some(x)
  | list{_, ...tail} => last(tail)
  | list{} => None
  }

let lastExn = list =>
  switch last(list) {
  | Some(x) => x
  | None => raise(Not_found)
  }
