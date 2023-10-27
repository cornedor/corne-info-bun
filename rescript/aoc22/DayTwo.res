type hand = Rock | Paper | Scissor
let isHandWinning = ((oponent, yours)) => {
  switch oponent {
  | Rock => yours === Paper
  | Paper => yours === Scissor
  | Scissor => yours === Rock
  }
}

let isDraw = ((oponent, yours): (hand, hand)) => oponent === yours

let handScore = hand => {
  let base = switch hand {
  | (_, Rock) => 1
  | (_, Paper) => 2
  | (_, Scissor) => 3
  }

  switch (isDraw(hand), isHandWinning(hand)) {
  | (true, _) => base + 3
  | (false, true) => base + 6
  | (false, false) => base + 0
  }
}

exception Invalid_Token

let tokenToHand = token => {
  switch token {
  | "A" => Rock
  | "X" => Rock
  | "B" => Paper
  | "Y" => Paper
  | "C" => Scissor
  | "Z" => Scissor
  | _ => raise(Invalid_Token)
  }
}

let convertWinStatusToHand = hand => {
  switch hand {
  | (Rock, Rock) => (Rock, Scissor) // Lose
  | (Rock, Paper) => (Rock, Rock) // Draw
  | (Rock, Scissor) => (Rock, Paper) // Win
  | (Paper, Rock) => (Paper, Rock)
  | (Paper, Paper) => (Paper, Paper)
  | (Paper, Scissor) => (Paper, Scissor)
  | (Scissor, Rock) => (Scissor, Paper)
  | (Scissor, Paper) => (Scissor, Scissor)
  | (Scissor, Scissor) => (Scissor, Rock)
  }
}

let calculateStrategyScore = () => {
  Js.String2.split(DayTwoInput.data, "\n")
  ->Js.Array2.map(round => {
    let tokens = round->Js.String2.split(" ")
    let hand = (
      tokenToHand(Js.Array2.unsafe_get(tokens, 0)),
      tokenToHand(Js.Array2.unsafe_get(tokens, 1)),
    )

    let score = handScore(hand)

    score
  })
  ->Js.Array2.reduce(\"+", 0)
}

let calculateStrategyScore2 = () => {
  DayTwoInput.data
  ->Js.String2.split("\n")
  ->Js.Array2.map(round => {
    let tokens = round->Js.String2.split(" ")
    let winStatus = (
      tokenToHand(Js.Array2.unsafe_get(tokens, 1)),
      tokenToHand(Js.Array2.unsafe_get(tokens, 1)),
    )
    // Convert win statuses to hands first in this version of the solution
    let hand = convertWinStatusToHand(winStatus)

    let score = handScore(hand)

    score
  })
  ->Js.Array2.reduce(\"+", 0)
}
