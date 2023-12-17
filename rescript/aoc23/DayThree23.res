let exampleData = await Bun.file(~path="./inputs/d3-example.aoc")->Bun.BunFile.text
let data = await Bun.file(~path="./inputs/d3-input.aoc")->Bun.BunFile.text

type partType = Gear(int) | Unkown(string)
type enginePart = {
  number: string,
  hasSymbol: bool,
  symbols: array<option<partType>>,
  x: int,
  y: int,
  width: int,
}

type gridItem = Empty | Part(enginePart) | Symbol(partType) | UnprocessedPart(string)

let getItemAt = (data, index) => {
  let char = String.charAt(data, index)
  switch char {
  | "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" => UnprocessedPart(char)
  | "." | "\n" | "" => Empty
  | "*" => Symbol(Gear(index))
  | s => Symbol(Unkown(s))
  }
}

let getAdjecentSymbols = (data, x, y, lineWidth) => {
  Aoc.adjecent->Array.map(((offsetX, offsetY)) => {
    let x = x + offsetX
    let y = y + offsetY
    let index = x + y * lineWidth
    switch getItemAt(data, index) {
    | Symbol(symbol) => Some(symbol)
    | _ => None
    }
  })
}

let rec findNextPart = (data, index, lineWidth) => {
  switch getItemAt(data, index) {
  | UnprocessedPart(char) => {
      let x = mod(index, lineWidth)
      let y = index / lineWidth

      // Engine part number only seem to be 3 long
      let continuingPart = switch findNextPart(data, index + 1, lineWidth) {
      | Part(part) => Some(part)
      | _ => None
      }

      let adjecentSymbols = Array.filter(getAdjecentSymbols(data, x, y, lineWidth), symbol =>
        switch symbol {
        | Some(_) => true
        | None => false
        }
      )

      let hasSymbolAdjecent = Array.some(adjecentSymbols, symbol =>
        switch symbol {
        | Some(_) => true
        | None => false
        }
      )

      switch continuingPart {
      | Some(continuingPart) =>
        // let number = char + continuingPart.number
        let symbols = Array.concat(adjecentSymbols, continuingPart.symbols)->Array.reduce([], (
          filtered,
          current,
        ) => {
          switch current {
          | Some(Gear(index)) => {
              let included = Array.some(filtered, item =>
                switch item {
                | Some(Gear(subIndex)) => subIndex == index
                | _ => false
                }
              )
              included ? filtered : Array.concat(filtered, [Some(Gear(index))])
            }
          | _ => filtered
          }
        })
        Part({
          number: char ++ continuingPart.number,
          hasSymbol: hasSymbolAdjecent || continuingPart.hasSymbol,
          x,
          y,
          width: 1 + continuingPart.width,
          symbols,
        })
      | None =>
        Part({
          number: char,
          hasSymbol: hasSymbolAdjecent,
          x,
          y,
          width: 1,
          symbols: adjecentSymbols,
        })
      }
    }
  | Empty => Empty
  | Symbol(s) => Symbol(s)
  | Part(part) => Part(part)
  }
}

let rec findAllParts = (data, index, lineWidth) => {
  switch String.length(data) - index {
  | -1 => []
  | _ =>
    switch findNextPart(data, index, lineWidth) {
    | Part(part) => Array.concat([part], findAllParts(data, index + part.width, lineWidth))
    | _ => findAllParts(data, index + 1, lineWidth)
    }
  }
}

let buildGrid = data => {
  let lines = String.split(data, "\n")
  let lineWidth = switch lines[0] {
  | Some(line) => String.length(line) + 1
  | None => 0
  }

  findAllParts(data, 0, lineWidth)
}

let getPartsWithSymbol = data =>
  data
  ->buildGrid
  ->Array.filter(part => part.hasSymbol)
  ->Array.reduce(0, (total, part) => {
    switch Int.fromString(part.number) {
    | Some(number) => total + number
    | None => total
    }
  })

let runExample1 = () => getPartsWithSymbol(exampleData)
let runPart1 = () => getPartsWithSymbol(data)

let setGearInMap = (gears, id, part) => {
  switch Belt.Map.Int.get(gears, id) {
  | Some(arr) => Belt.Map.Int.set(gears, id, Array.concat(arr, [part]))
  | None => Belt.Map.Int.set(gears, id, [part])
  }
}
let getGears = (data: array<enginePart>) => {
  let allGears = Array.reduce(data, Belt.Map.Int.empty, (gears, part) => {
    Array.reduce(part.symbols, gears, (gears, symbol) => {
      switch symbol {
      | Some(Gear(id)) => setGearInMap(gears, id, part)
      | _ => gears
      }
    })
  })

  Belt.Map.Int.reduce(allGears, 0, (total, _, gears) => {
    // Gears are only used when there are two parts connected
    switch Array.length(gears) > 1 {
    | true => {
        let gearTotal = Array.reduce(gears, 1, (acc, g) => {
          switch Belt.Int.fromString(g.number) {
          | Some(n) => acc * n
          | _ => acc
          }
        })

        total + gearTotal
      }
    | false => total
    }
  })
}

let runExample2 = () => buildGrid(exampleData)->getGears
let runPart2 = () => buildGrid(data)->getGears
