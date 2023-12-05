
import { mapValues, getMaps } from "./DayFive23";
import { logWithTime } from "./day5logger";


/**
 * 
 * @param {MessageEvent} event 
 */
self.onmessage = (event) => {
  logWithTime("Worker started...")
  const maps = getMaps()
  const { rangeStart, rangeLength } = JSON.parse(event.data)
  let minPos = Number.MAX_VALUE
  for (let i = 0; i < rangeLength; i++) {
    let seed = i + rangeStart
    let val = mapValues(maps, seed)
    minPos = Math.min(val, minPos)
  }

  postMessage(minPos);
};
