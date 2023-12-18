type t

type polygon = {points: array<Point2D.t>}

let make = () => {
  {points: []}
}

let push = (polygon: polygon, point: Point2D.t) => {
  Array.push(polygon.points, point)
}

let size = (polygon: polygon) => {
  Array.length(polygon.points)
}

// Calculate the area of the polygon using the shoelace method
let area = (polygon: polygon) => {
  let points = polygon.points
  let len = size(polygon)
  let a = ref(0.0)
  let b = ref(0.0)
  for p in 0 to len - 1 {
    let i2 = Int.mod(p + 1, len)
    let (x1, _) = Array.getUnsafe(points, Int.mod(p, len))
    let (_, y2) = Array.getUnsafe(points, i2)

    a := a.contents +. x1 *. y2
  }
  for p in 1 to len {
    let i2 = Int.mod(p - 1, len)
    let (x1, _) = Array.getUnsafe(points, Int.mod(p, len))
    let (_, y2) = Array.getUnsafe(points, i2)

    b := b.contents +. x1 *. y2
  }

  let area = (a.contents -. b.contents) /. 2.0

  area
}

let circumference = (polygon: polygon) => {
  let (length, _) = switch Array.at(polygon.points, -1) {
  | Some(end) =>
    Array.reduce(polygon.points, (0.0, end), ((acc, last), cur) => {
      (acc +. Point2D.distance(last, cur), cur)
    })
  | None => panic("No points in polygon")
  }
  length
}

let bounds = (polygon: polygon) => {
  let xs = Array.map(polygon.points, ((x, _)) => x)
  let ys = Array.map(polygon.points, ((_, y)) => y)

  let minPoint = Point2D.make(Math.minMany(xs), Math.minMany(ys))
  let maxPoint = Point2D.make(Math.maxMany(xs), Math.maxMany(ys))

  (minPoint, maxPoint)
}
