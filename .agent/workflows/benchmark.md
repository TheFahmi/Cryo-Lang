---
description: How to run Argon benchmarks
---

# Benchmark Workflow

## Quick Benchmark

// turbo
1. Native Rust baseline (target: ~40ms for N=35):
```bash
./argon.exe --native-bench 35
```

// turbo
2. Bytecode VM benchmark:
```bash
./argon.exe --vm-bench 35
```

## Full Benchmark Suite

3. Build Docker image:
```bash
docker build -t argon-bench .
```

4. Run Docker benchmarks:
```bash
docker run --rm argon-bench
```

## Comparison Benchmarks

5. Navigate to benchmark directory and run:
```bash
cd benchmarks/comparison && ./run.sh
```

## Expected Results (Fib 35)

| Mode | Expected Time |
|------|---------------|
| Native Rust | ~40ms |
| Bytecode VM | ~3500ms |
