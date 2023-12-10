open Aoc

let rec findDifferencesInLine = line => {
  switch line {
  | list{a, b} => list{b - a}
  | list{a, b, ...tail} => list{b - a, ...findDifferencesInLine(list{b, ...tail})}
  | _ => panic("Huh?")
  }
}

let rec reduceDifferrenesToZero = line => {
  let diffs = findDifferencesInLine(line)
  let someNotZero = List.some(diffs, item => item != 0)

  switch !someNotZero {
  | true => list{diffs}
  | false => list{diffs, ...reduceDifferrenesToZero(diffs)}
  }
}

let parseSensorData = async path => {
  let lines =
    (await readInput(path))
    ->toLinesEnd
    ->Array.map(l => {
      let list = splitIntList(l)->List.fromArray
      list{list, ...reduceDifferrenesToZero(list)}
    })

  Js.log2(
    "Result",
    Array.reduce(lines, (0, 0), ((left, right), line) => {
      let lineRight = line->List.map(ListUtils.lastExn)->List.reduce(0, \"+")
      let lineLeft = line->List.map(List.headExn)->List.reverse->List.reduce(0, (t, s) => s - t)

      (left + lineLeft, right + lineRight)
    }),
  )
}

let _ = parseSensorData("./inputs/d9-example.aoc")
let _ = parseSensorData("./inputs/d9-input.aoc")
