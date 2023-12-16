// import { walkMap } from './DaySixteen'

import { map } from "./DaySixteen23.gen";

const workerURL = new URL("DaySixteenWorker.ts", import.meta.url).href;

let height = map.length;
let width = map[0].length;

let maxAreaEngergized = 0;
console.time("startParallel");
async function startWorkers(
  count: number,
  payloadGenerator: (i: number) => any
) {
  let workers: Array<Promise<number>> = [];
  for (let i = 0; i < count; i++) {
    workers.push(
      new Promise((resolve) => {
        const worker = new Worker(workerURL);
        worker.onmessage = (e) => {
          console.log(i, "...", e.data);
          resolve(Number(e.data));
          worker.terminate();
        };
        // worker.postMessage(
        //   JSON.stringify({
        //     pos: [0, i],
        //     dir: [1, 0],
        //   })
        // );
        worker.postMessage(JSON.stringify(payloadGenerator(i)));
      })
    );
  }
  let results = (await Promise.all(workers)).map((item) => Number(item));
  maxAreaEngergized = Math.max(maxAreaEngergized, ...results);
}

await startWorkers(height, (i) => ({
  pos: [i, 0],
  dir: [0, 1],
}));
console.timeLog("startParallel");
await startWorkers(height, (i) => ({
  pos: [i, height - 1],
  dir: [0, -1],
}));
console.timeLog("startParallel");

await startWorkers(height, (i) => ({
  pos: [0, i],
  dir: [1, 0],
}));
console.timeLog("startParallel");
await startWorkers(height, (i) => ({
  pos: [width - 1, i],
  dir: [-1, 0],
}));
console.timeLog("startParallel");

console.log("Results", maxAreaEngergized);
