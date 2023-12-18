type direction = [#R | #D | #L | #U]
type instruction = {direction: direction, steps: int, stepsB: Vector2D.t}

Console.time("Initialisation")
let instructions =
  (await Aoc.readInput("inputs/d18-input.aoc"))
  ->Aoc.toLinesEnd
  ->Array.map(line =>
    switch String.split(line, " ") {
    | [dir, steps, color] => {
        let color = color->String.replace("(#", "")->String.replace(")", "")

        let dist = String.slice(color, ~start=0, ~end=-1)->Aoc.parseIntWithRadix(16)->Float.fromInt
        let dirb = switch String.sliceToEnd(color, ~start=5) {
        | "0" => (dist, 0.0)
        | "1" => (0.0, dist)
        | "2" => (0.0 -. dist, 0.0)
        | "3" => (0.0, 0.0 -. dist)
        | _ => panic("Invalid direction")
        }

        {
          direction: switch dir {
          | "R" => #R
          | "L" => #L
          | "U" => #U
          | "D" => #D
          | _ => panic("Invalid direction")
          },
          steps: Int.fromString(steps)->Aoc.ensureSomeM("Steps is not a number"),
          stepsB: dirb,
        }
      }
    | _ => panic("Invalid input")
    }
  )
  ->List.fromArray

Console.timeEnd("Initialisation")
Console.time("Part 1")
let grid = Grid2D.make(~hintSize=700)

let drawLine = (instruction, x, y, grid) => {
  switch instruction {
  | {direction: #R, steps} =>
    for step in 0 to steps {
      Grid2D.set(grid, (x + step, y), true)
    }
    (x + steps, y)
  | {direction: #L, steps} =>
    for step in 0 to steps {
      Grid2D.set(grid, (x - step, y), true)
    }
    (x - steps, y)
  | {direction: #U, steps} =>
    for step in 0 to steps {
      Grid2D.set(grid, (x, y - step), true)
    }
    (x, y - steps)
  | {direction: #D, steps} =>
    for step in 0 to steps {
      Grid2D.set(grid, (x, y + step), true)
    }
    (x, y + steps)
  }
}

let rec walkOutline = (instructions, x, y, grid) => {
  switch instructions {
  | list{} => grid
  | list{head} =>
    let _ = drawLine(head, x, y, grid)
    grid
  | list{head, ...rest} => {
      let (x, y) = drawLine(head, x, y, grid)
      walkOutline(rest, x, y, grid)
    }
  }
}

let fill = (grid, x, y) => {
  let stack = [(x, y)]

  while Array.length(stack) > 0 {
    let (x, y) = Array.pop(stack)->Aoc.ensureSome
    switch Grid2D.get(grid, (x, y))->Option.getWithDefault(false) {
    | true => ()
    | false => {
        Grid2D.set(grid, (x, y), true)
        Array.push(stack, (x + 1, y))
        Array.push(stack, (x - 1, y))
        Array.push(stack, (x, y + 1))
        Array.push(stack, (x, y - 1))
      }
    }
  }
}

let _ = walkOutline(instructions, 0, 0, grid)
fill(grid, 1, 1)

// Draw map
// let ((minX, minY), (maxX, maxY)) = Grid2D.getBounds(grid)
// for y in minY to maxY {
//   let line = ref("")
//   for x in minX to maxX {
//     let char = Grid2D.get(grid, (x, y))->Option.getWithDefault(false) ? "#" : "."
//     line := line.contents ++ char
//   }
//   Js.log(line.contents)
// }

Console.timeEnd("Part 1")
Js.log2("Result:", Array.length(Grid2D.values(grid)))
// Part 2
Console.time("Part 2")

let polygon = []
let rec buildPolygon = (instructions: List.t<instruction>, current: Vector2D.t) => {
  switch instructions {
  | list{} => ()
  | list{head} => {
      let newVec = Vector2D.add(current, head.stepsB)
      Array.push(polygon, newVec)
    }

  | list{head, ...rest} => {
      let newVec = Vector2D.add(current, head.stepsB)
      Array.push(polygon, newVec)
      buildPolygon(rest, newVec)
    }
  }
}

buildPolygon(instructions, (0.0, 0.0))
// To print a svg polygon:
// Js.log(Array.map(polygon, ((x, y)) => (x /. 1000.0, y /. 1000.0))->Array.joinWith(" "))

let polygonPoints = Array.length(polygon)
let x = []
let y = []
for p in 0 to polygonPoints - 1 {
  let i2 = Int.mod(p + 1, polygonPoints)
  let (x1, _) = Array.getUnsafe(polygon, Int.mod(p, polygonPoints))
  let (_, y2) = Array.getUnsafe(polygon, i2)

  Array.push(x, x1 *. y2)
}

for p in 1 to polygonPoints {
  let i2 = Int.mod(p - 1, polygonPoints)
  let (x1, _) = Array.getUnsafe(polygon, Int.mod(p, polygonPoints))
  let (_, y2) = Array.getUnsafe(polygon, i2)

  Array.push(y, x1 *. y2)
}
let x = Array.reduce(x, 0.0, \"+.")
let y = Array.reduce(y, 0.0, \"+.")
let s = Aoc.abs(x -. y)
let area = s /. 2.0

// We calculated the area of the trench, but we dig a trench one width...
let (outline, _) = Array.reduce(polygon, (0.0, (0.0, 0.0)), ((acc, last), cur) => {
  (acc +. Vector2D.distance(last, cur), cur)
})
// add 0.5 for each block + 1 for each corner
let trenchOffset = outline /. 2.0 +. 1.0

Console.timeEnd("Part 2")
Js.log2("Result 2:", area +. trenchOffset)
