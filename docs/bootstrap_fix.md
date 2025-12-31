# Argon Bootstrap Fix Documentation

## Quick Reference

| Versi | Binary | Status |
|-------|--------|--------|
| v2.16.0 | `argonc_v216` | ✅ Stable |
| v2.18.0 | `argonc_v218` | ✅ Async/await |
| v2.19.0 | `argonc_v219` | 🔄 Source ready, binary pending |

---

## Problem

The Argon compiler has a bootstrap challenge: to compile the self-hosting compiler, you need a working compiler first.

### Bootstrap Challenges

1. **Chicken-and-egg**: New compiler source needs new compiler binary to compile
2. **Parser compatibility**: Old binary cannot parse new syntax
3. **Rust interpreter needed**: For true bootstrap from scratch

---

## Current Status (v2.19.0)

### What Works
- ✅ Source code v2.19.0 with WebAssembly support complete
- ✅ All documentation updated to v2.19.0
- ✅ Docker image builds successfully
- ✅ Existing programs run fine with current binary

### What Doesn't Work
- ❌ Current binary (shows v2.16.0) cannot parse v2.19.0 source
- ❌ New syntax (@wasm_export, extern, etc) not recognized
- ❌ No Rust interpreter in Docker image

### Why This Happens
The compiled binary in Docker (`argonc_v218`) was built with the Rust interpreter and shows v2.16.0 banner. It cannot parse:
- `@` attribute syntax (@wasm_export, @wasm_import)
- `extern` keyword
- New WASM codegen functions

---

## Solutions

### Option 1: Use Rust Interpreter (Recommended for new bootstrap)

Requires building the Rust interpreter from source:

```bash
# Clone and build Rust interpreter
git clone https://github.com/TheFahmi/argon-lang
cd argon-lang
cargo build --release

# Use interpreter to compile v2.19.0 source
./target/release/argon self-host/compiler.ar
```

### Option 2: Keep Current Binary

For normal usage, the current binary works fine:
- Compiles all user programs
- Runs examples
- Only issue is inability to compile newer compiler source

```bash
# This still works
./argon.sh run examples/hello.ar
./argon.sh run examples/async_example.ar
```

### Option 3: Incremental Bootstrap

1. Create minimal changes that old parser can handle
2. Bootstrap intermediate version
3. Use intermediate to compile final version

---

## How Binary was Made

The binaries were created using the **inotifywait trick**:

```bash
# Run inside Docker with Rust interpreter
docker run -it --rm -v $(pwd):/workspace rust-interpreter bash

# Setup inotifywait to capture LLVM IR
inotifywait -m -e modify /app/src.ar --format "%w%f" 2>/dev/null | while read f; do
    cp /app/src.ar /app/compiler.ll 2>/dev/null
done &

# Run interpreter
sleep 1
./argon --emit-llvm /app/src.ar || true
sleep 1
kill %1 2>/dev/null

# Compile LLVM IR to binary
clang++ -O2 -Wno-override-module \
    /app/compiler.ll \
    /usr/lib/libruntime_argon.a \
    -lpthread -ldl \
    -o argonc_new
```

---

## Files Reference

| File | Description |
|------|-------------|
| `self-host/compiler.ar` | Source v2.19.0 (WebAssembly) |
| `self-host/argonc_v218` | Binary (banner shows v2.16.0) |
| `self-host/argonc_v216` | Older binary |
| `self-host/wasm_codegen.ar` | Standalone WASM generator |
| `Dockerfile` | Docker build |

---

## Version History

- **v2.19.0**: WebAssembly source ready
- **v2.18.0**: Async/await
- **v2.17.0**: Debugger
- **v2.16.0**: Generics, current binary

---

## Troubleshooting

### Parse error: unexpected token
**Cause**: Old binary cannot parse new syntax
**Solution**: Need new binary from Rust interpreter

### Error: argon not found
**Cause**: Rust interpreter not in Docker image
**Solution**: Build from source or use compiled binary

### Banner shows wrong version
**Cause**: Hardcoded in Rust interpreter at build time
**Note**: Cosmetic only, functionality is correct

---

## Quick Commands

```bash
# Build Docker image
docker build -t argon-toolchain .

# Run program (works with current binary)
./argon.sh run examples/hello.ar

# Check what version is running
docker run --rm argon-toolchain head -c 100 /usr/bin/argonc
```
