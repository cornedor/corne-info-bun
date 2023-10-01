import { signal } from "@preact/signals";
import { VNode, hydrate, render } from "preact";
import { renderPage } from "../utils/renderPage";
import { DevMode } from "../components/DevMode";

const pageInfoText = document.getElementById("pageInfo")?.innerText;

if (!pageInfoText) {
  throw new Error("Invalid request");
}

const currentComponent = signal<VNode | null>(null);

const pageInfo = JSON.parse(pageInfoText);
const rootElement = document.getElementById("app");

if (!rootElement) {
  throw new Error("No root element");
}

renderPage(pageInfo.src).then(([page]) => {
  currentComponent.value = page;
  hydrate(<>{currentComponent}</>, rootElement);
});

const socket = new WebSocket("ws://localhost:3000/");
socket.addEventListener("message", (event) => {
  const payload = JSON.parse(event.data);

  switch (payload.e) {
    case "no-match":
      location.href = payload.h;
      break;
    case "match":
      renderPage(payload.d.src).then(
        ([page]) => (currentComponent.value = page)
      );
      break;
    case "prefetch":
      import(payload.d.src);
      break;
    case "devmode":
      const container = document.createElement("div");
      document.body.appendChild(container);
      render(<DevMode socket={socket} />, container);
      break;
  }
});

socket.addEventListener("open", () => {
  socket.send(
    JSON.stringify({
      e: "ping",
    })
  );
});

function refetchCurrentPage() {
  socket.send(
    JSON.stringify({
      e: "refetch",
      h: document.location.href,
    })
  );
}

addEventListener("popstate", () => refetchCurrentPage());
addEventListener("_s_p", () => refetchCurrentPage());

addEventListener("_s_l", (e: Event & { detail?: { href: string } }) => {
  if (!e.detail?.href) {
    return;
  }
  socket.send(
    JSON.stringify({
      e: "prefetch",
      h: e.detail.href,
    })
  );
});
