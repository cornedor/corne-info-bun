@react.component
type makeFn = {"pageProps": option<Js.Json.t>} => React.element

type getPropsFn = unit => promise<Js.Json.t>
type pageConfig = {
  title?: string,
  useBaseLayout?: bool,
  statusCode?: int,
  getProps?: getPropsFn,
}

type pageModule = {
  make?: makeFn,
  config?: pageConfig,
  default?: unit => React.element,
}

type pageInfo = {
  kind: Bun.matchedRouteKind,
  params: Js.Dict.t<string>,
  query: Js.Dict.t<string>,
  src: string,
}

type ssrConfig = {statusCode: int, pageProps: option<Js.Json.t>}

external importPage: string => promise<option<pageModule>> = "import"

let getComponentWithBaseLayout = (children, config) => {
  switch config.useBaseLayout {
  | Some(true) | None => <BaseLayout title={config.title}> children </BaseLayout>
  | Some(false) => children
  }
}

let render = async (source: string, isSsr: bool, pageProps: option<Js.Json.t>) => {
  switch await importPage(source) {
  | None => None
  | Some({make, config}) => {
      let pageProps = isSsr
        ? switch config.getProps {
          | Some(getProps) => Some(await getProps())
          | None => None
          }
        : pageProps

      let component = getComponentWithBaseLayout(
        React.createElement(make, {"pageProps": pageProps}),
        config,
      )

      let ssrConfig = {
        statusCode: switch config.statusCode {
        | Some(c) => c
        | None => 200
        },
        pageProps,
      }

      Some(component, ssrConfig)
    }
  | Some({default, config}) =>
    Some((
      getComponentWithBaseLayout(React.createElement(default, ()), config),
      {
        statusCode: 200,
        pageProps: None,
      },
    ))
  | Some({default}) =>
    Some((
      getComponentWithBaseLayout(React.createElement(default, ()), {useBaseLayout: true}),
      {
        statusCode: 200,
        pageProps: None,
      },
    ))
  | Some(other) => {
      Js.log2("Not implemented", other)
      None
    }
  }
}
