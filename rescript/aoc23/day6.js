// A great day to chill, here is a hacky tacky solution.

function main(time, win) {
  let t = time; // assign a value to t variable
  let d = win; // assign a value to d variable

  let x1 = (-t - Math.sqrt(Math.pow(t, 2) - 4 * (-1) * (-d))) / (2 * (-1));
  let x2 = (-t + Math.sqrt(Math.pow(t, 2) - 4 * (-1) * (-d))) / (2 * (-1));

  // console.log("x1 =", x1);
  // console.log("x2 =", Math.ceil(x2 - x1));


  let counter = 0;
  for (let i = 0; i < (time); i++) {

    let dist = i * (time - i)
    // console.log(`${i} * (${time} - ${i}) = ${dist}`)
    // console.log(lp, i, dist)

    if (dist > win)
      counter += 1
  }

  console.log("x2 =", counter, (Math.ceil(x1) - Math.floor(x2)) - 1);
  return (Math.ceil(x1) - Math.floor(x2)) - 1
}

// let d = (t - x) * x



var example = [
  [7, 9],
  [15, 40],
  [30, 200],
].reduce((mul, [time, win]) => mul * main(time, win), 1)

console.log("Result", example)





// var inp = [
//   [58, 478],
//   [99, 2232],
//   [64, 1019],
//   [69, 1071]
// ].reduce((mul, [time, win]) => mul * main(time, win), 1)
// console.log("Result", inp)

var inp = [
  [58996469, 478223210191071],
].reduce((mul, [time, win]) => mul * main(time, win), 1)
console.log("Result", inp)




