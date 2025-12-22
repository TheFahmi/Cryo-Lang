#![allow(unused_variables)]
#![allow(unused_assignments)]
use std::time::Instant;
fn main() {
    let _arg_start = Instant::now();
    let mut sum = 0i64;
    let mut i = 0i64;
    while i < 1000000i64 {
        sum = sum + 1i64;
        i = i + 1i64;
    }
    println!("{}", sum);
    println!("Argon Exec Time: {:.4}ms", _arg_start.elapsed().as_secs_f64() * 1000.0);
}
