import { logWithTime } from "./day5logger";

const workerURL = new URL("day5worker.js", import.meta.url).href;

var chunks = [
  [2149186375.0, 163827995.0],
  [1217693442.0, 67424215.0],
  [365381741.0, 74637275.0],
  [1627905362.0, 77016740.0],
  [22956580.0, 60539394.0],
  // [586585112.0,        391263016.0],
  [586585112, 195631508],
  [586585112 + 195631508, 195631508],
  // [2740196667.0,       355728559.0],
  [2740196667, 177864280],
  [2740196667 + 177864280, 177864279],
  [2326609724.0, 132259842.0],
  [2479354214.0, 184627854.0],
  // [3683286274.0,       337630529.0],
  [3683286274, 168815265],
  [3683286274 + 168815265, 168815264],
];

// const chunks2 = [
//   [1636419363,  608824189],
//   [3409451394,  227471750],
//   [12950548,     91466703],
//   [1003260108,  224873703],
//   [440703838,   191248477],
//   [634347552,   275264505],
//   [3673953799,   67839674],
//   [2442763622,  237071609],
//   [3766524590,  426344831],
//   [1433781343,  153722422],
// ];

logWithTime("Starting workers...");
let workers = chunks.map((chunk) => {
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
