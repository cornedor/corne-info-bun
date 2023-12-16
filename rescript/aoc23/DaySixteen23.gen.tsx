/* TypeScript file generated from DaySixteen23.res by genType. */

/* eslint-disable */
/* tslint:disable */

import * as DaySixteen23BS__Es6Import from './DaySixteen23';
const DaySixteen23BS: any = DaySixteen23BS__Es6Import;

export type tile = 
    "MirrorTopRight"
  | "MirrorTopLeft"
  | "SplitterHorizontal"
  | "SplitterVertical"
  | "Air";

export type xy = [number, number];

export const map: Array<tile[]> = DaySixteen23BS.map;

export const energized: Array<boolean[]> = DaySixteen23BS.energized;

export const walkMap: (pos:xy, movement:xy, power:number) => boolean = DaySixteen23BS.walkMap;

export const countEnergized: () => number = DaySixteen23BS.countEnergized;
