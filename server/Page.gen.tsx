/* TypeScript file generated from Page.res by genType. */
/* eslint-disable import/first */


import type {Json_t as Js_Json_t} from './Js.gen';

// tslint:disable-next-line:interface-over-type-literal
export type getPropsFn = () => Promise<Js_Json_t>;

// tslint:disable-next-line:interface-over-type-literal
export type pageConfig = {
  readonly title?: string; 
  readonly useBaseLayout?: boolean; 
  readonly statusCode?: number; 
  readonly getProps?: getPropsFn; 
  readonly revalidate?: number
};
