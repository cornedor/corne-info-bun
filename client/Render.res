open Webapi.Dom

let pageInfoElem = Document.getElementById(Webapi.Dom.document, "pageInfo")
let pagePropsElem = Document.getElementById(Webapi.Dom.document, "pageProps")

let root = switch Document.getElementById(Webapi.Dom.document, "app") {
| Some(elem) => elem
| None => raise(Not_found)
}

let hydratePage = element => Preact.hydrate(element, root)
let renderPage = element => Preact.render(element, root)
