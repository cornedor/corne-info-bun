@module("glob") external glob: string => promise<array<string>> = "glob"
