// import { compile } from "@mdx-js/mdx";

@module("@mdx-js/mdx") external compileString: (string, 'b) => promise<'a> = "compile"
