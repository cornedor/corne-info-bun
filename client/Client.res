open Webapi
open Webapi.Dom

let pageInfo = switch Render.pageInfoElem {
| Some(elem) => Element.textContent(elem)->S.parseJsonStringWith(Protocol.pageInfoStruct)
| None => raise(Not_found)
}

let pageProps = switch Render.pagePropsElem {
| Some(elem) => {
    let json = Element.textContent(elem)->Js.Json.parseExn
    Element.remove(elem)
    json
  }
| None => Js.Json.null
}

switch pageInfo {
| Ok(pageInfo) =>
  switch await Page.render(pageInfo.src, false, Some(pageProps)) {
  | Some((pageElement, _)) => Render.hydratePage(pageElement)
  | None => raise(Not_found)
  }
| _ => raise(Not_found)
}

external toStr: Js.Json.t => string = "%identity"
let refetchCurrentPage = () => {
  open Protocol
  let href = Dom.Location.href(Dom.location)
  switch serializeRequest(Refetch({url: href})) {
  | Ok(payload) => WebSocket.sendText(Socket.socket, payload)
  | _ => Js.log("Err")
  }
}
Dom.Window.addPopStateEventListener(Dom.window, _ => {
  refetchCurrentPage()
})

external castToCustomEvent: Dom.Event.t => Link.EventWithDetail.t = "%identity"
Dom.Window.addEventListener(Dom.window, "_s_p", evt => {
  open Protocol
  let customEvent = castToCustomEvent(evt)->Link.EventWithDetail.detail

  switch serializeRequest(Prefetch({url: customEvent.href})) {
  | Ok(payload) => WebSocket.sendText(Socket.socket, payload)
  | _ => Js.log("Err")
  }
})

Dom.Window.addEventListener(Dom.window, "_s_l", evt => {
  open Protocol
  let customEvent = castToCustomEvent(evt)->Link.EventWithDetail.detail

  switch serializeRequest(Refetch({url: customEvent.href})) {
  | Ok(payload) => WebSocket.sendText(Socket.socket, payload)
  | _ => Js.log("Err")
  }
})
