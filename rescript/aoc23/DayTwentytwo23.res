type x = int
type y = int
type z = int
type coords = (x, y, z)
type brickSnapshot = (coords, coords)

let hash = ((x, y, z)) => {
  Int32.logor(Int32.logor(Int32.shift_left(x, 20), Int32.shift_left(y, 12)), z)->Int32.to_int
}

module CoordsHash = Belt.Id.MakeHashableU({
  type t = coords
  let hash = hash
  let eq = (a, b) => Pervasives.compare(a, b) == 0
})

let stringToCoords = (str): coords =>
  switch str->Aoc.splitStringList(~delimiter=",")->Array.map(c => Int.fromString(c)) {
  | [Some(x), Some(y), Some(z)] => (x, y, z)
  | _ => panic("Invalid coords")
  }

let makeBrickSnapshot = (line): brickSnapshot => {
  let (coordA, coordB) = switch line->Aoc.splitStringList(~delimiter="~") {
  | [a, b] => (a, b)
  | _ => panic("Invalid line")
  }
  (stringToCoords(coordA), stringToCoords(coordB))
}

let input =
  (await Aoc.readInput("./inputs/d22-input.aoc"))
  ->Aoc.toLinesEnd
  ->Array.map(makeBrickSnapshot)
  ->Array.toSorted((((_, _, zA), _), ((_, _, zB), _)) => Float.fromInt(zA - zB))

let hasOverlap = (brickA, brickB) => {
  let ((sXa, sYa, _), (eXa, eYa, _)) = brickA
  let ((sXb, sYb, _), (eXb, eYb, _)) = brickB

  max(sXa, sXb) <= min(eXa, eXb) && max(sYa, sYb) <= min(eYa, eYb)
}

let fall = (brick: brickSnapshot, below: array<brickSnapshot>) => {
  let ((sX, sY, sZ), (eX, eY, eZ)) = brick
  switch (sZ, below) {
  | (0, _) => brick
  | (z, []) => {
      let diff = 0 - z
      ((sX, sY, sZ + diff), (eX, eY, eZ + diff))
    }
  | (_, below) => {
      let hit = switch Array.find(below, item => hasOverlap(brick, item)) {
      | Some(v) => v
      | None => ((0, 0, 0), (0, 0, -1))
      }
      let (_, (_, _, z)) = hit
      let diff = eZ - sZ
      ((sX, sY, z + 1), (eX, eY, z + 1 + diff))
    }
  }
}

let fallen = Array.reduce(input, [], (fallen, brick) => {
  Array.unshift(fallen, fall(brick, fallen))

  fallen->Array.sort(((_, (_, _, zA)), (_, (_, _, zB))) => Float.fromInt(zB - zA))
  fallen
})

let map: Belt.HashMap.t<CoordsHash.t, array<int>, CoordsHash.identity> = Belt.HashMap.make(
  ~id=module(CoordsHash),
  ~hintSize=Array.length(input),
)

Array.forEach(fallen, brick => {
  let (pos, _) = brick
  Belt.HashMap.set(map, pos, [])
})

Array.forEach(fallen, brick => {
  let ((x, y, z), _) = brick
  // The Z axis that is supporting the brick
  let supportingZ = z - 1

  let options = Array.filter(fallen, brickB => {
    let (_pos, (_, _, upperZ)) = brickB
    upperZ == supportingZ && hasOverlap(brickB, brick)
  })

  Array.forEach(options, ((opt, _)) => {
    switch Belt.HashMap.get(map, opt) {
    | None => Belt.HashMap.set(map, opt, [hash((x, y, z))])
    | Some(arr) => Belt.HashMap.set(map, opt, Array.concat(arr, [hash((x, y, z))]))
    }
  })
})

let values = Belt.HashMap.valuesToArray(map)->Array.flat
let res = Belt.HashMap.reduce(map, 0, (acc, _key, value) => {
  let unique = Array.map(value, h => {
    Array.filter(values, v => v == h)->Array.length - 1
  })->Array.every(v => v > 0)

  // If not supporting anything, we can always remove it
  let empty = Array.length(value) == 0

  unique || empty ? acc + 1 : acc
})

Js.log2("Part 1", res)
