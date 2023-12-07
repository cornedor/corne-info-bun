import { getMaps } from "./DayFive23";
import { logWithTime } from "./day5logger";

const workerURL = new URL("day5worker.js", import.meta.url).href;
let [_, seeds] = await getMaps();

logWithTime("Starting workers...");
let workers = seeds.map((chunk: [number, number]) => {
  const [rangeStart, rangeLength] = chunk;
  return new Promise<number>((resolve) => {
    let worker = new Worker(workerURL);
    worker.onmessage = (e) => {
      logWithTime(`Lowest out of ${rangeLength} items is:`, e.data);
      resolve(Number(e.data));
    };
    worker.postMessage(JSON.stringify({ rangeStart, rangeLength }));
  });
});

const results = await Promise.all(workers);
logWithTime("Done calculating chunks 😵‍💫");
logWithTime(`Final result: ${Math.min(...results)}`);
process.exit();
