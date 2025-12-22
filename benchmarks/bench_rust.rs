use std::time::Instant;
fn main() {
    let start = Instant::now();
    let mut sum: i64 = 0;
    let mut i: i64 = 0;
    while i < 1_000_000 {
        sum += 1;
        i += 1;
    }
    let duration = start.elapsed();
    println!("Rust Native : {:.4} ms", duration.as_secs_f64() * 1000.0);
}
