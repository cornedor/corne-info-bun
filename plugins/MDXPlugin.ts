import type { BunPlugin } from "bun";
import { compile } from "@mdx-js/mdx";

export const mdxPlugin: BunPlugin = {
  name: "MDX Loader",
  setup(build) {
    build.onLoad({ filter: /\.mdx$/ }, async (args) => {
      const text = await Bun.file(args.path).text();

      const compiled = compile(text, {
        jsxImportSource: "preact",
        jsxRuntime: "automatic",
      });

      return {
        contents: (await compiled).toString(),
        loader: "js",
      };
    });
  },
};
