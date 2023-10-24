open Webapi

Bun.plugin(MDXPlugin.mdxPlugin)

let importMetaDir = %raw("import.meta.dir")
let origin = %raw("process.env.ROUTER_ORIGIN")

// This is used to tree shake SSR functions from frontend code.
%%raw(`globalThis.CLIENTSIDE = false`)

let router = Bun.FileSystemRouter.make({
  style: #nextjs,
  dir: "./pages",
  origin,
  assetPrefix: "pages/",
  fileExtensions: [".js", ".tsx", ".mdx"],
})

let htmlHeaders: Js.Dict.t<string> = Js.Dict.fromList(list{("Content-Type", "text/html")})
let staticHeaders: Js.Dict.t<string> = Js.Dict.fromList(list{("Cache-Control", "max-age=3600")})
let publicHeaders: Js.Dict.t<string> = Js.Dict.fromList(list{
  ("Cache-Control", "public, max-age=31536000, immutable"),
})

let handleNotFound = () => {
  Bun.Response.make(
    "404 page not found - <a href='/'>Go to home</a>",
    {
      status: 404,
      headers: htmlHeaders,
    },
  )
}

let getPageInfo = (match: Bun.matchedRoute): Protocol.pageInfo => {
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
      // Js.log(rendered)
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

  let staticHeaders = switch String.startsWith(pathname, "chunk") {
  | true => publicHeaders
  | false => staticHeaders
  }

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
      | Ok(Ping) =>
        switch serializeResponse(Pong) {
        | Ok(data) =>
          let _ = Bun.ServerWebSocket.sendStr(ws, data)
        | _ => Js.log("Could not send response")
        }
      | Ok(Prefetch({url})) =>
        switch Js.Nullable.toOption(Bun.FileSystemRouter.match(router, url)) {
        | Some(m) => {
            let pageInfo = getPageInfo(m)
            switch serializeResponse(PrefetchSource({src: pageInfo.src})) {
            | Ok(data) =>
              let _ = Bun.ServerWebSocket.sendStr(ws, data)
            | _ => Js.log("Could not send response")
            }
          }
        | None => Js.log("Page not found, so cannot be prefetched")
        }
      | Ok(Refetch({url})) =>
        switch Js.Nullable.toOption(Bun.FileSystemRouter.match(router, url)) {
        | Some(m) =>
          switch await Page.render(m.filePath, true, None) {
          | Some(_, ssrConfig) => {
              let pageInfo = getPageInfo(m)
              switch serializeResponse(
                Match({
                  src: pageInfo.src,
                  pageProps: ssrConfig.pageProps,
                }),
              ) {
              | Ok(data) =>
                let _ = Bun.ServerWebSocket.sendStr(ws, data)
              | _ => Js.log("Could not send response")
              }
            }
          | None => Js.log("...")
          }
        | None =>
          switch serializeResponse(NoMatch) {
          | Ok(data) =>
            let _ = Bun.ServerWebSocket.sendStr(ws, data)
          | _ => Js.log("Could not send response")
          }
        }
      | Error(err) => Js.log(err)
      }
    },
  },
})

Js.log("Starting server...")
