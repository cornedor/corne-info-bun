type t = (int, int)

let make = (x: int, y: int): t => {
  (x, y)
}

let add = ((v1x, v1y): t, (v2x, v2y): t) => {
  (v1x + v2x, v1y + v2y)
}

let sub = ((v1x, v1y): t, (v2x, v2y): t) => {
  (v1x - v2x, v1y - v2y)
}

let mul = ((v1x, v1y): t, (v2x, v2y): t) => {
  (v1x - v2x, v1y - v2y)
}

let div = ((v1x, v1y): t, (v2x, v2y): t) => {
  (v1x / v2x, v1y / v2y)
}

let mod = ((v1x, v1y): t, (v2x, v2y): t) => {
  (mod(v1x, v2x), mod(v1y, v2y))
}

let equals = ((v1x, v1y): t, (v2x, v2y): t) => {
  v1x == v2x && v1y == v2y
}

let adds = ((vx, vy), scalar: int) => {
  (vx + scalar, vy + scalar)
}

let muls = ((vx, vy), scalar: int) => {
  (vx * scalar, vy * scalar)
}

let divs = ((vx, vy), scalar: int) => {
  (vx / scalar, vy / scalar)
}

let subs = ((vx, vy), scalar: int) => {
  (vx - scalar, vy - scalar)
}

let exp = (vec1: t, vec2: t) => {
  let _ = vec1
  let _ = vec2

  %raw(`[vec1[0] ** vec2[0], vec1[1] ** vec2[0]]`)
}

let magnitude = ((x, y): t) => {
  sqrt(Int.toFloat(x * x + y * y))
}

let length = magnitude

let normalize = ((x, y): t) => {
  let m = magnitude((x, y))
  (Float.toInt(Float.fromInt(x) /. m), Float.toInt(Float.fromInt(y) /. m))
}

let \"+" = add
let \"-" = sub
let \"*" = mul
let \"/" = div
