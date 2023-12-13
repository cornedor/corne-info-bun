Js.log("AoC 2023, Day 12, attempt 2")

type check = (int, int)
type checkList = List.t<check>
type maskType = [#unknown | #must | #not]
type mask = array<maskType>

// --- Debugging utils
let makeString = (length, fill) => Array.make(~length, fill)->Array.joinWith("")
let printCheck = (numbers: checkList) => {
  let (offset, length) = List.reverse(numbers)->List.headExn
  let length = offset + length
  let str = ref(makeString(length, "_"))
  List.forEach(numbers, ((offset, length)) => {
    let p = makeString(length, "#")
    let head = String.slice(str.contents, ~start=0, ~end=offset)
    let tail = String.sliceToEnd(str.contents, ~start=offset + length)
    str := head ++ p ++ tail
  })
  str.contents
}
let printMask = (mask: mask) =>
  Array.map(mask, p =>
    switch p {
    | #unknown => "?"
    | #must => "#"
    | #not => "."
    }
  )->Array.joinWith("")

// Function that settles the checks in their initial positions
let settleInitialPositions = (sizes): checkList => {
  let (_, res) = sizes->Array.reduce((0, list{}), ((step, settled), item) => {
    (step + item + 1, list{...settled, (step, item)})
  })
  res
}

Aoc.logList2("settleInitialPositions", settleInitialPositions([3, 1, 1]))

let parseMask = (str): mask => {
  String.split(str, "")->Array.map(char =>
    switch char {
    | "?" => #unknown
    | "#" => #must
    | "." => #not
    | _ => #unknown
    }
  )
}

// This function checks if a check is allowed in its position using the mask.
let allowedByMask = (startAt: int, (pos, width): check, mask: mask, lookForward: bool) => {
  // Js.log((pos, width))
  // Js.log4(printMask(mask), printCheck(list{(pos, width)}), startAt, lookForward)
  let res = !Array.someWithIndex(mask, (item, i) => {
    let isInRange = i >= pos && i < pos + width
    let isPastRange = i > pos + width

    let leftOfRange = pos == i + 1
    let rightOfRange = pos + width == i

    // Js.log2(isInRange, isPastRange)

    switch item {
    | _ if pos + width > Array.length(mask) => true
    | _ if i < startAt => false
    | #must if leftOfRange => true
    | #must if rightOfRange => true
    | #must if isPastRange && !lookForward => false
    | #must => !isInRange
    | #not if isInRange => true
    | #not => false
    | #unknown => false
    }
  })

  // Js.log2("////", res)

  res
}

Js.log2("allowedByMask", allowedByMask(0, (0, 3), parseMask("###.????.###"), true))
Js.log2("allowedByMask", allowedByMask(0, (0, 3), parseMask("###.????.###"), false))
Js.log2("allowedByMask", allowedByMask(6, (9, 3), parseMask("###.????.###"), true))

let getRestWidth = (checks: checkList): int => {
  List.reduce(checks, 0, (total, (_, w)) => total + w + 1)
}

Js.log2("getRestWidth", getRestWidth(list{(1, 1), (1, 2)}))
Js.log("")

// Main recursive loop
let rec findMatches = (
  checks: checkList,
  mask: mask,
  maskWidth: int,
  startAt: int,
  cache: Map.t<string, float>,
): float => {
  let cacheKey = printCheck(checks)

  let result = switch Map.get(cache, cacheKey) {
  | Some(cached) => cached
  | None =>
    // Js.log2(cache, cacheKey)
    // Js.log2(printMask(mask), startAt)
    switch checks {
    | list{} => 0.0
    | list{(pos, width)} if pos + width > maskWidth =>
      allowedByMask(startAt, (pos, width), mask, true) ? 1.0 : 0.0
    | list{(pos, width)} => {
        let togo = maskWidth - pos + width
        let counter = ref(0.0)
        for x in 0 to togo {
          let movedPos = (pos + x, width)
          counter := counter.contents +. (allowedByMask(startAt, movedPos, mask, true) ? 1.0 : 0.0)
        }
        counter.contents
      }
    | list{(pos, width), ...rest} => {
        let togo = maskWidth - (getRestWidth(rest) - 1) - width - 1

        let counter = ref(0.0)
        for x in 0 to togo {
          let movedPos = (pos + x, width)
          counter :=
            counter.contents +.
            switch allowedByMask(startAt, movedPos, mask, false) {
            | true => {
                let movedRest = List.map(rest, ((p, w)) => (p + x, w))
                findMatches(movedRest, mask, maskWidth, pos + x + width + 1, cache)
              }
            | false => 0.0
            }
        }
        counter.contents
      }
    }
  }

  Map.set(cache, cacheKey, result)

  result
}

let exampleData = await Bun.file(~path="./inputs/d12-example.aoc")->Bun.BunFile.text

let checkInput = (text, unfold) => {
  text
  ->Aoc.toLinesEnd
  ->Array.map(item => Aoc.splitStringList(item))
  ->Array.map(slice => {
    switch (slice, unfold) {
    | ([mask, check], false) => {
        let mask = parseMask(mask)
        let check = Aoc.splitIntList(check, ~delimiter=",")
        let cache: Map.t<string, float> = Map.make()
        findMatches(settleInitialPositions(check), mask, Array.length(mask), 0, cache)
      }
    | ([mask, check], true) => {
        let mask = Array.joinWith([mask, mask, mask, mask, mask], "?")
        let mask = parseMask(mask)
        let check = Array.joinWith([check, check, check, check, check], ",")
        let check = Aoc.splitIntList(check, ~delimiter=",")
        let cache: Map.t<string, float> = Map.make()
        let res = findMatches(settleInitialPositions(check), mask, Array.length(mask), 0, cache)

        // Js.log2("Result!", res)
        res
      }
    | _ => panic("Incorrect input")
    }
  })
  ->Array.reduce(0.0, \"+.")
}

Js.log(checkInput(exampleData, true))
