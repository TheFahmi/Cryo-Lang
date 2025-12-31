# Argon Bootstrap Fix Documentation

## Quick Reference

| Versi | Binary | Status |
|-------|--------|--------|
| v2.16.0 | `argonc_v216` | ✅ Stable |
| v2.18.0 | `argonc_v218` | ✅ In Docker (async/await) |
| v2.19.0 | - | ⚠️ Source only (needs new interpreter) |

---

## Current Situation

### What Works ✅
- **Docker image** builds successfully with `argonc_v218`
- **All user programs** compile and run correctly
- **Source code v2.19.0** is complete with WebAssembly support
- **Examples** all work: `hello.ar`, `async_example.ar`, etc.

### What Doesn't Work ❌
- **v2.19.0 binary** cannot be bootstrapped
- **Rust interpreter** (`argon`) is outdated and cannot parse any recent compiler source
- **WASM target** is in source but not accessible without new binary

---

## Why Bootstrap Fails

The `argon` binary (Rust interpreter) in the repository is **very outdated**. It cannot parse:
- v2.19.0 source (WebAssembly features)
- v2.18.0 source (async/await)
- v2.17.0 source (debugger)
- v2.16.0 source (generics)

Even the oldest recent version fails with parse errors.

---

## Solution Required

To enable full v2.19.0 bootstrap, we need to:

### Option 1: Update Rust Interpreter Source
```bash
# Need to add Rust source to repo and update lexer/parser
# to match current Argon syntax

# Then rebuild interpreter:
cargo build --release
cp target/release/argon ./argon
```

### Option 2: Manual LLVM Generation
If you have access to a working interpreter that can parse the source:
```bash
./working_argon self-host/compiler.ar
# This overwrites compiler.ar with LLVM IR
# Use inotifywait to capture before deletion
```

### Option 3: Continue with v2.18 Binary
The current setup works fine for all practical purposes:
```bash
./argon.sh run examples/hello.ar
./argon.sh build program.ar -o program
```

---

## Current Dockerfile

```dockerfile
# Uses pre-built argonc_v218 binary
COPY self-host/argonc_v218 /usr/bin/argonc
```

This is the **only working solution** until the Rust interpreter is updated.

---

## Files in Repository

| File | Description |
|------|-------------|
| `argon` | Rust interpreter (OUTDATED - cannot parse recent source) |
| `self-host/argonc_v218` | Compiled v2.18 binary (WORKS) |
| `self-host/argonc_v216` | Compiled v2.16 binary (WORKS) |
| `self-host/compiler.ar` | v2.19.0 source with WebAssembly |
| `self-host/runtime.rs` | Runtime library source |

---

## Version History

| Version | Features | Binary Available |
|---------|----------|-----------------|
| v2.19.0 | WebAssembly, WASM codegen | ❌ Source only |
| v2.18.0 | Async/await | ✅ `argonc_v218` |
| v2.17.0 | Debugger support | (included in v218) |
| v2.16.0 | Generic types | ✅ `argonc_v216` |

---

## Quick Commands

```bash
# Build Docker image
docker build -t argon-toolchain .

# Run program
docker run --rm -v //d/rust:/ws argon-toolchain bash -c "cd /ws; argonc examples/hello.ar"

# Run compiled program  
docker run --rm -v //d/rust:/ws argon-toolchain bash -c "cd /ws; clang examples/hello.ar.ll -o hello; ./hello"
```
