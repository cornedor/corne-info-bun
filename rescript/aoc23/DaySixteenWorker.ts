import { countEnergized, walkMap, energized } from "./DaySixteen23.gen";

// console.log("fooooo");

self.onmessage = (event) => {
  const data = JSON.parse(event.data) as {
    pos: [number, number];
    dir: [number, number];
  };

  walkMap(data.pos, data.dir, 1);

  postMessage(countEnergized());
};
