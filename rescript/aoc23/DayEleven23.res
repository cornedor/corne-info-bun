let generateOffsetMaps = (dots, growSize) => {
  let vSlice = Array.map(dots, line => Array.some(line, item => item) ? 1 : growSize)
  // let hSlice = Array.map(dots, line => Array.some(line, item => item))

  let head = Aoc.ensureSome(dots[0])
  let hSlice = Array.make(~length=0, 1)
  for x in 0 to Array.length(head) - 1 {
    let found = ref(growSize)
    for y in 0 to Array.length(dots) - 1 {
      if Aoc.ensureSome(Aoc.ensureSome(dots[y])[x]) {
        found := 1
      }
    }
    Array.push(hSlice, found.contents)
  }

  let em: Belt.Map.Int.t<int> = Belt.Map.Int.empty

  let (_, toVMap, fromVMap) = Array.reduceWithIndex(vSlice, (0, em, em), (
    (sum, map, mapb),
    item,
    index,
  ) => {
    (sum + item, Belt.Map.Int.set(map, index, sum), Belt.Map.Int.set(mapb, sum, index))
  })

  let (_, toHMap, fromHMap) = Array.reduceWithIndex(hSlice, (0, em, em), (
    (sum, map, mapb),
    item,
    index,
  ) => {
    (sum + item, Belt.Map.Int.set(map, index, sum), Belt.Map.Int.set(mapb, sum, index))
  })

  (
    (v: int) => Belt.Map.Int.getExn(toVMap, v),
    (v: int) => Belt.Map.Int.getExn(fromVMap, v),
    (v: int) => Belt.Map.Int.getExn(toHMap, v),
    (v: int) => Belt.Map.Int.getExn(fromHMap, v),
  )
}

type star = {
  x: int,
  y: int,
}

let findStars = (toVMap, toHMap, dots) => {
  // let stars = Array.make(~length=0, {x: 0, y: 0})
  Array.mapWithIndex(dots, (line, y) =>
    Array.mapWithIndex(line, (point, x) => {
      switch point {
      | true => Some({x: toHMap(x), y: toVMap(y)})
      | _ => None
      }
    })->Array.filterMap(item => item)
  )->Array.flatMap(item => item)
}

let rec sumDistances = stars => {
  switch stars {
  | list{} => BigInt.fromInt(0)
  | list{_} => BigInt.fromInt(0)
  | list{star, ...rest} =>
    List.reduce(rest, sumDistances(rest), (sum, step) => {
      BigInt.add(sum, BigInt.fromInt(abs(step.x - star.x) + abs(step.y - star.y)))
    })
  }
}

let findConnections = (lines, growSize) => {
  let dots = Array.map(lines, line => String.split(line, "")->Array.map(char => char == "#"))
  let (toVMap, _fromVMap, toHMap, _fromHMap) = generateOffsetMaps(dots, growSize)
  let stars = findStars(toVMap, toHMap, dots)->List.fromArray

  let sum = sumDistances(stars)

  Js.log(sum)
}

(await Aoc.readInput("./inputs/d11-input.aoc"))->Aoc.toLinesEnd->findConnections(2)
(await Aoc.readInput("./inputs/d11-input.aoc"))->Aoc.toLinesEnd->findConnections(1000000)
