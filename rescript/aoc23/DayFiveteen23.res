let hash = str => {
  let hashNum = ref(0.0)

  for x in 0 to String.length(str) - 1 {
    let charCode = String.charCodeAt(str, x)
    hashNum := mod_float((hashNum.contents +. charCode) *. 17., 256.)
  }

  hashNum.contents
}

let hashMap = op => {
  let map = Map.make()

  for x in 0 to Array.length(op) - 1 {
    let item = Array.getUnsafe(op, x)
    let instructionOffset = switch (String.indexOf(item, "-"), String.indexOf(item, "=")) {
    | (v, -1) => v
    | (-1, v) => v
    | _ => panic("Two instructions found")
    }
    let boxLabel = String.slice(item, ~start=0, ~end=instructionOffset)
    let box = boxLabel->hash->Float.toInt
    let instruction = String.slice(item, ~start=instructionOffset, ~end=instructionOffset + 1)
    switch instruction {
    | "-" =>
      switch Map.get(map, box) {
      | Some(line) => Map.set(map, box, Array.filter(line, ((label, _)) => label != boxLabel))
      | None => ()
      }
    | "=" => {
        let value =
          Int.fromString(String.sliceToEnd(item, ~start=instructionOffset + 1))->Aoc.ensureSome
        switch Map.get(map, box) {
        | Some(boxMap) =>
          switch Array.findIndex(boxMap, ((item, _)) => item == boxLabel) {
          | index if index == -1 => Array.push(boxMap, (boxLabel, value))
          | index => boxMap[index] = (boxLabel, value)
          }
        | None => Map.set(map, box, [(boxLabel, value)])
        }
      }
    | c => panic("Unkown instruction: " ++ c)
    }
  }

  let total = ref(0)
  Map.forEachWithKey(map, (value, key) => {
    total :=
      total.contents +
      Array.reduceWithIndex(value, 0, (acc, (_, focalLength), slot) => {
        acc + (key + 1) * (slot + 1) * focalLength
      })
  })

  total.contents
}

Js.log2("hash", hash("HASH"))
Js.log("")

Console.time("done")
let input = (await Aoc.readInput("inputs/d15-input.aoc"))->Aoc.splitStringList(~delimiter=",")
Js.log2("Part 1", input->Array.map(hash)->Array.reduce(0., \"+."))

Js.log2("Part 2", hashMap(input))
Console.timeEnd("done")
