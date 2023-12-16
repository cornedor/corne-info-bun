let input =
  (await Aoc.readInput("inputs/d16-input.aoc"))
  ->Aoc.toLinesEnd
  ->Array.map(line => Aoc.splitStringList(line, ~delimiter=""))

// Array.forEach(input, a => Js.log(a))

type tile = MirrorTopRight | MirrorTopLeft | SplitterHorizontal | SplitterVertical | Air

@genType
let map = Array.map(input, line =>
  Array.map(line, char =>
    switch char {
    | "." => Air
    | "-" => SplitterHorizontal
    | "|" => SplitterVertical
    | "\\" => MirrorTopRight
    | "/" => MirrorTopLeft
    | c => panic("Character " ++ c ++ " is not valid")
    }
  )
)

@genType
let energized = Array.map(input, line => Array.map(line, _ => false))

type xy = (int, int)

let energize = ((x, y): xy): int => {
  let line = energized[y]
  switch line {
  | Some(line) =>
    switch line[x] {
    | Some(current) if current == true => -1
    | Some(_) => {
        line[x] = true
        1
      }
    | None => -1
    }
  | None => -10000
  }
}

let getTile = ((x, y): xy): option<tile> => {
  switch map[y] {
  | Some(line) => line[x]
  | None => None
  }
}

let cache = Map.make()

let getCacheKey = ((x, y), (mx, my)) => {
  Int.toStringWithRadix(x, ~radix=36) ++
  ":" ++
  Int.toStringWithRadix(y, ~radix=36) ++
  ":" ++
  Int.toStringWithRadix(mx, ~radix=36) ++
  ":" ++
  Int.toStringWithRadix(my, ~radix=36)
}

@genType
let rec walkMap = (pos: xy, movement: xy, power: int) => {
  let cacheKey = getCacheKey(pos, movement)
  switch Map.get(cache, cacheKey) {
  | Some(cached) => cached
  | None => {
      let isEnergized = energize(pos)
      Map.set(cache, cacheKey, true)

      switch isEnergized {
      | v if power + v <= 0 => true
      | v =>
        let power = power + v
        switch getTile(pos) {
        | Some(tile) => {
            let (posX, posY) = pos
            let (movX, movY) = movement
            switch tile {
            | Air => walkMap((posX + movX, posY + movY), (movX, movY), power)
            | SplitterHorizontal if movY == 0 =>
              walkMap((posX + movX, posY + movY), (movX, movY), power)
            | SplitterVertical if movX == 0 =>
              walkMap((posX + movX, posY + movY), (movX, movY), power)
            | SplitterHorizontal =>
              let _ = walkMap((posX + 1, posY), (1, 0), power)
              walkMap((posX - 1, posY), (-1, 0), power)
            | SplitterVertical =>
              let _ = walkMap((posX, posY + 1), (0, 1), power)
              walkMap((posX, posY - 1), (0, -1), power)
            | MirrorTopRight => walkMap((posX + movY, posY + movX), (movY, movX), power)
            | MirrorTopLeft =>
              walkMap((posX + (0 - movY), posY + (0 - movX)), (0 - movY, 0 - movX), power)
            }
          }
        | None => true
        }
      }
    }
  }
}

@genType
let countEnergized = () => {
  Array.reduce(energized, 0, (acc, line) => acc + Array.length(Array.filter(line, item => item)))
}

// Console.time("start")
// // walkMap((0, 0), (1, 0), 1)
// let _ = walkMap((1, 0), (0, 1), 1, 0)

// Array.forEach(energized, item => Js.log(Array.joinWith(Array.map(item, o => o ? "#" : "."), "")))
// Js.log(
//   Array.reduce(energized, 0, (acc, line) => acc + Array.length(Array.filter(line, item => item))),
// )

// Console.timeEnd("start")
