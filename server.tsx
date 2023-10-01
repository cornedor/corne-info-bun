import render from "preact-render-to-string";
import path from "path";
import { make as RootLayout } from "./server/RootLayout.gen";
import { MatchedRoute, plugin } from "bun";
import { glob } from "glob";
// import { mdxPlugin } from "./plugins/MDXPlugin";
import { BaseLayout } from "./layouts/BaseLayout";
import { renderPage } from "./utils/renderPage";
import { mdxPlugin } from "./rescript/plugins/MDXPlugin";

plugin(mdxPlugin);

function rebuildFrontend() {
  console.log("Rebuild frontend");
  glob("{pages,client}/**/*.{ts,tsx,mdx,js}").then((pages) =>
    Bun.build({
      entrypoints: pages,
      outdir: "./_s",
      splitting: true,
      plugins: [mdxPlugin],
      minify: process.env.DEV_MODE !== "true",
    })
  );
}
rebuildFrontend();

const router = new Bun.FileSystemRouter({
  style: "nextjs",
  dir: "./pages",
  origin: "http://localhost:3000",
  assetPrefix: "pages/",
  fileExtensions: [".tsx", ".mdx"],
});

function getPageInfo(match: MatchedRoute) {
  const frontendUrl = new URL(match.src);
  const frontendPath = path.parse(frontendUrl.pathname);

  frontendUrl.pathname = [frontendPath.dir, `${frontendPath.name}.js`].join(
    "/"
  );

  return {
    kind: match.kind,
    params: match.params,
    pathname: match.pathname,
    query: match.query,
    src: frontendUrl.toString(),
  };
}

const server = Bun.serve({
  port: 3001,
  async fetch(request) {
    if (server.upgrade(request)) {
      return;
    }

    const match = router.match(request);

    if (!match) {
      let pathname = new URL(request.url).pathname;

      const staticPath = path.resolve(
        import.meta.dir,
        "_s",
        pathname.replace(/^\//, "")
      );
      const staticFile = Bun.file(staticPath);
      const publicPath = path.resolve(
        import.meta.dir,
        "public",
        pathname.replace(/^\//, "")
      );
      const publicFile = Bun.file(publicPath);

      const headers = new Headers();
      headers.append(
        "Cache-Control",
        pathname.startsWith("/pages/")
          ? "max-age=3600"
          : "public, max-age=604800, immutable"
      );
      if (await staticFile.exists()) {
        return new Response(staticFile, {
          headers,
        });
      }

      if (await publicFile.exists()) {
        return new Response(publicFile, {
          headers,
        });
      }

      return new Response("404 page not found", {
        status: 404,
      });
    }

    const [page, { statusCode }] = await renderPage(match.filePath);

    const rendered = render(
      <RootLayout pageInfo={getPageInfo(match)}>{page}</RootLayout>
    );
    const html = `<!doctype html>${rendered}`;

    return new Response(html, {
      headers: {
        "Content-Type": "text/html",
      },
      status: statusCode ?? 200,
    });
  },

  websocket: {
    open(ws) {
      ws.subscribe("universe");
    },

    close(ws) {
      ws.unsubscribe("universe");
    },
    async message(ws, message) {
      if (typeof message !== "string") {
        return;
      }
      const payload = JSON.parse(message);
      switch (payload.e) {
        case "ping":
          ws.send(
            JSON.stringify({
              e: "pong",
              a: ws.remoteAddress,
            })
          );

          ws.publish("universe", "Hello!");

          if (process.env.DEV_MODE === "true") {
            ws.send(
              JSON.stringify({
                e: "devmode",
              })
            );
          }

          break;
        case "prefetch": {
          const match = router.match(payload.h);
          if (match) {
            ws.send(
              JSON.stringify({
                e: "prefetch",
                d: getPageInfo(match),
              })
            );
          }
          break;
        }
        case "refetch":
          const match = router.match(payload.h);
          if (!match) {
            ws.send(
              JSON.stringify({
                e: "no-match",
                h: payload.h,
              })
            );
            return;
          }
          ws.send(
            JSON.stringify({
              e: "match",
              d: getPageInfo(match),
            })
          );
          break;

        case "rebuild":
          rebuildFrontend();
          break;
        default:
          console.warn("Unkown event");
      }
    },
  },
});

console.log(`Listening on localhost:${server.port}`);
