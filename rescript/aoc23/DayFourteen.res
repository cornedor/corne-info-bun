let moveItemY = (arr, index, direction) => {
  switch arr[index + direction] {
  | Some(old) => {
      Array.setUnsafe(arr, index + direction, Array.getUnsafe(arr, index))
      Array.setUnsafe(arr, index, old)
    }

  | _ => ()
  }
  arr
}

let moveItemX = (arr, indexA, indexB, direction) => {
  switch arr[indexA + direction] {
  | Some(row) => {
      let old = Array.getUnsafe(row, indexB)
      let sourceRow = Array.getUnsafe(arr, indexA)
      Array.setUnsafe(row, indexB, Array.getUnsafe(sourceRow, indexB))
      Array.setUnsafe(sourceRow, indexB, old)
    }
  | _ => ()
  }
  arr
}

let grid =
  (await Aoc.readInput("inputs/d14-example.aoc"))
  ->Aoc.toLinesEnd
  ->Array.map(line => Aoc.splitStringList(line, ~delimiter=""))

let moveForward = grid => {
  grid->Array.forEach(line => {
    let fb = ref(0)
    let changed = ref(true)

    while changed.contents {
      changed := false
      let hasToMove = ref(false)
      for x in 0 to Array.length(line) - 1 {
        switch Array.getUnsafe(line, x) {
        | "." => hasToMove := true
        | "#" => hasToMove := false
        | "O" if hasToMove.contents => {
            let _ = moveItemY(line, x, -1)
            changed := true
          }
        | "O" => hasToMove := false
        | v => panic("Unknown char " ++ v)
        }
      }

      fb := fb.contents + 1
    }
  })
}

let results: array<int> = []
let gridRef = ref(grid)
for _loop in 0 to 10000 {
  let grid = gridRef.contents
  // North
  let grid = Aoc.transposeArray(grid)
  moveForward(grid)
  let grid = Aoc.transposeArray(grid)

  // Array.forEach(grid, line => Js.log(Array.joinWith(line, "")))
  // Js.log("")

  // West
  moveForward(grid)
  // Array.forEach(grid, line => Js.log(Array.joinWith(line, "")))
  // Js.log("")

  // South
  Array.reverse(grid)
  let grid = Aoc.transposeArray(grid)
  moveForward(grid)
  let grid = Aoc.transposeArray(grid)
  Array.reverse(grid)
  // Array.forEach(grid, line => Js.log(Array.joinWith(line, "")))
  // Js.log("")

  let grid = Aoc.transposeArray(grid)
  Array.reverse(grid)
  let grid = Aoc.transposeArray(grid)
  moveForward(grid)
  let grid = Aoc.transposeArray(grid)
  Array.reverse(grid)

  let res = Array.reduce(grid, 0, (acc, line) => {
    let lineLen = Array.length(line)
    acc +
    Array.reduceWithIndex(line, 0, (acc, item, index) => {
      acc +
      switch item {
      | "O" => lineLen - index
      | _ => 0
      }
    })
  })

  if Array.length(Array.filter(results, i => i == res)) < 20 {
    // Js.log2("Loop", res)
    Array.push(results, res)
  }
  let grid = Aoc.transposeArray(grid)
  // Array.forEach(grid, line => Js.log(Array.joinWith(line, "")))
  // Js.log(loop)

  let str = Array.joinWith(results, "g")
  // Js.log(str)
  switch Re.exec(RegExp.fromString("(.+?)(g?\\1)+"), str) {
  | Some(r) => {
      let m = Array.find(Re.Result.matches(r), item => String.length(item) > 3)
      switch m {
      | Some(m) => Js.log(m)
      | None => ()
      }
    }
  | None => ()
  }

  gridRef := grid
}

Js.log(Array.joinWith(results, ":"))

let grid = gridRef.contents

// Array.reverse(grid)

// Js.log(
//   Array.reduce(grid, 0, (acc, line) => {
//     let lineLen = Array.length(line)
//     acc +
//     Array.reduceWithIndex(line, 0, (acc, item, index) => {
//       acc +
//       switch item {
//       | "O" => lineLen - index
//       | _ => 0
//       }
//     })
//   }),
// )
