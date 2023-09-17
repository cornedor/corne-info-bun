import { ComponentChildren } from "preact";

interface RootLayoutProps {
  children?: ComponentChildren;
  pageInfo?: any;
}

export default function RootLayout({ children, pageInfo }: RootLayoutProps) {
  return (
    <html>
      <head>
        <meta charSet="utf8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link href="/output.css" rel="stylesheet" />
        <title>Corné Dorrestijn</title>
      </head>
      <body class="bg-stone-50 font-serif antialiased dark:bg-stone-950 dark:text-stone-400 contrast-more:dark:text-stone-100">
        <div id="app">{children}</div>
        <script
          type="application/json"
          id="pageInfo"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(pageInfo) }}
        />
        <script type="module" src="/client/index.js"></script>
      </body>
    </html>
  );
}
