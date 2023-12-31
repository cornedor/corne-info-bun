import * as esbuild from 'esbuild'
import { glob } from 'glob'
import mdx from '@mdx-js/esbuild'

const entries = await glob("{pages,client}/**/*.{ts,tsx,js,mdx}")
await esbuild.build({
  entryPoints: entries,
  bundle: true,
  splitting: true,
  treeShaking: true,
  minify: true,
  format: 'esm',
  sourcemap: "linked",
  outdir: '_s',
  external: ["bun:sqlite"],
  loader: {
    '.js': 'jsx'
  },
  plugins: [mdx({
    jsxImportSource: 'preact',
    jsxRuntime: 'automatic',
  })],
  define: {
    CLIENTSIDE: 'true'
  }
})

console.log("Build done!", new Date())
