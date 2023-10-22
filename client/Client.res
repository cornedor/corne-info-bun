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

let socket = WebSocket.make("ws://" ++ Dom.Location.host(Dom.location) ++ ":3000/")

socket->WebSocket.addOpenListener(_ => {
  open Protocol
  Js.log("Socket  open")

  switch serializeRequest(Ping) {
  | Ok(data) => WebSocket.sendText(socket, data)
  | _ => ()
  }
})

external toStr: Js.Json.t => string = "%identity"
let refetchCurrentPage = () => {
  open Protocol
  let href = Dom.Location.href(Dom.location)
  switch serializeRequest(Refetch({url: href})) {
  | Ok(payload) => WebSocket.sendText(socket, payload)
  | _ => Js.log("Err")
  }
}
Dom.Window.addPopStateEventListener(Dom.window, _ => {
  refetchCurrentPage()
})

socket->WebSocket.addMessageListener(event => {
  open Protocol

  switch parseResponse(toStr(event.data)) {
  | Ok(Pong) => Js.log("Pong! Connection works")
  | Ok(PrefetchSource({src})) => {
      let _ = Page.importPage(src)
    }
  | Ok(Match({src, pageProps})) =>
    let _ = Page.render(src, false, pageProps)->Promise.then(r =>
      Promise.resolve(
        switch r {
        | Some((pageElement, _)) =>
          let _ = Preact.hydrate(pageElement, root)
        | None => raise(Not_found)
        },
      )
    )
  | Ok(n) => Js.log2("Not implemented", n)
  | Error(err) => Js.log2("Error", err)
  }
})

// TODO: How to do events
external toCustomEvent: Dom.Event.t => Link.EventWithDetail.t = "%identity"
Dom.Window.addEventListener(Dom.window, "_s_p", evt => {
  open Protocol
  let customEvent = toCustomEvent(evt)->Link.EventWithDetail.detail

  switch serializeRequest(Prefetch({url: customEvent.href})) {
  | Ok(payload) => WebSocket.sendText(socket, payload)
  | _ => Js.log("Err")
  }
})

Dom.Window.addEventListener(Dom.window, "_s_l", evt => {
  open Protocol
  let customEvent = toCustomEvent(evt)->Link.EventWithDetail.detail

  switch serializeRequest(Refetch({url: customEvent.href})) {
  | Ok(payload) => WebSocket.sendText(socket, payload)
  | _ => Js.log("Err")
  }
})
