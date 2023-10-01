type parsedPath = {
  root: string,
  dir: string,
  base: string,
  ext: string,
  name: string,
}

@module("path") external parse: string => parsedPath = "parse"
