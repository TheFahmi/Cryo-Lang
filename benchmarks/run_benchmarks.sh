#!/bin/bash

echo "=== BENCHMARK ARENA: GOD TIER ==="
echo "Workload: Fib(50) + 10B Loop + 10M Recursion (TCO)"
echo "Target: ~1 Minute Execution"
echo ""

# Just 1 iteration
echo "============================================="
echo "   Start the Race..."
echo "============================================="

echo "--- 1. C++ (Clang -O3) ---"
./bench_runner ./benchmark_cpp
echo ""

echo "--- 2. Rust Native ---"
./bench_runner ./benchmark_rust_bin
# Compile the heavy benchmark using our self-hosted compiler
echo "Transpiling Argon Source..."

# Use the stage1 compiler if available, otherwise fall back to interpreter
if [ -f "./stage1_compiler" ]; then
    ./stage1_compiler --unsafe-math self-host/fib_poly.argon > /dev/null 2>&1
elif [ -f "/app/stage1_compiler" ]; then
    /app/stage1_compiler --unsafe-math self-host/fib_poly.argon > /dev/null 2>&1
else
    # Fallback: use Argon interpreter directly to emit LLVM IR
    ./argon --emit-llvm self-host/fib_poly.argon > self-host/fib_poly.argon.ll 2>/dev/null
fi

if [ -f "self-host/fib_poly.argon.ll" ]; then
    echo "--- 3. Argon Self-Hosted (Rust Runtime) ---"
    
    # Compile Rust Runtime
    rustc --crate-type staticlib -O -o libruntime_rust.a self-host/runtime.rs
    
    # Link Argon LLVM + Rust Runtime
    # Explicitly static link libstdc++ if needed, or just let clang handle it?
    # Rust runtime depends on pthread/dl.
    clang++ -O3 -march=native -flto -Wno-override-module self-host/fib_poly.argon.ll libruntime_rust.a -o benchmark_argon -lpthread -ldl
    
    ./bench_runner ./benchmark_argon
else
    echo "Compilation failed."
fi
echo ""
