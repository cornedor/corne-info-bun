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
  let optionsA: Array<{
    pos: [number, number];
    dir: [number, number];
  }> = [];
  let optionsB: Array<{
    pos: [number, number];
    dir: [number, number];
  }> = [];
  let step = Math.floor(count / 2);
  for (let i = 0; i < step; i++) {
    optionsA.push(payloadGenerator(i));
  }
  for (let i = step; i < count; i++) {
    optionsB.push(payloadGenerator(i));
  }

  const resultA: Promise<number> = new Promise((resolve) => {
    const worker = new Worker(workerURL);
    worker.onmessage = (e) => {
      resolve(Number(e.data));
      worker.terminate();
    };
    worker.postMessage(JSON.stringify(optionsA));
  });
  const resultB: Promise<number> = new Promise((resolve) => {
    const worker = new Worker(workerURL);
    worker.onmessage = (e) => {
      resolve(Number(e.data));
      worker.terminate();
    };
    worker.postMessage(JSON.stringify(optionsB));
  });

  let res = await Promise.all([resultA, resultB]);

  console.log(res);

  maxAreaEngergized = Math.max(maxAreaEngergized, ...res);
}

const workers = [];
workers.push(
  startWorkers(height, (i) => ({
    pos: [i, 0],
    dir: [0, 1],
  }))
);
workers.push(
  startWorkers(height, (i) => ({
    pos: [i, height - 1],
    dir: [0, -1],
  }))
);
workers.push(
  startWorkers(height, (i) => ({
    pos: [0, i],
    dir: [1, 0],
  }))
);
workers.push(
  startWorkers(height, (i) => ({
    pos: [width - 1, i],
    dir: [-1, 0],
  }))
);

await Promise.all(workers);

console.log("Results", maxAreaEngergized);
console.timeEnd("startParallel");
