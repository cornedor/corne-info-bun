@genType @react.component
let make = (~children, ~pageInfo) => {
  <html>
    <head>
      <meta charSet="utf8" />
      <meta name="viewport" content="width=device-width, initial-scale=1" />
      <link href="/output.css" rel="stylesheet" />
      <link href="/legacy.css" rel="stylesheet" />
      <title> {React.string("Corné Dorrestijn")} </title>
    </head>
    <body
      className="bg-stone-50 font-serif antialiased dark:bg-stone-950 dark:text-stone-400 contrast-more:dark:text-stone-100">
      <div id="app"> children </div>
      <script type_="module" src="/client/Client.js" />
      <script
        type_="application/json"
        id="pageInfo"
        dangerouslySetInnerHTML={{
          "__html": switch Js.Json.stringifyAny(pageInfo) {
          | Some(s) => s
          | None => "{}"
          },
        }}
      />
    </body>
  </html>
}
