open Webapi

let socket = WebSocket.make(Dom.Location.origin(Dom.location)->String.replace("http", "ws"))

socket->WebSocket.addOpenListener(_ => {
  open Protocol
  Js.log("Socket open")

  switch serializeRequest(Ping) {
  | Ok(data) => WebSocket.sendText(socket, data)
  | _ => ()
  }
})

external castToStr: Js.Json.t => string = "%identity"

socket->WebSocket.addMessageListener(event => {
  open Protocol

  switch parseResponse(castToStr(event.data)) {
  | Ok(Pong) => Js.log("Pong! Connection works")
  | Ok(PrefetchSource({src})) => {
      let _ = Page.importPage(src)
    }
  | Ok(Match({src, pageProps})) =>
    let _ = Page.render(src, false, pageProps)->Promise.then(r =>
      Promise.resolve(
        switch r {
        | Some((pageElement, _)) =>
          let _ = Render.renderPage(pageElement)
        | None => {
            Js.log(r)
            raise(Not_found)
          }
        },
      )
    )
  | Ok(n) => Js.log2("Not implemented", n)
  | Error(err) => Js.log2("Error", err)
  }
})
