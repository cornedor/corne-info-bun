open Aoc

let parts = Map.fromArray([
  ("|", ((0, -1), (0, 1), "┃")),
  ("-", ((-1, 0), (1, 0), "━")),
  ("L", ((0, -1), (1, 0), "┗")),
  ("J", ((0, -1), (-1, 0), "┛")),
  ("F", ((0, 1), (1, 0), "┏")),
  ("7", ((0, 1), (-1, 0), "┓")),
])

let pathParts = ["┃", "┗", "┛"]
let skipParts = ["┓", "┏", "━", "S"]

let isPrevious = ((x1, y1), (x2, y2), (x3, y3)) => {
  x2 + x3 == x1 && y2 + y3 == y1
}

let rec step = (charAtPos, posToIndex, previousPos, currentPos, count, mod) => {
  let (x, y) = currentPos
  let currentPart = charAtPos(x, y)
  let ((movX, movY), c) = switch Map.get(parts, currentPart) {
  | Some((d1, d2, c)) if isPrevious(previousPos, currentPos, d1) => (d2, c)
  | Some((d1, _, c)) => (d1, c)
  | None => panic("Left the pipe")
  }
  let (nextX, nextY) = (x + movX, y + movY)

  mod[posToIndex(x, y)] = c

  switch charAtPos(nextX, nextY) {
  | "S" => (count, mod)
  | _ => step(charAtPos, posToIndex, currentPos, (nextX, nextY), count +. 0.5, mod)
  }
}

let countLoop = str => {
  let lineWidth = String.indexOf(str, "\n") + 1

  let posFromIndex = posFromIndex(lineWidth, ...)
  let posToIndex = posToIndex(lineWidth, ...)
  let charAtPosStr = charAtPos(str, lineWidth, ...)

  let (x1, y1) = posFromIndex(String.indexOf(str, "S"))

  let (steps, map) = step(
    charAtPosStr,
    posToIndex,
    (x1, y1),
    (x1 + 1, y1),
    1.0,
    String.split(str, ""),
  )

  let combinedMap = String.replace(Array.joinWith(map, ""), "┓�┗", "┓┗")
  let height = String.length(str) / lineWidth
  let charAtPosFin = charAtPos(combinedMap, lineWidth, ...)

  let insideCount = ref(0)
  for y in 0 to height - 1 {
    let isInside = ref(false)
    for x in 0 to lineWidth - 2 {
      let char = charAtPosFin(x, y)
      let isPathPart = Array.includes(pathParts, char)
      let isSkipPart = Array.includes(skipParts, char)

      switch (isPathPart, isSkipPart) {
      | (true, _) => isInside := !isInside.contents
      | (false, true) => isInside := isInside.contents
      | (false, false) if isInside.contents => insideCount := insideCount.contents + 1
      | (false, false) => insideCount := insideCount.contents
      }
    }
  }

  Js.log(combinedMap)
  Js.log2("Outside steps", steps)
  Js.log2("Inside count", insideCount.contents)
}

let _ = countLoop(await Aoc.readInput("inputs/d10-input.aoc"))
let _ = countLoop(await Aoc.readInput("inputs/d10-example2.aoc"))
