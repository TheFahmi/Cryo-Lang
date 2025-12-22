fn fib(n: i64) -> i64 {
    if (n < 2) {
        return n;
    }
    fib(n - 1) + fib(n - 2)
}

fn consume_stack(limit: i64, d: i64, a: i64, b: i64, c: i64, e: i64, f: i64, g: i64, h: i64, i: i64) -> i64 {
    if d >= limit {
        return d;
    }
    consume_stack(limit, d + 1, a+1, b+1, c+1, e+1, f+1, g+1, h+1, i+1)
}

fn main() {
    println!("Fib(50):");
    println!("{}", fib(50));

    println!("Loop 10 Billion:");
    let mut sum: i64 = 0;
    let mut i: i64 = 0;
    while i < 10000000000 {
        sum += i;
        i += 1;
    }
    println!("{}", sum);
    
    println!("TCO Stack Dive (10M depth):");
    println!("{}", consume_stack(10000000, 0, 1, 2, 3, 4, 5, 6, 7, 8));
}
