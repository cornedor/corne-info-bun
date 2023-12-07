let exampleData1 = await Bun.file(~path="./inputs/d1-example-1.aoc")->Bun.BunFile.text
let exampleData2 = await Bun.file(~path="./inputs/d1-example-2.aoc")->Bun.BunFile.text
let data = await Bun.file(~path="./inputs/d1-input.aoc")->Bun.BunFile.text

let basicNumbers =
  Array.make(~length=9, 0)->Js.Array2.mapi((_, i) => (Belt.Int.toString(i + 1), i + 1))

let wordNumbers = Js.Array2.concat(
  basicNumbers,
  [
    ("one", 1),
    ("two", 2),
    ("three", 3),
    ("four", 4),
    ("five", 5),
    ("six", 6),
    ("seven", 7),
    ("eight", 8),
    ("nine", 9),
  ],
)

let getNumberFromLine = (line, (numberStr, numberValue)) => {
  (String.indexOf(line, numberStr), numberValue)
}
let getLastNumberFromLine = (line, (numberStr, numberValue)) => {
  (String.lastIndexOf(line, numberStr), numberValue)
}

let filterMismatch = items => Js.Array2.filter(items, ((index, _)) => index >= 0)

let extractNumbers = (numbers, line): int => {
  let numberIndices =
    numbers->Js.Array2.map(number => getNumberFromLine(line, number))->filterMismatch
  let lastNumberIndices =
    numbers->Js.Array2.map(number => getLastNumberFromLine(line, number))->filterMismatch

  let tail = numberIndices[0]
  let rest = Js.Array2.sliceFrom(numberIndices, 1)

  let (_, first) = switch tail {
  | Some(first) => rest->Js.Array2.reduce(((index, value), (lowestIndex, lowestIndexValue)) => {
      switch index < lowestIndex {
      | true => (index, value)
      | _ => (lowestIndex, lowestIndexValue)
      }
    }, first)
  | None => (0, 0)
  }

  let tail = lastNumberIndices[0]
  let rest = Js.Array2.sliceFrom(lastNumberIndices, 1)
  let (_, last) = switch tail {
  | Some(first) => rest->Js.Array2.reduce(((index, value), (lowestIndex, lowestIndexValue)) => {
      switch index > lowestIndex {
      | true => (index, value)
      | _ => (lowestIndex, lowestIndexValue)
      }
    }, first)
  | None => (0, 0)
  }

  first * 10 + last
}

let runExample1 = () =>
  Js.Array2.map(exampleData1->String.split("\n"), item =>
    extractNumbers(wordNumbers, item)
  )->Array.reduce(0, \"+")

let runExample2 = () =>
  Js.Array2.map(exampleData2->String.split("\n"), item =>
    extractNumbers(wordNumbers, item)
  )->Array.reduce(0, \"+")

let input = data->Js.String2.split("\n")
let runPart1 = () =>
  Array.map(input, item => extractNumbers(basicNumbers, item))->Array.reduce(0, \"+")
let runPart2 = () =>
  Array.map(input, item => extractNumbers(wordNumbers, item))->Array.reduce(0, \"+")
