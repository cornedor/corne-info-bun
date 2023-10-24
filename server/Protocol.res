type request =
  | Ping
  | Prefetch({url: string})
  | Refetch({url: string})

type response =
  | Pong
  | PrefetchSource({src: string})
  | NoMatch
  | Match({src: string, pageProps: option<Js.Json.t>})

type pageInfo = {
  kind: Bun.matchedRouteKind,
  params: Js.Dict.t<string>,
  query: Js.Dict.t<string>,
  src: string,
}

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
    PrefetchSource({
      src: s.field("s", S.string),
    })
  }),
  S.object(s => {
    s.tag("<", "4")
    NoMatch
  }),
  S.object(s => {
    s.tag("<", "m")
    Match({
      src: s.field("s", S.string),
      pageProps: s.field("p", S.option(S.json)),
    })
  }),
])

let pageInfoStruct = S.object(s => {
  kind: s.field(
    "k",
    S.union([
      S.literal(#exact),
      S.literal(#"catch-all"),
      S.literal(#"optional-catch-all"),
      S.literal(#dynamic),
    ]),
  ),
  params: s.field("p", S.dict(S.string)),
  query: s.field("q", S.dict(S.string)),
  src: s.field("s", S.string),
})

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
