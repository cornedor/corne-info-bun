/* TypeScript file generated from Grid2D.res by genType. */

/* eslint-disable */
/* tslint:disable */

import * as Grid2DBS from './Grid2D';

import type {HashMap_t as Belt_HashMap_t} from './Belt.gen';

import type {ref as PervasivesU_ref} from './PervasivesU.gen';

export type position = [number, number];

export abstract class PositionHash_identity { protected opaque!: any }; /* simulate opaque types */

export type PositionHash_t = position;

export type gridMap<a> = Belt_HashMap_t<PositionHash_t,a,PositionHash_identity>;

export type grid<a> = {
  readonly width: (undefined | number); 
  readonly height: (undefined | number); 
  readonly map: gridMap<a>; 
  readonly maxX: PervasivesU_ref<number>; 
  readonly maxY: PervasivesU_ref<number>; 
  readonly minX: PervasivesU_ref<number>; 
  readonly minY: PervasivesU_ref<number>
};

export const forEach: <a>(grid:grid<a>, fn:((_1:PositionHash_t, _2:a) => void)) => void = Grid2DBS.forEach as any;
