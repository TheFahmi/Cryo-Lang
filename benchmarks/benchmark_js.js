
function fib(n) {
    if (n < 2) return n;
    return fib(n - 1) + fib(n - 2);
}

console.log("Fibonacci(40):");
console.log(fib(40));

console.log("\nLoop 100M iterations:");
let sum = 0;
let i = 0;
while (i < 100000000) {
    sum += i;
    i++;
}
console.log(sum);
