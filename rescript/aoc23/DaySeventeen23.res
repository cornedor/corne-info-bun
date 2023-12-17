let input = await Aoc.readInput("inputs/d17-input.aoc")
let lines = input->Aoc.toLinesEnd
let cleaned = lines->Array.joinWith("")
let lineLength = Array.getUnsafe(lines, 0)->String.length

type nodeKey = string

// type edge = {key: nodeKey, weight: int}
type direction = (int, int)
type position = (int, int)

type graph = {
  nodes: array<nodeKey>,
  neighbours: Map.t<nodeKey, array<(position, int, direction)>>,
}

type weight = float
type time = int
type hr = int
type queue = (hr, position, weight, direction)

let generateNodeKey = (x, y) => `${Int.toString(x)},${Int.toString(y)}`

let addNode = (graph, node) => {
  Array.push(graph.nodes, node)
  Map.set(graph.neighbours, node, [])
}

let addEdge = (graph, nodeA, nodeB, weight, directionA, _directionB) => {
  switch Map.get(graph.neighbours, nodeA) {
  | None => ()
  | Some(m) => Array.push(m, (nodeB, weight, directionA))
  }
}

let createEmptyGraph = () => {
  let graph: graph = {
    nodes: [],
    neighbours: Map.make(),
  }

  graph
}

let enqueue = (queue: array<queue>, item: queue) => {
  let (hr, _, _, _) = item
  switch Array.findIndexOpt(queue, ((cHr, _, _, _)) => cHr > hr) {
  | None => Array.push(queue, item)
  | Some(index) => Array.splice(queue, ~start=index, ~remove=0, ~insert=[item])
  }
}

let neighbourOffsets = [(-1, 0), (0, -1), (0, 1), (1, 0)]
let inputToGraph = (input, lineLength) => {
  let graph = createEmptyGraph()
  let charAtPos = Aoc.charAtPos(input, lineLength, ...)
  let height = String.length(input) / lineLength
  for y in 0 to height - 1 {
    let str = ref("")
    for x in 0 to lineLength - 1 {
      str := str.contents ++ charAtPos(x, y)
      let nodeKey = generateNodeKey(x, y)
      addNode(graph, nodeKey)
      Array.forEach(neighbourOffsets, ((offsetX, offsetY)) => {
        let nX = x + offsetX
        let nY = y + offsetY
        let inBounds = nX >= 0 && nY >= 0 && nX < lineLength && nY < height

        if inBounds {
          addEdge(
            graph,
            nodeKey,
            (nX, nY),
            charAtPos(nX, nY)->Int.fromString->Aoc.ensureSome,
            (offsetX, offsetY),
            (offsetX, offsetY),
          )
        }
      })
    }
  }

  graph
}

let stepCacheKey = (((posX, posY), _weight, (dirX, dirY))) => {
  open Int
  `${toString(posX)},${toString(posY)}/${toString(dirX)},${toString(dirY)}`
}

let findPath = (graph: graph, startNode, (endX, endY), maxi, mini) => {
  let priorityQueue: array<queue> = []
  let times = Map.make()
  let visited = Set.make()

  enqueue(priorityQueue, (0, startNode, 0.0, (1, 0)))
  enqueue(priorityQueue, (0, startNode, 0.0, (0, 1)))

  let failsafe = ref(100000000)
  let break = ref(true)
  let res = ref(0.0)

  while Array.length(priorityQueue) > 0 && failsafe.contents > 0 && break.contents {
    failsafe := failsafe.contents - 1
    let (_, node, weight, (stepX, stepY)) = Array.shift(priorityQueue)->Aoc.ensureSome
    let stepSize = max(abs(stepX), abs(stepY))

    switch node {
    | (nodeX, nodeY) if nodeX == endX && nodeY == endY && stepSize > mini => {
        // Js.log3("Found the end!!!", weight, stepSize)
        break := false
        res := weight
      }
    | (nodeX, nodeY) =>
      switch Map.get(graph.neighbours, generateNodeKey(nodeX, nodeY)) {
      | None => panic("Could not found neighbours, check your graph")
      | Some(neighbours) =>
        let valid = Array.filterMap(neighbours, (((posX, posY), weight, (dirX, dirY))) => {
          let newDirX = stepX * abs(dirX) + dirX
          let newDirY = stepY * abs(dirY) + dirY

          let isSameDirection = abs(stepX) == 0 && abs(dirX) == 0
          let isPastMaxSteps = abs(newDirX) > maxi || abs(newDirY) > maxi
          let isBeforeMinSteps = (abs(newDirX) < mini || abs(newDirY) < mini) && isSameDirection

          let isOutOfBounds = newDirX < 0 && newDirY < 0 && newDirX > endX && newDirY > endY

          let isTheOpposites = dirX * stepX < 0 || dirY * stepY < 0

          isTheOpposites || isOutOfBounds || isPastMaxSteps || isBeforeMinSteps
            ? None
            : Some(((posX, posY), weight, (newDirX, newDirY)))
        })

        Array.forEach(valid, (((posX, posY), nodeWeight, (dirX, dirY))) => {
          let key = stepCacheKey(((posX, posY), nodeWeight, (dirX, dirY)))

          if !Set.has(visited, key) {
            Set.add(visited, key)
            Map.set(times, key, weight +. Float.fromInt(nodeWeight))
            enqueue(
              priorityQueue,
              (
                Int.fromFloat(weight) + nodeWeight,
                (posX, posY),
                weight +. Float.fromInt(nodeWeight),
                (dirX, dirY),
              ),
            )
          }
        })
      }
    }
  }
  res.contents
}

let graph = inputToGraph(cleaned, lineLength)

let last = lineLength - 1
let lastKey = `${Int.toString(last)},${Int.toString(last)}`
Js.log2("Part 1:", findPath(graph, (0, 0), (last, last), 3, 0))
Js.log2("Part 2:", findPath(graph, (0, 0), (last, last), 10, 3))
