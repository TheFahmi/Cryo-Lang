const start = performance.now();
let sum = 0, i = 0;
while (i < 1000000) { sum++; i++; }
const end = performance.now();
console.log(`JavaScript  : ${(end - start).toFixed(4)} ms`);
