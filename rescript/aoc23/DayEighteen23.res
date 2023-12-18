type direction = [#R | #D | #L | #U]
type instruction = {direction: direction, steps: int, color: string}

let instructions =
  (await Aoc.readInput("inputs/d18-input.aoc"))
  ->Aoc.toLinesEnd
  ->Array.map(line =>
    switch String.split(line, " ") {
    | [dir, steps, color] => {
        direction: switch dir {
        | "R" => #R
        | "L" => #L
        | "U" => #U
        | "D" => #D
        | _ => panic("Invalid direction")
        },
        steps: Int.fromString(steps)->Aoc.ensureSomeM("Steps is not a number"),
        color: color->String.replace("(", "")->String.replace(")", ""),
      }
    | _ => panic("Invalid input")
    }
  )
  ->List.fromArray

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

Js.log("")
Js.log("START")
Js.log("")

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
let ((minX, minY), (maxX, maxY)) = Grid2D.getBounds(grid)
for y in minY to maxY {
  let line = ref("")
  for x in minX to maxX {
    let char = Grid2D.get(grid, (x, y))->Option.getWithDefault(false) ? "#" : "."
    line := line.contents ++ char
  }
  Js.log(line.contents)
}

Js.log(Array.length(Grid2D.values(grid)))
