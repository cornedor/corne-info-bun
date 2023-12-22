type pulse = High | Low
type pulseMap = Map.t<string, pulse>
type part =
  | Broadcaster(list<string>)
  | FlipFlop(bool, list<string>)
  | Conjunction(pulseMap, list<string>)

type rec node<'t> = {
  children: array<node<'t>>,
  parent: option<node<'t>>,
  item: 't,
}

// State and metadata
let state = Map.make()
let conjunctionParents = Map.make()

let updateFlipFlopState = (pulse: pulse, part: part) => {
  switch (pulse, part) {
  | (High, FlipFlop(state, parts)) => FlipFlop(state, parts)
  | (Low, FlipFlop(state, parts)) => FlipFlop(!state, parts)
  | _ => part
  }
}

let parseLine = line => {
  switch String.split(line, " -> ") {
  | [part, parts] => {
      let parts = List.fromArray(Aoc.splitStringList(parts, ~delimiter=","))
      let t = String.slice(part, ~start=0, ~end=1)
      let name = String.sliceToEnd(part, ~start=1)

      switch t {
      | "%" => (name, FlipFlop(false, parts))
      | "&" => (name, Conjunction(Map.make(), parts))
      | "b" => ("broadcaster", Broadcaster(parts))
      | _ => panic("Invalid part: " ++ line)
      }
    }
  | _ => panic("Invalid line: " ++ line)
  }
}

let parts =
  (await Aoc.readInput("inputs/d20-input.aoc"))
  ->Aoc.toLinesEnd
  ->Array.map(parseLine)
  ->Map.fromArray

Map.forEachWithKey(parts, (part, key) => {
  let _ = Map.set(state, key, Low)

  switch part {
  | Conjunction(_, _) => Map.set(conjunctionParents, key, [])
  | _ => ()
  }
})

Map.forEachWithKey(parts, (part, key) => {
  let parts = switch part {
  | Conjunction(_, parts) => parts
  | Broadcaster(parts) => parts
  | FlipFlop(_, parts) => parts
  }

  List.forEach(parts, childKey => {
    switch Map.get(conjunctionParents, childKey) {
    | Some(cur) => Array.push(cur, key)
    | None => ()
    }
  })
})

let queue = []
let lowSent = ref(0.0)
let highSent = ref(0.0)

let countPulses = (pulse: pulse, amount: int) => {
  switch pulse {
  | High => highSent := highSent.contents +. Float.fromInt(amount)
  | Low => lowSent := lowSent.contents +. Float.fromInt(amount)
  }
}

let loop = Map.fromArray([("gs", 0), ("kd", 0), ("vg", 0), ("zf", 0)])

let runStep = (name, pulse: pulse, _from, pushes) => {
  // Js.log4(_from ++ " -", pulse, "->", name)
  let r = switch (name, Map.get(parts, name)) {
  | (name, None) if name == "output" => Js.log2("DEBUG:", pulse)
  | (name, None) if name == "rx" =>
    switch pulse {
    | High => ()
    | Low => Js.log2("Got em!", pushes)
    }
  | (name, None) => panic("Part not found in Map: " ++ name)
  | (_, Some(Broadcaster(children))) => {
      countPulses(pulse, List.length(children))
      children->List.forEach(child => Array.push(queue, (child, pulse, name)))
    }
  | (_, Some(FlipFlop(_, children))) => {
      let currentState = Map.get(state, name)->Aoc.ensureSome
      let newPulse = switch pulse {
      | High => currentState
      | Low => currentState == Low ? High : Low
      }
      if newPulse != currentState {
        Map.set(state, name, newPulse)
        children->List.forEach(child => {
          countPulses(newPulse, 1)
          Array.push(queue, (child, newPulse, name))
        })
      }
    }
  | (_, Some(Conjunction(_, children))) => {
      let parents =
        Map.get(conjunctionParents, name)->Option.getExn->Array.map(k => Map.get(state, k))
      let someLow = parents->Array.some(b => b == Some(Low))
      let newPulse = someLow ? High : Low
      Map.set(state, name, newPulse)
      // children->List.forEach(child => runStep(child, newPulse, name))
      children->List.forEach(child => {
        countPulses(newPulse, 1)
        Array.push(queue, (child, newPulse, name))
      })
    }
  }

  switch _from {
  | "gs" | "kd" | "vg" | "zf" =>
    switch pulse {
    | High =>
      if Map.get(loop, _from)->Option.getExn < 3000 {
        Map.set(loop, _from, pushes)
      }
    | Low => ()
    }
  | _ => ()
  }

  r
}

Console.time("Loop")

let i = ref(0)
while i.contents < 100000 {
  i := i.contents + 1

  runStep("broadcaster", Low, "button", i.contents)
  lowSent := lowSent.contents +. 1.0
  while Array.length(queue) > 0 {
    let (child, pulse, name) = Array.shift(queue)->Option.getExn
    runStep(child, pulse, name, i.contents)
  }

  if i.contents == 1000 {
    Js.log2("Part 1:", highSent.contents *. lowSent.contents)
  }

  if !(Map.values(loop)->Core__Iterator.toArray->Array.some(item => item == 0)) {
    i := 100001

    let loopValues =
      Map.values(loop)->Core__Iterator.toArray->Array.map(BigInt.fromInt)->List.fromArray
    Js.log2("Part 2:", Aoc.lcmMany(loopValues))
  }
}

Console.timeEnd("Loop")
