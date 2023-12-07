"use client";
import { mapValue, isInRange, getMaps } from "./DayFive23";

export type RangeMap = {
  name: string;
  destStart: number;
  sourceStart: number;
  sourceEnd: number;
  length: number;
};

var order = [
  "seed-to-soil",
  "soil-to-fertilizer",
  "fertilizer-to-water",
  "water-to-light",
  "light-to-temperature",
  "temperature-to-humidity",
  "humidity-to-location",
];

function getLines(
  start: number,
  end: number,
  rangeMap: RangeMap[]
): Array<[number, number]> {
  // Is there a mapping where the start position is in range
  const inMap = rangeMap.find((range) => isInRange(start, range));

  if (!inMap) {
    // const inMap = rangeMap.find((range) => isInRange(end, range));
    // if (inMap) {
    //   let newEnd = inMap.sourceStart;
    //   let newRangeStart = inMap.sourceStart + 1;
    //   // console.log(`Split end ${start}-${end} => ${newRangeStart}-${end}`);
    //   return [
    //     [mapValue(start, inMap), mapValue(newEnd, inMap)],
    //     ...getLines(newRangeStart, end, rangeMap),
    //   ];
    // }
    return [[start, end]];
  }

  if (isInRange(end, inMap)) {
    return [[mapValue(start, inMap), mapValue(end, inMap)]];
  }

  // Split a range into two new ranges
  let newEnd = inMap.sourceEnd;
  let newRangeStart = inMap.sourceEnd + 1;

  console.log(`Split beginning ${start}-${end} => ${newRangeStart}-${end}`);

  return [
    [mapValue(start, inMap), mapValue(newEnd, inMap)],
    ...getLines(newRangeStart, end, rangeMap),
  ];
}

function resolveRange(
  maps: Map<string, Array<RangeMap>>,
  start: number,
  stop: number,
  i: number = 0
): number {
  if (i === order.length - 1) {
    let map = maps.get(order[i])!;
    const resolvedLines = getLines(start, stop, map);
    return Math.min(...resolvedLines.map((item) => item[0]));
  }
  let key = order[i];
  let map = maps.get(key)!;
  const resolvedLines = getLines(start, stop, map);

  return Math.min(
    ...resolvedLines.flatMap(([start, stop]) =>
      resolveRange(maps, start, stop, i + 1)
    )
  );
}
const files = ["inputs/d5-example.txt", "inputs/d5-rolf.txt"];
console.time("Total");
for (const file of files) {
  const [maps, seedRanges] = (await getMaps(file)) as [
    Map<string, Array<RangeMap>>,
    number[][],
  ];
  console.log(`\n\n\n\nRun ${file}`);
  console.time("Single cycle");
  console.log(
    Math.min(
      ...seedRanges.map(([s, e]) => {
        // console.log("\n\n");
        console.time(`Resolving range ${s} - ${e}`);
        const result = resolveRange(maps, s, s + e);
        console.timeEnd(`Resolving range ${s} - ${e}`);
        return result;
      })
    )
  );
  console.timeEnd("Single cycle");
}
console.timeEnd("Total");
