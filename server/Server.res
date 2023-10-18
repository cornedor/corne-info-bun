open Webapi

Bun.plugin(MDXPlugin.mdxPlugin)

let importMetaDir = %raw("import.meta.dir")

let startBuilder = async () => {
  let pages = await Glob.glob("{pages,client}/**/*.{ts,tsx,mdx,js}")
  Js.log("Building " ++ Belt.Int.toString(Array.length(pages)) ++ " files...")
  await Bun.build({
    entrypoints: pages,
    outdir: "./_s",
    splitting: true,
    plugins: [MDXPlugin.mdxPlugin],
    // minify: process.env.DEV_MODE !== "true",
  })
}

Promise.done(startBuilder())

let router = Bun.FileSystemRouter.make({
  style: #nextjs,
  dir: "./pages",
  origin: "http://localhost:3000",
  assetPrefix: "pages/",
  fileExtensions: [".js", ".tsx", ".mdx"],
})

let htmlHeaders: Js.Dict.t<string> = Js.Dict.fromList(list{("Content-Type", "text/html")})
let staticHeaders: Js.Dict.t<string> = Js.Dict.fromList(list{("Cache-Control", "max-age=3600")})
let publicHeaders: Js.Dict.t<string> = Js.Dict.fromList(list{
  ("Cache-Control", "public, max-age=604800, immutable"),
})

let handleNotFound = () => {
  Bun.Response.make(
    "404 page not found",
    {
      status: 404,
    },
  )
}

let getPageInfo = (match: Bun.matchedRoute): Page.pageInfo => {
  let frontendUrl = Url.make(match.src)
  let frontendPath = Path.parse(Url.pathname(frontendUrl))

  Url.setPathname(frontendUrl, Array.joinWith([frontendPath.dir, `${frontendPath.name}.js`], "/"))

  {
    kind: match.kind,
    params: match.params,
    query: match.query,
    src: String.make(frontendUrl),
  }
}

let handleMatch = async (_request, match: Bun.matchedRoute) => {
  switch await Page.render(match.filePath, true, None) {
  | Some(pageElement, ssrConfig) => {
      let rendered = Preact.RenderToString.render(
        <RootLayout pageInfo={getPageInfo(match)} pageProps={ssrConfig.pageProps}>
          pageElement
        </RootLayout>,
      )
      Bun.Response.make(
        "<!doctype html>" ++ rendered,
        {status: ssrConfig.statusCode, headers: htmlHeaders},
      )
    }
  | None => handleNotFound()
  }
}

let handleFile = async (request: Bun.request) => {
  let pathname = Url.make(request.url)->Url.pathname->Js.String2.replaceByRe(%re("/^\//"), "")
  let staticPath = NodeJs.Path.resolve([importMetaDir, "..", "_s", pathname])
  let publicPath = NodeJs.Path.resolve([importMetaDir, "..", "public", pathname])

  let staticFile = Bun.file(~path=staticPath)
  let publicFile = Bun.file(~path=publicPath)

  switch await Js.Promise2.all2((Bun.BunFile.exists(staticFile), Bun.BunFile.exists(publicFile))) {
  | (false, false) => handleNotFound()
  | (true, _) => Bun.Response.make(staticFile, {status: 200, headers: staticHeaders})
  | (false, true) => Bun.Response.make(publicFile, {status: 200, headers: publicHeaders})
  }
}

let server = Bun.serve({
  port: 3000,
  fetch: async (request, _server) => {
    // _server is not set, so we use the above defined server. This is a hack, but I can't find a
    // better way for now.
    switch Bun.Server.upgrade(%raw("server"), request) {
    | true => None
    | false =>
      switch Js.Nullable.toOption(Bun.FileSystemRouter.matchRequest(router, request)) {
      | Some(m) => Some(await handleMatch(request, m))
      | None => Some(await handleFile(request))
      }
    }
  },
  websocket: {
    \"open": async _s => {
      Js.log("Socket opened")
      //  let _t: int = Bun.ServerWebSocket.close(~t=s, ~code=1, ~reason="")
    },
    close: async (_s, _status, msg) => {
      Js.log2("Socket closed:", msg)
    },
    message: async (ws, message) => {
      open Protocol

      switch parseRequest(message) {
      | Ok(Ping) => switch serializeResponse(Pong) {
        | Ok(data) =>
          let _ = Bun.ServerWebSocket.sendStr(ws, data)
        | _ => Js.log("Could not send response")
        }
      | Ok(Prefetch({url})) => Js.log2("Prefetch", url)
      | Ok(Refetch({url})) => Js.log2("Prefetch", url)
      | Error(err) => Js.log(err)
      }
    },
  },
})

let _ = Bun.Server.fetchStr(server, "/")
