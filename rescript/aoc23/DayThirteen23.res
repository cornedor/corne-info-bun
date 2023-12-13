let compareStrings = (a, b) => {
  let la = String.split(a, "")
  let lb = String.split(b, "")
  Array.reduceWithIndex(la, 0, (errors, sa, index) => {
    errors +
    switch lb[index] {
    | None => -1
    | Some(sb) if sb == sa => 0
    | Some(_) => -1
    }
  })
}

let rec checkHLine = (lines, up, down) => {
  switch (lines[up], lines[down]) {
  | (None, _) | (_, None) => up
  | (Some(a), Some(b)) if a == b => checkHLine(lines, up - 1, down + 1)
  | (_, _) => -999
  }
}

let checkHLine2 = (lines, line, corrections) => {
  let valid = ref(true)
  let corrections = ref(corrections)
  for x in 0 to Array.length(lines) {
    let up = line - x
    let down = line + x + 1
    switch (lines[up], lines[down]) {
    | (Some(lup), Some(ldown)) => {
        let compared = compareStrings(lup, ldown)
        corrections := corrections.contents + compared
        if corrections.contents < 0 {
          valid := false
        }
      }
    | (None, _) | (_, None) => valid := valid.contents
    }
  }

  (valid.contents, corrections.contents)
}

let rec findHMirror = (lines, offset, corrections): (int, int) => {
  let linesCount = Array.length(lines)
  switch offset {
  | -1 => findHMirror(lines, offset + 1, corrections)
  | v if v >= linesCount - 1 => (0, 999)
  | offset =>
    switch checkHLine2(lines, offset, corrections) {
    | (true, v) if v == 0 => (offset + 1, v)
    | (_, v) => {
        let res = findHMirror(lines, offset + 1, corrections)
        res
      }
    }
  }
}

let u = Array.getUnsafe
let rotateArray = arr => {
  Array.mapWithIndex(u(arr, 0), (_, index) => {
    Array.map(arr, row => u(row, index))
  })
}

let rotateInput = arr => {
  arr
  ->Array.map(line => String.split(line, ""))
  ->rotateArray
  ->Array.map(line => Array.joinWith(line, ""))
}

let findMirrors = (text, corrections) => {
  String.split(text, "\n\n")
  ->Array.mapWithIndex((map, _index) => {
    let map = Aoc.toLinesEnd(map)

    let (a, _) = findHMirror(map, 0, corrections)
    let (b, _) = findHMirror(rotateInput(map), 0, corrections)
    Js.log3(_index, a, b)

    a * 100 + b
  })
  ->Array.reduce(0, \"+")
}

// Js.log2("Example Part 1:", findMirrors(await Aoc.readInput("inputs/d13-example.aoc"), 0))
// Js.log2("Input Part 1:", findMirrors(await Aoc.readInput("inputs/d13-input.aoc"), 0))

// Js.log2("Example Part 2:", findMirrors(await Aoc.readInput("inputs/d13-example.aoc"), 1))
// Js.log2("Input Part 2:", findMirrors(await Aoc.readInput("inputs/d13-input.aoc"), 1))
Js.log2("Input Part 2:", findMirrors(await Aoc.readInput("inputs/d13-bram.aoc"), 0))
