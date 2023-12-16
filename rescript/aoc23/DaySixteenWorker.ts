import { throwRay } from "./DaySixteen23.gen";

// console.log("fooooo");

self.onmessage = (event) => {
  const data = JSON.parse(event.data) as Array<{
    pos: [number, number];
    dir: [number, number];
  }>;

  let max = 0;
  for (const item of data) {
    max = Math.max(max, throwRay(item.pos, item.dir));
  }

  postMessage(max);
};
