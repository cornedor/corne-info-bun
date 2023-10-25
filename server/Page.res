type makeFn = {
  "pageProps": option<Js.Json.t>,
  "components": option<MDXComponents.components>,
} => React.element

type getPropsFn = unit => promise<Js.Json.t>

@genType
type pageConfig = {
  title?: string,
  useBaseLayout?: bool,
  statusCode?: int,
  getProps?: getPropsFn,
  revalidate?: int,
}

type pageModule = {
  make?: makeFn,
  config?: pageConfig,
  default?: makeFn,
}

type ssrConfig = {statusCode: int, pageProps: option<Js.Json.t>}

external importPage: string => promise<option<pageModule>> = "import"
type cachedResult = {data: string, age: int}
@module("./Cache.ts")
external getCachedPageProps: (~path: string) => option<cachedResult> = "getCachedPageProps"
@module("./Cache.ts")
external setCachedPageProps: (~path: string, ~data: string, ~age: int) => unit =
  "setCachedPageProps"

let getComponentWithBaseLayout = (children, config) => {
  switch config.useBaseLayout {
  | Some(true) | None =>
    <BaseLayout title={config.title} showMainTitle={config.title == Some("Blog")}>
      children
    </BaseLayout>
  | Some(false) => children
  }
}

let render = async (source: string, isSsr: bool, pageProps: option<Js.Json.t>) => {
  switch await importPage(source) {
  | None => None
  | Some({make, config}) => {
      let pageProps = switch (isSsr, config.revalidate) {
      | (true, Some(revalidate)) => {
          let now = Belt.Float.toInt(Date.now())
          let revalidateAge = now - revalidate
          let cached = getCachedPageProps(~path=source)

          switch cached {
          | Some({data, age}) if age > revalidateAge => Some(JSON.parseExn(data))
          | _ =>
            switch config.getProps {
            | Some(getProps) => {
                let result = await getProps()
                let json = JSON.stringifyAny(result)
                switch json {
                | Some(json) =>
                  setCachedPageProps(~path=source, ~data=json, ~age=Belt.Float.toInt(Date.now()))
                | None => ()
                }
                Some(result)
              }
            | None => None
            }
          }
        }
      | (true, _) =>
        switch config.getProps {
        | Some(getProps) => {
            let result = await getProps()
            Some(result)
          }
        | None => None
        }
      | (false, _) => pageProps
      }

      let component = getComponentWithBaseLayout(
        React.createElement(make, {"pageProps": pageProps, "components": None}),
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
      getComponentWithBaseLayout(
        React.createElement(
          default,
          {
            "pageProps": None,
            "components": Some(MDXComponents.components),
          },
        ),
        config,
      ),
      {
        statusCode: 200,
        pageProps: None,
      },
    ))
  | Some({default}) =>
    Some((
      getComponentWithBaseLayout(
        React.createElement(
          default,
          {
            "pageProps": None,
            "components": None,
          },
        ),
        {useBaseLayout: true},
      ),
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
