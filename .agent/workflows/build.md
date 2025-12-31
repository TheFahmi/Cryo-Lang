---
description: How to build and test the Argon compiler
---

# Build and Test Workflow

## Build

// turbo
1. Build release binary:
```bash
cargo build --release
```

## Verify

// turbo
2. Check version:
```bash
./target/release/argon.exe --version
```

// turbo
3. Run benchmark (target: ~40ms):
```bash
./target/release/argon.exe --native-bench 35
```

// turbo
4. Run hello world:
```bash
./target/release/argon.exe examples/hello.ar
```

## Copy Binary (Optional)

5. Copy to project root:
```bash
cp target/release/argon.exe argon.exe
```
