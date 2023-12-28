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

let settled = Array.reduce(input, [], (fallen, brick) => {
  Array.unshift(fallen, fall(brick, fallen))

  fallen->Array.sort(((_, (_, _, zA)), (_, (_, _, zB))) => Float.fromInt(zB - zA))
  fallen
})

let supportsMap: Belt.HashMap.t<CoordsHash.t, array<int>, CoordsHash.identity> = Belt.HashMap.make(
  ~id=module(CoordsHash),
  ~hintSize=Array.length(input),
)

let supportedByMap: Belt.HashMap.t<
  CoordsHash.t,
  array<int>,
  CoordsHash.identity,
> = Belt.HashMap.make(~id=module(CoordsHash), ~hintSize=Array.length(input))

Array.forEach(settled, brick => {
  let (pos, _) = brick
  Belt.HashMap.set(supportsMap, pos, [])
})

Array.forEach(settled, brick => {
  let ((x, y, z), _) = brick
  // The Z axis that is supporting the brick
  let supportingZ = z - 1

  let options = Array.filter(settled, brickB => {
    let (_pos, (_, _, upperZ)) = brickB
    upperZ == supportingZ && hasOverlap(brickB, brick)
  })

  Array.forEach(options, ((opt, _)) => {
    switch Belt.HashMap.get(supportedByMap, (x, y, z)) {
    | None => Belt.HashMap.set(supportedByMap, (x, y, z), [hash(opt)])
    | Some(arr) => Belt.HashMap.set(supportedByMap, (x, y, z), Array.concat(arr, [hash(opt)]))
    }
    switch Belt.HashMap.get(supportsMap, opt) {
    | None => Belt.HashMap.set(supportsMap, opt, [hash((x, y, z))])
    | Some(arr) => Belt.HashMap.set(supportsMap, opt, Array.concat(arr, [hash((x, y, z))]))
    }
  })
})

let values = Belt.HashMap.valuesToArray(supportsMap)->Array.flat
let reverseLookup = Map.make()
let totalRemovableBricks = Belt.HashMap.reduce(supportsMap, 0, (acc, key, value) => {
  Map.set(reverseLookup, hash(key), key)
  let unique = Array.map(value, h => {
    Array.filter(values, v => v == h)->Array.length - 1
  })->Array.every(v => v > 0)

  // If not supporting anything, we can always remove it
  let empty = Array.length(value) == 0

  unique || empty ? acc + 1 : acc
})

let rec countDisintegrated = (coords, disintegrated, first) => {
  let isSupported =
    first ||
    switch Belt.HashMap.get(supportedByMap, coords) {
    // Is supported by the ground
    | None => true
    // Check if this brick is not supported by any other not disintegrated brick
    | Some(supportedBy) => Array.every(supportedBy, item => Set.has(disintegrated, item))
    }

  switch isSupported {
  | false => 0
  | true =>
    Set.add(disintegrated, hash(coords))
    switch Belt.HashMap.get(supportsMap, coords) {
    | None => 0
    | Some(children) =>
      Array.filterMap(children, child => Map.get(reverseLookup, child))
      ->Array.map(a => {
        countDisintegrated(a, disintegrated, false)
      })
      ->Array.reduce(0, \"+")
    }
  }
}

let totalDisintegrated = Array.map(settled, brick => {
  let (pos, _) = brick
  let disintegrated = Set.make()
  let _ = countDisintegrated(pos, disintegrated, true)

  Set.size(disintegrated) - 1
})->Array.reduce(0, \"+")

Js.log2("Part 1", totalRemovableBricks)
Js.log2("Part 2", totalDisintegrated)
