@module("preact")
external hydrate: (JsxU.element, Webapi.Dom.Element.t) => unit = "hydrate"
@module("preact")
external render: (JsxU.element, Webapi.Dom.Element.t) => unit = "render"

module RenderToString = {
  @module("preact-render-to-string")
  external render: JsxU.element => string = "default"
}

module Signals = {
  @module("@preact/signals")
  external make: 'value => 'value = "signal"
}
