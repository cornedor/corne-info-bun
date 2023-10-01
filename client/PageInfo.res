let parse = json => {
  open JsonCombinators.Json
  decode(
    json,
    Decode.object(field =>
      {
        "kind": field.required("kind", Decode.string),
        "query": field.required("query", Decode.dict(Decode.string)),
        "params": field.required("query", Decode.dict(Decode.string)),
        "src": field.required("src", Decode.string),
      }
    ),
  )
}

let a = "b"
