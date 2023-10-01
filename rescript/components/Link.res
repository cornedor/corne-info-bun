open Webapi

@react.component
let make = (~href, ~children, ~className="", ~rel="", ~onMouseEnter=?, ~onClick=?) => {
  switch Js.String2.startsWith(href, "/") {
  | false => <a href className rel> children </a>
  | true =>
    <a
      href
      className
      rel
      onMouseEnter={e => {
        switch onMouseEnter {
        | Some(onMouseEnter) => onMouseEnter(e)
        | None => ()
        }

        let base = Dom.Location.href(Dom.location)
        let url = Url.makeWith(href, ~base)

        let _ = Dom.EventTarget.dispatchEvent(
          Dom.Window.asEventTarget(window),
          Dom.CustomEvent.makeWithOptions(
            "_s_l",
            {
              "detail": {
                "href": url,
              },
            },
          ),
        )
      }}
      onClick={e => {
        switch onClick {
        | Some(onClick) => onClick(e)
        | None => ()
        }

        let base = Dom.Location.href(Dom.location)
        let url = Url.makeWith(href, ~base)

        let _ = Dom.EventTarget.dispatchEvent(
          Dom.Window.asEventTarget(window),
          Dom.CustomEvent.makeWithOptions(
            "_s_l",
            {
              "detail": {
                "href": url,
              },
            },
          ),
        )
      }}>
      children
    </a>
  }
}
