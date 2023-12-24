type t = (float, float)

let make = (x: float, y: float): t => {
  (x, y)
}

let fromInt = ((x, y)): t => {
  (Float.fromInt(x), Float.fromInt(y))
}

let toInt = ((x, y)) => {
  (Float.toInt(x), Float.toInt(y))
}

let add = ((v1x, v1y): t, (v2x, v2y): t) => {
  (v1x +. v2x, v1y +. v2y)
}

let sub = ((v1x, v1y): t, (v2x, v2y): t) => {
  (v1x -. v2x, v1y -. v2y)
}

let mul = ((v1x, v1y): t, (v2x, v2y): t) => {
  (v1x -. v2x, v1y -. v2y)
}

let div = ((v1x, v1y): t, (v2x, v2y): t) => {
  (v1x /. v2x, v1y /. v2y)
}

let mod = ((v1x, v1y): t, (v2x, v2y): t) => {
  (Float.mod(v1x, v2x), Float.mod(v1y, v2y))
}

let equals = ((v1x, v1y): t, (v2x, v2y): t) => {
  v1x == v2x && v1y == v2y
}

let adds = ((vx, vy), scalar: float) => {
  (vx +. scalar, vy +. scalar)
}

let muls = ((vx, vy), scalar: float) => {
  (vx *. scalar, vy *. scalar)
}

let divs = ((vx, vy), scalar: float) => {
  (vx /. scalar, vy /. scalar)
}

let subs = ((vx, vy), scalar: float) => {
  (vx -. scalar, vy -. scalar)
}

let exp = (point1: t, point2: t) => {
  let _ = point1
  let _ = point2

  %raw(`[point1[0] ** point2[0], point1[1] ** point2[0]]`)
}

let magnitude = ((x, y): t) => {
  sqrt(x *. x +. y *. y)
}

let distance = (point1: t, point2: t) => {
  let (aX, aY) = point1
  let (bX, bY) = point2

  sqrt(Math.pow(aX -. bX, ~exp=2.0) +. Math.pow(aY -. bY, ~exp=2.0))
}

let length = magnitude

let normalize = ((x, y): t) => {
  let m = magnitude((x, y))
  (x /. m, y /. m)
}

let \"+" = add
let \"-" = sub
let \"*" = mul
let \"/" = div
