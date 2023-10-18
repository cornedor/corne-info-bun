// These types are specific to this project, only a small part is added to this bindings

type pluginConstraints = {
  /**
  * Only apply the plugin when the import specifier matches this regular expression
  *
  * @example
  * ```ts
  * // Only apply the plugin when the import specifier matches the regex
  * Bun.plugin({
  *  setup(builder) {
  *     builder.onLoad({ filter: /node_modules\/underscore/ }, (args) => {
  *      return { contents: "throw new Error('Please use lodash instead of underscore.')" };
  *     });
  *  }
  * })
  * ```
  */
  filter: Js.Re.t,
  /**
  * Only apply the plugin when the import specifier has a namespace matching
  * this string
  *
  * Namespaces are prefixes in import specifiers. For example, `"bun:ffi"`
  * has the namespace `"bun"`.
  *
  * The default namespace is `"file"` and it can be omitted from import
  * specifiers.
  */
  namespace?: string,
}

type loader = [
  | #js
  | #jsx
  | #ts
  | #tsx
  | #json
  | #toml
  | #file
  | #napi
  | #wasm
  | #text
]

type onLoadArgs = {
  /**
   * The resolved import specifier of the module being loaded
   * @example
   * ```ts
   * builder.onLoad({ filter: /^hello:world$/ }, (args) => {
   *   console.log(args.path); // "hello:world"
   *   return { exports: { foo: "bar" }, loader: "object" };
   * });
   * ```
   */
  path: string,
  /**
   * The namespace of the module being loaded
   */
  namespace: string,
  /**
   * The default loader for this file extension
   */
  loader: loader,
}

type onLoadResult = {
  /**
   * The source code of the module
   */
  contents: string,
  /**
   * The loader to use for this file
   *
   * "css" will be added in a future version of Bun.
   */
  loader?: loader,
}

type onLoadCallback = onLoadArgs => promise<onLoadResult>

module PluginBuilder = {
  type t

  /**
   * Register a callback to load imports with a specific import specifier
   * @param constraints The constraints to apply the plugin to
   * @param callback The callback to handle the import
   * @example
   * ```ts
   * Bun.plugin({
   *   setup(builder) {
   *     builder.onLoad({ filter: /^hello:world$/ }, (args) => {
   *       return { exports: { foo: "bar" }, loader: "object" };
   *     });
   *   },
   * });
   * ```
   */
  @send
  external onLoad: (t, pluginConstraints, onLoadCallback) => unit = "onLoad"
}

