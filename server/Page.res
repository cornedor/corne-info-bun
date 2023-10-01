@react.component
type makeFn = {"pageProps": Js.Json.t} => React.element

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

type ssrConfig = {statusCode: int, pageProps: Js.Json.t}

external importPage: string => promise<option<pageModule>> = "import"

let getComponentWithBaseLayout = (children, config) => {
  switch config.useBaseLayout {
  | Some(true) | None => <BaseLayout title={config.title}> children </BaseLayout>
  | Some(false) => children
  }
}

let render = async (source: string) => {
  switch await importPage(source) {
  | None => None
  | Some({make, config}) => {
      let pageProps = switch config.getProps {
      | Some(getProps) => await getProps()
      | None => Js.Json.null
      }

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
  | Some({default, config}) => Some((
      getComponentWithBaseLayout(React.createElement(default, ()), config),
      {
        statusCode: 200,
        pageProps: Js.Json.null,
      },
    ))
  | Some({default}) =>
    Some((
      getComponentWithBaseLayout(React.createElement(default, ()), {useBaseLayout: true}),
      {
        statusCode: 200,
        pageProps: Js.Json.null,
      },
    ))
  | Some(other) => {
      Js.log2("Not implemented", other)
      None
    }
  }
}
