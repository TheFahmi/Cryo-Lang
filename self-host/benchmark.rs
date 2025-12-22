#![allow(unused_variables)]
#![allow(unused_assignments)]
use std::time::Instant;
fn main() {
    let _arg_start = Instant::now();
    // Function fib skipped
    println!("{}", 0 /* Unimplemented Expr */);
    println!("{}", 0 /* Unimplemented Expr */);
    println!("{}", 0 /* Unimplemented Expr */);
    let mut result = 0 /* Call Expr */;
    println!("{}", result);
    println!("{}", 0 /* Unimplemented Expr */);
    println!("{}", 0 /* Unimplemented Expr */);
    let mut sum = 0i64;
    let mut i = 0i64;
    while i < 1000000i64 {
        sum = sum + i;
        i = i + 1i64;
    }
    println!("{}", sum);
    println!("{}", 0 /* Unimplemented Expr */);
    println!("{}", 0 /* Unimplemented Expr */);
    println!("Argon Exec Time: {:.4}ms", _arg_start.elapsed().as_secs_f64() * 1000.0);
}
