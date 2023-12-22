let exampleData = await Bun.file(~path="./inputs/d8-example.aoc")->Bun.BunFile.text
let data = await Bun.file(~path="./inputs/d8-input.aoc")->Bun.BunFile.text

let getNextStep = (instruction, currentPosition) =>
  switch instruction {
  | "L" => {
      let (left, _) = currentPosition
      left
    }
  | "R" => {
      let (_, right) = currentPosition
      right
    }
  | _ => raise(Not_found)
  }

let getNextInstruction = (instructions, index) =>
  switch Array.at(instructions, index) {
  | Some(instruction) => (instruction, index + 1)
  | None => (
      switch Array.at(instructions, 0) {
      | Some(i) => i
      | None => raise(Not_found)
      },
      1,
    )
  }

let rec walkSteps = (comparator, instructions, index, currentPosition, map, count) => {
  let (instruction, nextIndex) = getNextInstruction(instructions, index)

  let currentPosition = switch Belt.Map.String.get(map, currentPosition) {
  | Some(pos) => pos
  | _ => raise(Not_found)
  }

  let nextStep = getNextStep(instruction, currentPosition)

  switch comparator(nextStep) {
  | true => count
  | false => walkSteps(comparator, instructions, nextIndex, nextStep, map, count + 1)
  }
}

let step = walkSteps(s => s == "ZZZ", ...)
let stepZ = walkSteps(s => String.charAt(s, 2) === "Z", ...)

let getOptions = (instructions, map: Belt.Map.String.t<(string, string)>, keys: array<string>) => {
  let values = Array.map(keys, key => {
    BigInt.fromInt(stepZ(instructions, 0, key, map, 1))
  })->List.fromArray

  Aoc.lcmMany(values)
}

let parseLines = (text, runFirst) => {
  let instructions = Aoc.splitStringList(Aoc.ensureSome(Aoc.lineAt(text, 0)), ~delimiter="")

  let empty: Belt.Map.String.t<(string, string)> = Belt.Map.String.empty
  let map = Aoc.toLinesEnd(text, ~start=2)->Array.reduce(empty, (mapping, line) => {
    let position = String.substring(line, ~start=0, ~end=3)
    let l = String.substring(line, ~start=7, ~end=10)
    let r = String.substring(line, ~start=12, ~end=15)
    Belt.Map.String.set(mapping, position, (l, r))
  })

  switch runFirst {
  | true => Js.log2("Human map:", step(instructions, 0, "AAA", map, 1))
  | false => ()
  }

  let keys = Belt.Map.String.keysToArray(map)->Array.filter(item => String.charAt(item, 2) == "A")
  Js.log2("Ghost map:", getOptions(instructions, map, keys))
}

let _ = parseLines(exampleData, false)
let _ = parseLines(data, true)
