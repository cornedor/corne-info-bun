let readInput = path => Bun.file(~path)->Bun.BunFile.text

let toLines = (str, ~start=0, ~end=-1) =>
  String.trim(str)->String.split("\n")->Array.slice(~start, ~end)

let toLinesEnd = (str, ~start=0) => String.trim(str)->String.split("\n")->Array.sliceToEnd(~start)

let lineAt = (str, index, ~start=0) => toLines(str, ~start)->Array.at(index)

let splitStringList = (str, ~delimiter=" ") => String.split(str, delimiter)->Array.map(String.trim)

let splitIntList = (str, ~delimiter=" ") =>
  splitStringList(str, ~delimiter)->Array.map(item =>
    switch Belt.Int.fromString(item) {
    | Some(n) => n
    | None => panic("Could not parse Int: " ++ item)
    }
  )

let splitFloatList = (str, ~delimiter=" ") =>
  splitStringList(str, ~delimiter)->Array.map(item =>
    switch Belt.Float.fromString(item) {
    | Some(n) => n
    | None => panic("Could not parse Int: " ++ item)
    }
  )

let ensureSome = value =>
  switch value {
  | Some(value) => value
  | None => {
      Js.log2("Could not ensure value", value)
      panic("Could not ensure value. See log for more details")
    }
  }
