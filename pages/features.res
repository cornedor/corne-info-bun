// @react.component
let make: Page.makeFn = props => {
  let pageProps = props["pageProps"]

  let csr = "Client says: " ++ Float.toString(Math.random())

  <>
    <h3> {React.string("SSR Props")} </h3>
    <code>
      {switch pageProps {
      | Some(pageProps) => Js.Json.stringify(pageProps)->React.string
      | None => React.string("?")
      }}
    </code>
    <p>
      <code> {React.string(csr)} </code>
    </p>
  </>
}

let title = "Features"
// TODO: Find a shorter way to do this
let config: Page.pageConfig = %raw(`CLIENTSIDE`)
  ? {
      title: title,
    }
  : {
      title,
      getProps: async () => {
        Js.Json.string("Server says: " ++ Float.toString(Math.random()))
      },
    }
