type card = {
  id: int,
  winningNumbers: array<int>,
  myNumbers: array<int>,
}

let getMatches = card => {
  let hasNumber = mine => Array.some(card.winningNumbers, n => n == mine)
  Array.filter(card.myNumbers, number => hasNumber(number))
}

let countWinningNumbers = card => {
  let matches = getMatches(card)

  let points = switch Array.length(matches) {
  | 0 => 0.0
  | n => Math.pow(2.0, ~exp=Belt.Float.fromInt(n - 1))
  }

  Belt.Int.fromFloat(points)
}

let processCards = cards => {
  Array.map(cards, countWinningNumbers)->Array.reduce(0, (total, item) => total + item)
}

let rec countWinningCards = (cards, start, amount, dbg) => {
  Js.log(dbg)
  let slice = Array.slice(cards, ~start, ~end=start + amount)

  let copies = slice->Array.mapWithIndex((card, i) => {
    let matches = Array.length(getMatches(card))
    switch Array.length(slice) {
    | 0 => 0
    | _ =>
      countWinningCards(cards, start + i + 1, matches, dbg ++ " " ++ Int.toString(card.id) ++ " ->")
    }
  })
  Array.reduce(copies, 0, \"+") + Array.length(copies)
}

// Parsing data to a type

exception Invalid_data(string)

let splitNumbers = numbers => {
  String.trim(numbers)
  ->String.splitByRegExp(%re("/ +/"))
  ->Belt.Array.keepMap(part => part)
  ->Array.map(part =>
    switch Belt.Int.fromString(part) {
    | Some(n) => n
    | None => raise(Invalid_data(part))
    }
  )
}

exception Invalid_numbers(string)
let parseNumbers = numbers => {
  let (winning, mine) = switch String.split(numbers, "|") {
  | [winning, mine] => (winning, mine)
  | _ => ("", "")
  }

  (splitNumbers(winning), splitNumbers(mine))
}

let parseCardId = str =>
  switch String.replace(str, "Card ", "")->Belt.Int.fromString {
  | Some(n) => n
  | _ => 0
  }

let inputToCards = input =>
  String.split(input, "\n")->Array.map(line => {
    switch String.split(line, ": ") {
    | [card, numbers] => {
        let (winning, mine) = parseNumbers(numbers)
        {
          id: parseCardId(card),
          winningNumbers: winning,
          myNumbers: mine,
        }
      }
    | _ => raise(Invalid_data(line))
    }
  })

let runExample1 = () => inputToCards(DayFour23Input.exampleData)->processCards
let runPart1 = () => inputToCards(DayFour23Input.data)->processCards

let runExample2 = () => {
  let cards = inputToCards(DayFour23Input.exampleData)
  countWinningCards(cards, 0, Array.length(cards), "start ->")
}
let runPart2 = () => {
  let cards = inputToCards(DayFour23Input.data)
  countWinningCards(cards, 0, Array.length(cards), "start ->")
}
