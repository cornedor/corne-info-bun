let getElfCallories = () => {
  let data = Js.Array.sortInPlaceWith(
    (a, b) => b - a,
    DayOneInput.data
    ->Js.String2.split("\n\n")
    ->Js.Array2.map(elf => {
      Js.Array.reduce(
        \"+",
        0,
        elf
        ->Js.String2.split("\n")
        ->Js.Array2.map(
          item => {
            let value = Belt.Int.fromString(item)
            switch value {
            | Some(v) => v
            | None => 0
            }
          },
        ),
      )
    }),
  )

  data
}

let getMostCalloriesElf = () => {
  getElfCallories()[0]
}

let getThreeMostCalloriesElf = () => {
  let result = getElfCallories()

  Js.Array2.unsafe_get(result, 0) +
  Js.Array2.unsafe_get(result, 1) +
  Js.Array2.unsafe_get(result, 2)
}
