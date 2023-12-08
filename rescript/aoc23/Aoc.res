let toLines = (str, ~start=0, ~end=-1) =>
  String.trim(str)->String.split("\n")->Array.slice(~start, ~end)
let toLinesEnd = (str, ~start=0) => String.trim(str)->String.split("\n")->Array.sliceToEnd(~start)
let lineAt = (str, index, ~start=0) => toLines(str, ~start)->Array.at(index)
