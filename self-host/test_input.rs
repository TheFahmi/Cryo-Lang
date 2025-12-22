#![allow(unused_variables)]
#![allow(unused_assignments)]
use std::time::Instant;
fn main() {
    let _arg_start = Instant::now();
    let mut x = 10i64;
    let mut y = 20i64;
    println!("{}", x + y);
    println!("Argon Exec Time: {:.4}ms", _arg_start.elapsed().as_secs_f64() * 1000.0);
}