type bunTarget = [#bun | #node | #browser]

type bunPlugin = {
  /**
   * Human-readable name of the plugin
   *
   * In a future version of Bun, this will be used in error messages.
   */
  name?: string,
  /**
   * For generating bundles that are intended to be run by the Bun runtime. In many cases,
   * it isn't necessary to bundle server-side code; you can directly execute the source code
   * without modification. However, bundling your server code can reduce startup times and
   * improve running performance.
   *
   * * bun: All bundles generated with `target: "bun"` are marked with a special `// @bun` pragma, which
   *        indicates to the Bun runtime that there's no need to re-transpile the file before execution.
   * * node: The plugin will be applied to Node.js builds
   * * browser: The plugin will be applied to browser builds 
   */
  target?: bunTarget,
  setup: PluginBuilder.t => unit,
}

type blobPropertyBag = {
  /** Set a default "type". Not yet implemented. */
  \"type"?: string,

  // endings?: "transparent" | "native";
}

type responseInit = {
  headers?: Js.Dict.t<string>,
  status?: int,
  statusText?: string,
}

type rec response = {
  headers: Js.Dict.t<string>,
  body: unknown,
  bodyUsed: bool,
  text: unit => Promise.t<string>,
  arrayBuffer: unit => Promise.t<unknown>,
  json: unit => Promise.t<Js.Json.t>,
  blob: unit => Promise.t<unknown>,
  formData: unit => Promise.t<unknown>,
  ok: bool,
  redirected: bool,
  status: int,
  statusText: string,
  \"type": [
    | #basic
    | #cors
    | #default
    | #error
    | #opaque
    | #opaqueredirect
  ],
  url: string,
  clone: unit => response,
}

module Response = {
  @new external make: ('a, responseInit) => response = "Response"

  @scope("Response")
  external json: (~body: Js.Json.t, ~options: responseInit=?) => response = "json"
  @scope("Response")
  external redirect: (~url: string, ~status: int=?) => response = "redirect"
  @scope("Response")
  external redirectOpts: (~url: string, ~options: responseInit=?) => response = "redirect"
  @scope("Response")
  external error: unit => response = "error"
}

type request = {url: string}

module GenericServeOptions = {
  type t
}

module Server = {
  type t = BunTypes.server

  @send external stop: (t, ~closeActiveConnections: bool=?) => unit = "stop"
  @send external reload: (t, BunTypes.serve) => unit = "reload"
  @send external fetch: (t, request) => promise<response> = "fetch"
  @send external fetchStr: (t, string) => promise<response> = "fetch"

  @send external upgrade: (@this t, request) => bool = "upgrade"
}

module ServerWebSocket = {
  type t

  type compress = bool

  @send external sendStr: (t, string) => int = "send"
  @send external sendText: (t, string) => int = "sendText"
  @send external close: (~t: t, ~code: int=?, ~reason: string=?) => int = "close"
}

type buffer = unknown // todo
// type message = StringMessage(string) | BufferMessage(buffer)
type message = string

type webSocketHandler = {
  message?: (ServerWebSocket.t, message) => promise<unit>,
  \"open"?: ServerWebSocket.t => promise<unit>,
  drain?: ServerWebSocket.t => promise<unit>,
  close?: (ServerWebSocket.t, int, string) => promise<unit>,
  ping?: (ServerWebSocket.t, buffer) => promise<unit>,
  pong?: (ServerWebSocket.t, buffer) => promise<unit>,
  /**
   * Sets the maximum size of messages in bytes.
   *
   * Default is 16 MB, or `1024 * 1024 * 16` in bytes.
   */
  maxPayloadLength?: int,
  /**
   * Sets the maximum number of bytes that can be buffered on a single connection.
   *
   * Default is 16 MB, or `1024 * 1024 * 16` in bytes.
   */
  backpressureLimit?: int,
  /**
   * Sets if the connection should be closed if `backpressureLimit` is reached.
   *
   * Default is `false`.
   */
  closeOnBackpressureLimit?: bool,
  /**
   * Sets the the number of seconds to wait before timing out a connection
   * due to no messages or pings.
   *
   * Default is 2 minutes, or `120` in seconds.
   */
  idleTimeout?: int,
  /**
   * Should `ws.publish()` also send a message to `ws` (itself), if it is subscribed?
   *
   * Default is `false`.
   */
  publishToSelf?: int,
  /**
   * Should the server automatically send and respond to pings to clients?
   *
   * Default is `true`.
   */
  sendPings?: int,
}

type rec serve = {
  /**
   * What is the maximum size of a request body? (in bytes)
   * @default 1024 * 1024 * 128 // 128MB
   */
  maxRequestBodySize?: int,
  /**
   * Render contextual errors? This enables bun's error page
   * @default process.env.NODE_ENV !== 'production'
   */
  development?: bool,
  error?: (Server.t, Js.Exn.t) => unit,
  id?: Js.null<string>,
  port?: int,
  hostname?: string,
  websocket?: webSocketHandler,
  fetch?: (request, Server.t) => promise<option<response>>,
}

// module Server = {
//   type t

//   type stop = bool => unit
//   type reload = serve => unit
//   type fetch = string => promise<response>

//   @as("fetch")
//   type fetchReq = request => promise<response>
// }

type genericServeOptions = {
  maxRequestBodySize?: int,
  development?: bool,
}

module BunFile = {
  type t

  type writeOptions = {highWaterMark?: int}

  @get external lastModified: t => string = "lastModified"
  @get external name: t => string = "name"

  @send external slice: (t, ~begin: int=?, ~end: int=?, ~contentType: string=?) => t = "slice"
  @send external writer: (t, ~options: writeOptions=?) => t = "writer"
  @send external exists: t => promise<bool> = "exists"
  @send external text: t => promise<string> = "text"
}

type matchedRouteKind = [
  | #exact
  | #"catch-all"
  | #"optional-catch-all"
  | #dynamic
]

type matchedRoute = {
  params: Js.Dict.t<string>,
  filePath: string,
  pathname: string,
  query: Js.Dict.t<string>,
  name: string,
  kind: matchedRouteKind,
  src: string,
}

module FileSystemRouter = {
  type t
  type options = {
    dir: string,
    style: [#nextjs],
    assetPrefix?: string,
    origin?: string,
    fileExtensions?: array<string>,
  }
  @module("bun") @new external make: options => t = "FileSystemRouter"
  @send external match: (t, string) => Js.Nullable.t<matchedRoute> = "match"
  @send external matchRequest: (t, request) => Js.Nullable.t<matchedRoute> = "match"
}

type buildNaming =
  | Simple(string)
  | Complex({chunk?: string, entry?: string, asset?: string})

type buildMinify =
  | MinifyEnabled(bool)
  | MinifyConfig({whitespace?: bool, syntax?: bool, identifiers?: bool})

type buildConfig = {
  entrypoints: array<string>,
  outdir?: string,
  target?: bunTarget,
  format?: [#esm],
  naming?: buildNaming,
  root?: string,
  splitting?: bool,
  plugins?: array<bunPlugin>,
  \"external"?: array<string>,
  publicPath?: string,
  define?: Js.Dict.t<string>,
  sourcemap?: [#none | #inline | #"external"],
  minify?: buildMinify,
}

type buildArtifact = {
  path: string,
  loader: loader,
  hash: Js.Nullable.t<string>,
  kind: [#"entry-point" | #chunk | #asset | #sourcemap],
}

type buildOutput = {
  outputs: array<unit>,
  success: bool,
  logs: array<unit>,
}

@module("bun") external file: (~path: string) => BunFile.t = "file"
@module("bun") external plugin: bunPlugin => unit = "plugin"
@module("bun") external serve: serve => Server.t = "serve"

@module("bun") external build: buildConfig => promise<buildOutput> = "build"
