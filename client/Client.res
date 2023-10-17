open Webapi
open Webapi.Dom

let pageInfoElem = Document.getElementById(Webapi.Dom.document, "pageInfo")
let pagePropsElem = Document.getElementById(Webapi.Dom.document, "pageProps")

let root = switch Document.getElementById(Webapi.Dom.document, "app") {
| Some(elem) => elem
| None => raise(Not_found)
}

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

let pageInfo = switch pageInfoElem {
| Some(elem) => Element.textContent(elem)->Js.Json.parseExn->parse
| None => raise(Not_found)
}

let pageProps = switch pagePropsElem {
| Some(elem) => Element.textContent(elem)->Js.Json.parseExn
| None => Js.Json.null
}

Js.log(pageProps)

let currentComponent = Preact.Signals.make(React.null)

switch pageInfo {
| Ok(pageInfo) =>
  switch await Page.render(pageInfo["src"], false, Some(pageProps)) {
  | Some((pageElement, _)) => Preact.hydrate(pageElement, root)
  | None => raise(Not_found)
  }
| _ => raise(Not_found)
}

let socket = WebSocket.make("ws://localhost:3000/")

socket->WebSocket.addOpenListener(_ => {
  Js.log("Socket  open")
  switch Js.Json.stringifyAny(Some({"e": "ping"})) {
  | Some(str) => WebSocket.sendText(socket, str)
  | None => ()
  }
})
