type t<'a>

@genType
type position = (int, int)
module PositionHash = Belt.Id.MakeHashableU({
  type t = position
  let hash = ((x, y)) => {
    Int32.logor(Int32.shift_left(x, 16)->Int32.to_int, y)
  }
  let eq = (a, b) => Pervasives.compare(a, b) == 0
})

type gridMap<'a> = Belt.HashMap.t<PositionHash.t, 'a, PositionHash.identity>

@genType
type grid<'a> = {
  width: option<int>,
  height: option<int>,
  map: gridMap<'a>,
  maxX: ref<int>,
  maxY: ref<int>,
  minX: ref<int>,
  minY: ref<int>,
}

let make = (type content, ~width: option<int>=None, ~height: option<int>=None, ~hintSize=10000) => {
  let map: Belt.HashMap.t<PositionHash.t, content, PositionHash.identity> = Belt.HashMap.make(
    ~id=module(PositionHash),
    ~hintSize,
  )

  {
    width,
    height,
    maxX: ref(0),
    maxY: ref(0),
    minX: ref(0),
    minY: ref(0),
    map,
  }
}

let set = (grid: grid<'a>, position: position, value: 'a) => {
  open Belt.HashMap
  let (x, y) = position
  switch (grid.height, grid.width) {
  | (None, None) => {
      grid.maxX := max(grid.maxX.contents, x)
      grid.maxY := max(grid.maxY.contents, y)
      grid.minX := min(grid.minX.contents, x)
      grid.minY := min(grid.minY.contents, y)
      set(grid.map, position, value)
    }
  | (Some(height), None) if y <= height && y >= 0 => {
      grid.maxX := max(grid.maxX.contents, x)
      grid.minX := min(grid.minX.contents, x)
      set(grid.map, position, value)
    }
  | (None, Some(width)) if x <= width && x >= 0 => {
      grid.maxY := max(grid.maxY.contents, y)
      grid.minY := min(grid.minY.contents, y)
      set(grid.map, position, value)
    }
  | (Some(height), Some(width)) if y <= height && x <= width => set(grid.map, position, value)
  // Out of bounds
  | (None, Some(_)) | (Some(_), None) | (Some(_), Some(_)) => ()
  }
}

let get = (grid: grid<'a>, position: position) => {
  open Belt.HashMap
  get(grid.map, position)
}

let width = (grid: grid<'a>) => {
  switch grid.width {
  | Some(width) => width
  | None => grid.maxX.contents
  }
}

let height = (grid: grid<'a>) => {
  switch grid.height {
  | Some(height) => height
  | None => grid.maxY.contents
  }
}

let getBounds = (grid: grid<'a>) => {
  ((grid.minX.contents, grid.minY.contents), (grid.maxX.contents, grid.maxY.contents))
}

let toArray = (grid: grid<'a>) => {
  Belt.HashMap.toArray(grid.map)
}

let values = (grid: grid<'a>) => {
  Belt.HashMap.valuesToArray(grid.map)
}

@genType
let forEach = (grid: grid<'a>, fn: ('key, 'value) => unit) => {
  Belt.HashMap.forEach(grid.map, fn)
}

let locate = (grid: grid<'a>, fn: ('key, 'value) => bool) => {
  Belt.HashMap.reduce(grid.map, list{}, (acc, key, value) => {
    switch fn(key, value) {
    | true => list{key, ...acc}
    | false => acc
    }
  })
}
