/* TypeScript file generated from DaySixteen23.res by genType. */

/* eslint-disable */
/* tslint:disable */

import * as DaySixteen23BS__Es6Import from './DaySixteen23';
const DaySixteen23BS: any = DaySixteen23BS__Es6Import;

import type {t as Map_t} from './Map.gen';

export type tile = 
    "MirrorTopRight"
  | "MirrorTopLeft"
  | "SplitterHorizontal"
  | "SplitterVertical"
  | "Air";

export type xy = [number, number];

export const map: Array<tile[]> = DaySixteen23BS.map;

export const walkMap: (pos:xy, movement:xy, power:number, cache:Map_t<string,boolean>, energized:Array<boolean[]>) => boolean = DaySixteen23BS.walkMap;

export const countEnergized: (energized:Array<boolean[]>) => number = DaySixteen23BS.countEnergized;

export const throwRay: (pos:xy, movement:xy) => number = DaySixteen23BS.throwRay;
