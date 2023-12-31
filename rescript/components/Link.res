open Webapi

module Detail = {
  type t = {href: string}
}
module EventWithDetail = Webapi.Dom.CustomEvent.Make(Detail)

external toState: 'a => Dom.History.state = "%identity"
@send external urlToString: Webapi.Url.t => string = "toString"
@react.component
let make = (~href, ~children, ~className="", ~target="", ~rel="", ~onMouseEnter=?, ~onClick=?) => {
  switch Js.String2.startsWith(href, "/") {
  | false => <a href className rel target> children </a>
  | true =>
    <a
      href
      className
      rel
      target
      onMouseEnter={e => {
        switch onMouseEnter {
        | Some(onMouseEnter) => onMouseEnter(e)
        | None => ()
        }

        let base = Dom.Location.href(Dom.location)
        let url = Url.makeWith(href, ~base)

        let _ = Dom.EventTarget.dispatchEvent(
          Dom.Window.asEventTarget(window),
          EventWithDetail.makeWithOptions("_s_p", {detail: {href: urlToString(url)}}),
        )
      }}
      onClick={e => {
        switch onClick {
        | Some(onClick) => onClick(e)
        | None => ()
        }

        let base = Dom.Location.href(Dom.location)
        let url = Url.makeWith(href, ~base)

        Dom.History.pushState(Dom.history, toState(Js.Dict.empty()), "", urlToString(url))

        let _ = Dom.EventTarget.dispatchEvent(
          Dom.Window.asEventTarget(window),
          EventWithDetail.makeWithOptions("_s_l", {detail: {href: urlToString(url)}}),
        )
        ReactEvent.Mouse.preventDefault(e)
      }}>
      children
    </a>
  }
}
