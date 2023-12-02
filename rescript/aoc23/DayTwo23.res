type round = {
  red: int,
  green: int,
  blue: int,
}

type game = {
  id: int,
  rounds: array<round>,
  highs: round,
  valid: bool,
}

let getColor = (colors, color) => {
  switch Array.find(colors, s => String.endsWith(s, color)) {
  | Some(str) =>
    switch str->String.replace(color, "")->String.trim->Belt.Int.fromString {
    | Some(count) => count
    | None => 0
    }
  | None => 0
  }
}

let parseData = data => {
  String.split(data, "\n")->Array.map(line => {
    let (id, rounds) = switch String.split(line, ": ") {
    | [id, rounds] => (id, rounds)
    | _ => ("", "")
    }
    let id = switch String.replace(id, "Game ", "")->Belt.Int.fromString {
    | Some(id) => id
    | None => 0
    }

    let rounds = String.split(rounds, ";")->Array.map(round => {
      let colors = String.split(round, ",")->Array.map(String.trim)
      let red = getColor(colors, "red")
      let green = getColor(colors, "green")
      let blue = getColor(colors, "blue")
      {
        red,
        green,
        blue,
      }
    })

    let highs = Array.reduce(rounds, {red: 0, green: 0, blue: 0}, (total, round) => {
      red: max(total.red, round.red),
      green: max(total.green, round.green),
      blue: max(total.blue, round.blue),
    })

    {
      id,
      rounds,
      highs,
      // only 12 red cubes, 13 green cubes, and 14 blue cubes
      valid: highs.red <= 12 && highs.green <= 13 && highs.blue <= 14,
    }
  })
}

let run1 = data => {
  let games = parseData(data)
  games->Array.filter(game => game.valid)->Array.reduce(0, (total, game) => total + game.id)
}

let run2 = data => {
  let games = parseData(data)

  games->Array.reduce(0, (total, {highs}) => {
    let power = highs.red * highs.green * highs.blue
    total + power
  })
}

let runExample1 = () => run1(DayTwo23Input.exampleData)
let runPart1 = () => run1(DayTwo23Input.data)

let runExample2 = () => run2(DayTwo23Input.exampleData)
let runPart2 = () => run2(DayTwo23Input.data)
