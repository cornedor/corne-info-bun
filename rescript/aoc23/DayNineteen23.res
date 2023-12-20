let input = (await Aoc.readInput("inputs/d19-input.aoc"))->String.trim

type action = Accept | Reject | Move(string)
type rule = Gt(string, int, action) | Lt(string, int, action) | Else(action)
type hypercube = ((int, int, int, int), (int, int, int, int))

let getReaction = str => {
  switch str {
  | "A" => Accept
  | "R" => Reject
  | v => Move(v)
  }
}
let parseInstruction = str => {
  switch String.split(str, ":") {
  | [action, reaction] =>
    let item = String.charAt(str, 1)
    switch item {
    | ">" => {
        let parts = String.split(action, ">")
        let key = Array.getUnsafe(parts, 0)
        let value = Array.getUnsafe(parts, 1)->Int.fromString->Aoc.ensureSomeM("Gt int")

        Gt(key, value, getReaction(reaction))
      }
    | "<" => {
        let parts = String.split(action, "<")
        let key = Array.getUnsafe(parts, 0)
        let value = Array.getUnsafe(parts, 1)->Int.fromString->Aoc.ensureSomeM("Lt int")

        Lt(key, value, getReaction(reaction))
      }
    | _ => panic("Invalid instruction")
    }

  | [reaction] => Else(getReaction(reaction))
  | _ => panic("Invalid instruction")
  }
}

let parseInstructions = arr => {
  switch arr {
  | [name, instructions] => (
      name,
      instructions
      ->String.replace("}", "")
      ->Aoc.splitStringList(~delimiter=",")
      ->Array.map(part => parseInstruction(part))
      ->List.fromArray,
    )
  | _ => panic("Invalid input")
  }
}

let (instructions, parts) = switch String.split(input, "\n\n") {
| [instructions, parts] => (
    instructions
    ->Aoc.toLinesEnd
    ->Array.map(line => String.split(line, "{")->parseInstructions)
    ->Map.fromArray,
    parts
    ->Aoc.toLinesEnd
    ->Array.map(line => {
      line
      ->String.replace("{", "")
      ->String.replace("}", "")
      ->Aoc.splitStringList(~delimiter=",")
      ->Array.map(str => {
        switch String.split(str, "=") {
        | [name, value] => (name, Int.fromString(value)->Aoc.ensureSomeM("= int"))
        | _ => panic("Invalid input")
        }
      })
      ->Map.fromArray
    }),
  )
| _ => panic("Invalid input")
}

let getU = (m, k) => Map.get(m, k)->Aoc.ensureSomeM("Invalid data")
let getPartValue = part => Map.values(part)->Core__Iterator.toArray->Array.reduce(0, \"+")
let cube: hypercube = ((1, 1, 1, 1), (4001, 4001, 4001, 4001))

let clamp = (start, stop, index) => min(max(start, index), stop)

let sliceX = (cube: hypercube, x) => {
  let ((sx, sm, sa, ss), (ex, em, ea, es)) = cube
  let x = clamp(sx, ex, x)
  (((sx, sm, sa, ss), (x, em, ea, es)), ((x, sm, sa, ss), (ex, em, ea, es)))
}
let sliceM = (cube: hypercube, m) => {
  let ((sx, sm, sa, ss), (ex, em, ea, es)) = cube
  let m = clamp(sm, em, m)
  (((sx, sm, sa, ss), (ex, m, ea, es)), ((sx, m, sa, ss), (ex, em, ea, es)))
}
let sliceA = (cube: hypercube, a) => {
  let ((sx, sm, sa, ss), (ex, em, ea, es)) = cube
  let a = clamp(sa, ea, a)
  (((sx, sm, sa, ss), (ex, em, a, es)), ((sx, sm, a, ss), (ex, em, ea, es)))
}
// I guess using tuples has a downside...
let sliceS = (cube: hypercube, s) => {
  let ((sx, sm, sa, ss), (ex, em, ea, es)) = cube
  let s = clamp(ss, es, s)
  (((sx, sm, sa, ss), (ex, em, ea, s)), ((sx, sm, sa, s), (ex, em, ea, es)))
}

let sliceHyperCubeKey = (cube: hypercube, key: string, index: int) => {
  switch key {
  | "x" => sliceX(cube, index)
  | "m" => sliceM(cube, index)
  | "a" => sliceA(cube, index)
  | "s" => sliceS(cube, index)
  | _ => (cube, cube)
  }
}

let hypercubeVolume = (((sx, sm, sa, ss), (ex, em, ea, es)): hypercube) => {
  BigInt.mul(
    BigInt.fromInt(ex - sx),
    BigInt.mul(
      BigInt.fromInt(em - sm),
      BigInt.mul(BigInt.fromInt(ea - sa), BigInt.fromInt(es - ss)),
    ),
  )
}

let rec doStep = (workflow: string, cube: hypercube) => {
  let steps = Map.get(instructions, workflow)->Aoc.ensureSomeM("Could not find workflow")
  // let count = Array.length(steps)
  let (_, acc) = List.reduce(steps, (cube, BigInt.fromInt(0)), ((cube, acc), step) => {
    switch step {
    | Else(action) => (
        cube,
        switch action {
        | Accept => BigInt.add(acc, hypercubeVolume(cube))
        | Reject => acc
        | Move(step) => BigInt.add(acc, doStep(step, cube))
        },
      )
    | Gt(key, value, action) => {
        let (mismatch, match) = sliceHyperCubeKey(cube, key, value + 1)
        (
          mismatch,
          switch action {
          | Accept => BigInt.add(acc, hypercubeVolume(match))
          | Reject => acc
          | Move(step) => BigInt.add(acc, doStep(step, match))
          },
        )
      }
    | Lt(key, value, action) => {
        let (match, mismatch) = sliceHyperCubeKey(cube, key, value)
        (
          mismatch,
          switch action {
          | Accept => BigInt.add(acc, hypercubeVolume(match))
          | Reject => acc
          | Move(step) => BigInt.add(acc, doStep(step, match))
          },
        )
      }
    }
  })
  acc
}

let accepted =
  Array.filter(parts, part => {
    let cube = (
      (getU(part, "x"), getU(part, "m"), getU(part, "a"), getU(part, "s")),
      (getU(part, "x") + 1, getU(part, "m") + 1, getU(part, "a") + 1, getU(part, "s") + 1),
    )
    BigInt.toInt(doStep("in", cube)) == 1
  })
  ->Array.map(getPartValue)
  ->Array.reduce(0, \"+")
Js.log2("Result Part 1", accepted)
Js.log2("Result Part 2", doStep("in", cube))
