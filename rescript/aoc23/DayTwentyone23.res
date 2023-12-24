let grid = Grid2D.make()
let input =
  (await Aoc.readInput("inputs/d21-example.aoc"))
  ->Aoc.toLinesEnd
  ->Array.mapWithIndex((line, y) => {
    Aoc.splitStringList(~delimiter="", line)->Array.forEachWithIndex((item, x) => {
      Grid2D.set(grid, (x, y), item)
    })
  })

let isRock = pos => Grid2D.get(grid, pos)->Option.getUnsafe == "#"

let adjecent = [(-1, 0), (0, -1), (0, 1), (1, 0)]->Array.map(Point2D.fromInt)
let setStepAround = pos => {
  Array.map(adjecent, offset => {
    let pos = Point2D.add(pos->Point2D.fromInt, offset)->Point2D.toInt
    switch Grid2D.get(grid, pos) {
    // | Some(".") | Some("S") | None => Grid2D.set(grid, pos, "O")
    | Some(".") | Some("S") => Grid2D.set(grid, pos, "O")
    | _ => ()
    }
  })
}

let startPosition = Grid2D.locate(grid, (_, v) => {
  v == "S"
})->List.headExn

let _ = setStepAround(startPosition)

@genType
let doStep = () => {
  let ((minX, minY), (maxX, maxY)) = Grid2D.getBounds(grid)
  for y in minY to maxY {
    let line = ref("")
    for x in minX to maxX {
      let char = Grid2D.get(grid, (x, y))->Option.getWithDefault("?")
      line := line.contents ++ char
    }
    Js.log(line.contents)
  }

  let steps = Grid2D.locate(grid, (_, item) => item == "O")
  Js.log(Grid2D.locate(grid, (_, item) => item == "O")->List.length)
  List.forEach(steps, item => Grid2D.set(grid, item, "."))
  List.forEach(steps, item => setStepAround(item))

  grid
}

let main = async () => {
  for i in 1 to 64 {
    Console.clear()
    Console.log2("Step", i)

    let _ = doStep()

    await Aoc.wait(200)
  }
}

let _ = main()
