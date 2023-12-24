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

let ensureSomeM = (value, message) =>
  switch value {
  | Some(value) => value
  | None => panic("Could not ensure value: " ++ message)
  }

let logList = list => Js.log2("list", List.toArray(list))
let logList2 = (tag, list) => Js.log3(tag, "list", List.toArray(list))

external parseIntWithRadix: (string, int) => int = "parseInt"
external abs: float => float = "Math.abs"

let posFromIndex = (lineWidth, index) => {
  let x = mod(index, lineWidth)
  let y = index / lineWidth
  (x, y)
}
let posToIndex = (lineWidth, x, y) => x + y * lineWidth

let charAtPos = (str, lineWidth, x, y) => String.charAt(str, posToIndex(lineWidth, x, y))

let _u = Array.getUnsafe
let transposeArray = arr => {
  Array.mapWithIndex(_u(arr, 0), (_, index) => {
    Array.map(arr, row => _u(row, index))
  })
}

let adjecent = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]

let rec gcd = (a, b) => {
  switch BigInt.fromInt(0) == b {
  | true => a
  | false => gcd(b, BigInt.mod(a, b))
  }
}

let lcm = (a, b) => {
  let div = gcd(a, b)
  BigInt.div(BigInt.mul(a, b), div)
}

let rec lcmMany = (items: list<BigInt.t>) => {
  switch items {
  | list{} => panic("Programming error")
  | list{last} => last
  | list{head, tail} => lcm(head, tail)
  | list{head, ...tail} => lcm(head, lcmMany(tail))
  }
}

@genType
let wait = timeout =>
  Promise.make((resolve, _reject) => {
    let _ = setTimeout(() => {
      resolve()
    }, timeout)
  })
