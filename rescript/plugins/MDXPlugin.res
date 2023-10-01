let mdxPlugin: Bun.bunPlugin = {
  name: "MDX Loader",
  target: #bun,
  setup: build => {
    Bun.PluginBuilder.onLoad(
      build,
      {
        filter: %re("/\.mdx$/"),
      },
      async args => {
        let text = Bun.file(~path=args.path)->Bun.BunFile.text

        let result: Bun.onLoadResult = {
          contents: Js.String.make(
            await Mdx.compileString(
              await text,
              {
                "jsxImportSource": "preact",
                "jsxRuntime": "automatic",
              },
            ),
          ),
          loader: #js,
        }

        result
      },
    )
  },
}
