type card = {
  cardType: string,
  value: int,
}

type handType =
  | FiveOfAKind(string)
  | FourOfAKind(string)
  | FullHouse(string, string)
  | ThreeOfAKind(string)
  | TwoPair(string, string)
  | OnePair(string)
  | HighCard

type hand = {
  cardsStr: string,
  bid: int,
  cards: (card, card, card, card, card),
  handType: handType,
  typeRank: int,
}

let letters = ["A", "K", "Q", "J", "T"]

let failoverCard = {
  cardType: "Invalid",
  value: 0,
}
let failoverCards = (failoverCard, failoverCard, failoverCard, failoverCard, failoverCard)

let getHandTypeRank = handType =>
  switch handType {
  | FiveOfAKind(_) => 0
  | FourOfAKind(_) => 1
  | FullHouse(_) => 2
  | ThreeOfAKind(_) => 3
  | TwoPair(_) => 4
  | OnePair(_) => 5
  | HighCard => 6
  }

let getHandType = cards => {
  let ofAKinds =
    cards
    ->Array.filter(card => card.cardType != "J")
    ->Array.map(card => {
      (card.cardType, Array.filter(cards, b => b.cardType == card.cardType)->Array.length)
    })
    ->Array.filter(((_, count)) => count != 1)

  let jokers = Array.filter(cards, b => b.cardType == "J")->Array.length

  let fiveOfAKind = Array.find(ofAKinds, ((_, count)) => count == 5)
  let fourOfAKind = Array.find(ofAKinds, ((_, count)) => count == 4)
  let threeOfAKind = Array.find(ofAKinds, ((_, count)) => count == 3)
  let twoKinds =
    Array.filter(ofAKinds, ((_, count)) => count == 2)
    ->Array.reduce(Belt.Map.String.empty, (map, (key, count)) =>
      Belt.Map.String.set(map, key, count)
    )
    ->Belt.Map.String.toArray

  let (twoOfAKindA, twoOfAKindB) = switch twoKinds {
  | [a, b] => (Some(a), Some(b))
  | [a] => (Some(a), None)
  | _ => (None, None)
  }

  switch (fiveOfAKind, fourOfAKind, threeOfAKind, twoOfAKindA, twoOfAKindB) {
  | (Some((card, _)), _, _, _, _) => FiveOfAKind(card)
  | (None, Some((card, _)), _, _, _) if jokers == 1 => FiveOfAKind(card)
  | (None, Some((card, _)), _, _, _) => FourOfAKind(card)
  | (None, None, Some((card, _)), None, _) if jokers == 2 => FiveOfAKind(card)
  | (None, None, Some((card, _)), None, _) if jokers == 1 => FourOfAKind(card)
  | (None, None, Some((card, _)), None, _) => ThreeOfAKind(card)
  | (None, None, Some((cardA, _)), Some((cardB, _)), _) => FullHouse(cardA, cardB)
  | (None, None, None, Some((cardA, _)), Some((_, _))) if jokers == 2 => FourOfAKind(cardA)
  | (None, None, None, Some((cardA, _)), Some((cardB, _))) if jokers == 1 => FullHouse(cardA, cardB)
  | (None, None, None, Some((cardA, _)), Some((cardB, _))) => TwoPair(cardA, cardB)
  | (None, None, None, Some((card, _)), None) if jokers >= 1 =>
    switch jokers {
    | 1 => ThreeOfAKind(card)
    | 2 => FourOfAKind(card)
    | 3 => FiveOfAKind(card)
    | _ => panic("Programming error")
    }
  | (None, None, None, Some((card, _)), None) | (None, None, None, None, Some((card, _))) =>
    OnePair(card)
  | (None, None, None, None, None) if jokers >= 1 =>
    switch jokers {
    | 1 => OnePair("J")
    | 2 => ThreeOfAKind("J")
    | 3 => FourOfAKind("J")
    | 4 => FiveOfAKind("J")
    | 5 => FiveOfAKind("J")
    | _ => panic("Programming error")
    }
  | (None, None, None, None, None) => HighCard
  }
}

let getCards = str => {
  switch String.split(str, "")->Array.map(char =>
    switch char {
    | "A" | "K" | "Q" | "J" | "T" => {
        cardType: char,
        value: switch char {
        | "J" => 0
        | _ => 14 - Array.indexOf(letters, char)
        },
      }
    | c if Belt.Int.fromString(c) != None => {
        let value = switch Belt.Int.fromString(c) {
        | Some(n) => n
        | None => 0
        }

        {
          cardType: c,
          value,
        }
      }
    | _ => panic("Invalid card")
    }
  ) {
  | [a, b, c, d, e] => (a, b, c, d, e)
  | _ => failoverCards
  }
}

let getBid = bid =>
  switch Belt.Int.fromString(bid) {
  | Some(n) => n
  | None => 0
  }

let comp = (handA: hand, handB: hand) => {
  let (a1, a2, a3, a4, a5) = handA.cards
  let (b1, b2, b3, b4, b5) = handB.cards

  let diff = switch (
    a1.value == b1.value,
    a2.value == b2.value,
    a3.value == b3.value,
    a4.value == b4.value,
    a5.value == b5.value,
  ) {
  | (false, _, _, _, _) => b1.value - a1.value
  | (true, false, _, _, _) => b2.value - a2.value
  | (true, true, false, _, _) => b3.value - a3.value
  | (true, true, true, false, _) => b4.value - a4.value
  | (true, true, true, true, false) => b5.value - a5.value
  | (true, true, true, true, true) => 0
  }

  Float.fromInt(diff)
}

let cardsTupleToArray = ((a, b, c, d, e)) => [a, b, c, d, e]
let emptyMap: Belt.Map.Int.t<array<hand>> = Belt.Map.Int.empty
let parseInput = async path => {
  let text = await Bun.file(~path)->Bun.BunFile.text
  let lines = String.split(text, "\n")
  lines
  ->Array.map(line =>
    switch String.split(line, " ") {
    | [cardsStr, bid] => {
        let cards = getCards(cardsStr)
        let handType = getHandType(cardsTupleToArray(cards))

        {
          cardsStr,
          cards,
          bid: getBid(bid),
          handType,
          typeRank: getHandTypeRank(handType),
        }
      }
    | _ => {
        cardsStr: "INVALID",
        cards: failoverCards,
        bid: 0,
        handType: HighCard,
        typeRank: 0,
      }
    }
  )
  ->Array.filter(item => item.bid != 0)
  ->Array.reduce(emptyMap, (mapped, item) => {
    Belt.Map.Int.set(
      mapped,
      item.typeRank,
      switch Belt.Map.Int.get(mapped, item.typeRank) {
      | Some(items) => Array.concat(items, [item])
      | None => [item]
      },
    )
  })
  ->Belt.Map.Int.reduce([], (all, _, range) => {
    Array.concat(all, Array.toSorted(range, comp))
  })
  ->Array.toReversed
  // ->Array.map(item => {
  //   Js.log(item.cardsStr)
  //   item
  // })
  ->Array.reduceWithIndex(0, (total, item, index) => total + item.bid * (index + 1))
}

Js.log(await parseInput("./inputs/d7-example.aoc"))
Js.log(await parseInput("./inputs/d7-input.aoc"))
