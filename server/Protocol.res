type request =
  | Ping
  | Prefetch({url: string})
  | Refetch({url: string})

type response =
  | Pong
  | Prefetched({data: Js.Json.t})
  | NoMatch
  | Match({data: Js.Json.t})

let requestStruct = S.union([
  S.object(s => {
    s.tag(">", "p")
    Ping
  }),
  S.object(s => {
    s.tag(">", "r")
    Prefetch({
      url: s.field("url", S.string),
    })
  }),
  S.object(s => {
    s.tag(">", "f")
    Refetch({
      url: s.field("url", S.string),
    })
  }),
])

let responseStruct = S.union([
  S.object(s => {
    s.tag("<", "p")
    Pong
  }),
  S.object(s => {
    s.tag("<", "r")
    Prefetched({
      data: s.field("data", S.json),
    })
  }),
  S.object(s => {
    s.tag("<", "4")
    NoMatch
  }),
  S.object(s => {
    s.tag("<", "m")
    Match({
      data: s.field("data", S.json),
    })
  }),
])

let parseRequest = message => {
  S.parseJsonStringWith(message, requestStruct)
}

let parseResponse = message => {
  S.parseJsonStringWith(message, responseStruct)
}

let serializeRequest = data => {
  S.serializeToJsonStringWith(data, requestStruct)
}

let serializeResponse = data => {
  S.serializeToJsonStringWith(data, responseStruct)
}
