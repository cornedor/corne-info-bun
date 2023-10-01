module Crate = {
  @react.component
  let make = (~tag: option<string>=?) =>
    <div className="aoc22-crate">
      {switch tag {
      | Some(tag) => React.string(tag)
      | None => React.string("?")
      }}
    </div>
}

module EmptySpace = {
  @react.component
  let make = () => <div className="aoc22-empty-space" />
}

module Stack = {
  @react.component
  let make = (~index: int, ~stack: DayFive.stack) => {
    let stackArr = Belt.List.toArray(stack)
    let crates = Belt.Array.mapWithIndex(stackArr, (i, tag) =>
      switch tag {
      | DayFive.Tag(tag) => <Crate key={Belt.Int.toString(i)} tag={tag} />
      | DayFive.Empty => <EmptySpace key={Belt.Int.toString(i)} />
      }
    )
    <div className="aoc22-stack">
      {React.array(crates)}
      <div className="aoc22-indicator"> {React.string(Belt.Int.toString(index))} </div>
    </div>
  }
}

module Button = {
  @react.component
  let make = (~children, ~onClick) =>
    <button
      type_="button"
      className="shadow-sm bg-amber-200 border-amber-400 border-2 px-2 py-1 text-black rounded hover:bg-amber-300 active:ring-2 focus:ring-2"
      onClick>
      children
    </button>
}

module Stacks = {
  @react.component
  let make = () => {
    let (version, setVersion) = React.useState(() => DayFive.CM9000)
    let (float, setFloat) = React.useState(() => true)
    let (step, setStep) = React.useState(() => 0)

    let lines = DayFiveInput.dataLines
    let steppedData = switch step {
    | 0 => lines
    | step => Belt.Array.slice(lines, ~offset=0, ~len=step)
    }

    let (stacks, instructions) = DayFive.initStacks(steppedData, version)
    let stackElems = Belt.Array.mapWithIndex(stacks, (i, stack) =>
      <Stack index={i + 1} key={Belt.Int.toString(i)} stack={stack} />
    )

    let instructionElems = Belt.List.mapWithIndex(instructions, (index, instruction) =>
      <pre key={Belt.Int.toString(index)}>
        {switch instruction {
        | Move(amount, from, to_) =>
          React.string(
            `Move ${Belt.Int.toString(amount)} from ${Belt.Int.toString(
                from,
              )} to ${Belt.Int.toString(to_)}.`,
          )
        }}
      </pre>
    )
    <div>
      <Button
        onClick={_ => {
          setVersion(version => {
            switch version {
            | DayFive.CM9000 => DayFive.CM9001
            | DayFive.CM9001 => DayFive.CM9000
            }
          })
        }}>
        {React.string("Toggle version")}
      </Button>
      <span>
        {React.string(
          "Using version " ++
          switch version {
          | DayFive.CM9000 => "CrateMover 9000"
          | DayFive.CM9001 => "CrateMover 9001"
          },
        )}
      </span>
      <br />
      <Button
        onClick={_ => {
          setFloat(f => !f)
        }}>
        {React.string("Toggle floating crates")}
      </Button>
      <span> {React.string("Stepper (0 renders all steps): ")} </span>
      <Button
        onClick={_ => {
          setStep(s => Js_math.max_int(s - 1, 0))
        }}>
        {React.string("<--")}
      </Button>
      <span> {React.string(Belt.Int.toString(step))} </span>
      <Button
        onClick={_ => {
          setStep(s => s + 1)
        }}>
        {React.string("-->")}
      </Button>
      <div className={"aoc22-stacks" ++ (float ? " aoc22-floating" : "")}>
        {React.array(stackElems)}
      </div>
      <details>
        <summary> {React.string("Steps")} </summary>
        {React.array(Belt.List.toArray(instructionElems))}
      </details>
    </div>
  }
}
