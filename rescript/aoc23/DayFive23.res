type rangeMap = {
  name: string,
  destStart: float,
  sourceStart: float,
  sourceEnd: float,
  length: float,
}

let isInRange = (value: float, rangeMap: rangeMap) =>
  value >= rangeMap.sourceStart && value <= rangeMap.sourceEnd

let mapValue = (value: float, rangeMap: rangeMap) => {
  switch isInRange(value, rangeMap) {
  | true => value +. (rangeMap.destStart -. rangeMap.sourceStart)
  | false => value
  }
}

let lineToRangeMap = (name, line) => {
  let numbers = String.split(line, " ")->Array.map(line =>
    switch Belt.Float.fromString(line) {
    | Some(n) => n
    | None => panic(line ++ " container invalid chars")
    }
  )

  let (destStart, sourceStart, length) = switch numbers {
  | [destStart, sourceStart, length] => (destStart, sourceStart, length)
  | _ => (0.0, 0.0, 0.0)
  }

  {
    name,
    destStart,
    sourceStart,
    sourceEnd: sourceStart +. (length -. 1.0),
    length,
  }
}

let lineToSeedRange = line => {
  let numbers =
    String.replace(line, "seeds: ", "")
    ->String.split(" ")
    ->Array.map(line =>
      switch Belt.Float.fromString(line) {
      | Some(n) => n
      | None => panic(line ++ " contains invalid chars")
      }
    )

  let (rangeAStart, rangeALength, rangeBStart, rangeBLength) = switch numbers {
  | [a, b, c, d] => (a, b, c, d)
  | _ => (0.0, 0.0, 0.0, 0.0)
  }

  (rangeAStart, rangeALength, rangeBStart, rangeBLength)
}

let getSeeds = line =>
  line
  ->String.replace("seeds: ", "")
  ->String.split(" ")
  ->Array.map(chars =>
    switch Belt.Float.fromString(chars) {
    | Some(n) => n
    | _ => panic(chars ++ " is not a number")
    }
  )

type lineTypes = Name(string) | Range(string)

let getLineType = line => {
  switch line {
  | line if line == "" => None
  | line if String.endsWith(line, ":") => Some(Name(String.replace(line, " map:", "")))
  | line => Some(Range(line))
  }
}

let parseLines = lines => {
  let initMap: Map.t<string, array<rangeMap>> = Map.make()
  Array.map(lines, getLineType)->Array.reduce((initMap, ""), ((map, currentName), item) => {
    switch item {
    | Some(Name(name)) => {
        Map.set(map, name, [])
        (initMap, name)
      }
    | Some(Range(range)) => {
        let items = Map.get(map, currentName)
        switch items {
        | Some(items) =>
          Map.set(map, currentName, Array.concat(items, [lineToRangeMap(currentName, range)]))
        | None => Map.set(map, currentName, [lineToRangeMap(currentName, range)])
        }

        (map, currentName)
      }
    | _ => (map, currentName)
    }
  })
}

let order = [
  "seed-to-soil",
  "soil-to-fertilizer",
  "fertilizer-to-water",
  "water-to-light",
  "light-to-temperature",
  "temperature-to-humidity",
  "humidity-to-location",
]

let mapValues = (maps, seed) => {
  // Js.log3("======== seed", seed, " ========")
  Array.reduce(order, seed, (seed, key) => {
    // Js.log2("  -> ", key)
    switch Map.get(maps, key) {
    | Some(ranges) =>
      switch Array.find(ranges, range => isInRange(seed, range)) {
      | Some(range) => mapValue(seed, range)
      | _ => seed
      }
    | None => seed
    }
  })
}

let parseData = data => {
  let lines = String.split(data, "\n")

  let seedsLine = switch lines[0] {
  | Some(s) => s
  | None => ""
  }
  let mapLines = Array.sliceToEnd(lines, ~start=2)

  let seeds = getSeeds(seedsLine)
  let (maps, _) = parseLines(mapLines)

  let mappedSeeds = Array.map(seeds, v => mapValues(maps, v))

  let minPos = ref(99999999999.0)

  let chunks = [
    (2149186375.0, 163827995.0),
    (1217693442.0, 67424215.0),
    (365381741.0, 74637275.0),
    (1627905362.0, 77016740.0),
    (22956580.0, 60539394.0),
    (586585112.0, 391263016.0),
    (2740196667.0, 355728559.0),
    (2326609724.0, 132259842.0),
    (2479354214.0, 184627854.0),
    (3683286274.0, 337630529.0),
  ]

  Array.forEach(chunks, ((rangeStart, rangeLength)) => {
    Js.log2("Looping over this many items:", rangeLength)
    for seed in 0 to Belt.Int.fromFloat(rangeLength) {
      let seed = Belt.Float.fromInt(seed) +. rangeStart
      if seed < 0.0 {
        Js.log4(
          rangeStart,
          rangeLength,
          Belt.Int.fromFloat(rangeStart),
          Belt.Int.fromFloat(rangeLength),
        )
        panic("Seed below zero, integer overflow happend")
      }
      let val = mapValues(maps, seed)
      minPos := Math.min(val, minPos.contents)
    }
  })

  (seeds, maps, mappedSeeds, Math.minMany(mappedSeeds), minPos.contents)
}

// Js.log(parseData(DayFive23Input.exampleData))
Js.log(parseData(DayFive23Input.data))
