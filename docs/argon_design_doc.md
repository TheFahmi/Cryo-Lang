# Argon Language: Architecture & Design

**Version:** 2.2.0 (Self-Hosted & Stable)
**Status:** Production Ready (Self-Hosting Verified)
**Backend:** LLVM 15+
**Last Updated:** 2025-12-28

---

## 1. Introduction
Argon is a high-performance, self-hosted systems programming language designed to provide memory safety without a Garbage Collector (GC) or the complexity of Rust's lifetime annotations. It achieves this through **Region-Based Memory Management (RBMM)** and **Linear Capabilities**.

Argon has reached a major milestone: **Verified Self-Hosting**. The compiler (`compiler.ar`) is written in Argon itself, can compile itself, and produces **byte-for-byte identical output** when compiled by itself (Stage 1 == Stage 2).

---

## 2. Core Concepts

### 2.1 Region-Based Memory Management (RBMM)
Instead of tracking individual object lifetimes, Argon groups allocations into **Regions** (Arenas).
- **Allocations**: Simply bump a pointer in the current region (O(1)).
- **Deallocations**: Free the entire region at once when it goes out of scope (O(1)).
- **Safety**: The compiler ensures no reference outlives its region.

### 2.2 Linear Capabilities
Resources like Sockets, File Handles, or Unique Pointers are **Linear**.
- **Must be used exactly once** (moved) or explicitly closed.
- Prevents resource leaks at compile time.

### 2.3 Data Representation (Tagged Pointers)
Creating a truly self-hosted dynamic system required a uniform data representation. Use of **Tagged Integers** avoids heap allocation for small numbers:
- **Integers**: Represented as `(n << 1) | 1`. The lowest bit is always `1`.
- **Pointers**: Represented as raw 64-bit addresses. The lowest bit is always `0` (due to alignment).
- **Booleans**: `true` is represented as `3` (integer 1), and `false` as `1` (integer 0).
- **Null**: Represented as `0`.

---

## 3. Architecture

### 3.1 The Compiler (`compiler.ar`)
The compiler is a monolithic application written in Argon (~1650 lines).
1.  **Lexer**: Tokenizes source code (`.ar` files), handling complex string escapes and operators.
2.  **Parser**: Recursive Descent parser generating a lightweight AST. Includes support for `if/else if/else`, `while` loops, `break/continue`, and function definitions.
3.  **Code Generator**: Emits LLVM IR (Text format). Uses tagged integer arithmetic.
    - **Fast Path Optimization**: Detects integer parsing at compile time to emit native LLVM instructions (`add`, `sub`, `icmp`) instead of runtime calls, guarding them with runtime type checks.
    - **Stage Detection**: Automatically detects if running in Stage 0 (Rust interpreter) or Stage 1+ (compiled) to handle number tagging correctly.
4.  **Backend**: Invokes `clang++` to optimize LLVM IR and link with the runtime.

### 3.2 The Runtime (`runtime.rs`)
A minimal runtime written in Rust (compiled to `libruntime_argon.a`).
- Provides Intrinsics: `argon_str_new`, `argon_print`, `argon_add`, `argon_eq`.
- File I/O: `argon_read_file`, `argon_write_file`, `argon_file_exists`.
- Networking: `argon_listen`, `argon_accept`, `argon_socket_read`.
- Memory: Bump allocator primitives.

### 3.3 The Toolchain (`argon`)
A Docker-based wrapper ensuring consistent builds across Windows, Linux, and Mac.
- **Scaffolding**: `argon new` generates MVC project structures.
- **Bundler**: Merges source files for compilation.
- **Builder**: Compiles and Links native binaries.

---

## 4. Self-Hosting Details

### 4.1 Bootstrap Process
```
Stage 0: Rust Interpreter runs compiler.ar → generates compiler.ar.ll
Stage 1: clang links compiler.ar.ll → stage1.out (native binary)
Stage 2: stage1.out compiles compiler.ar → compiler.ar.ll (IDENTICAL to Stage 1)
```

### 4.2 Key Challenges Solved
1. **Number Tagging Consistency**: Stage 0 (Rust) returns raw integers from `parseInt()`, while Stage 1+ returns tagged integers. Solved with `detect_stage()` function.
2. **String Comparison**: Runtime `argon_eq` compares string *content*, not pointer addresses.
3. **Control Flow**: Proper handling of `if/else`, `while`, `break`, `continue` with correct LLVM IR basic blocks.

### 4.3 Verification
- Stage 1 compiling itself produces **identical output** each time
- ~9000 tokens, 110 functions, ~240KB of LLVM IR generated

---

## 5. Syntax & Features

### 5.1 Basic Syntax
```typescript
fn main() {
    let x = 10;
    print("Hello: " + x);
}
```

### 5.2 Networking (v2.1)
```typescript
fn start_server() {
    let s = argon_listen(3000);
    while (1) {
        let c = argon_accept(s);
        if (c != -1) {
             argon_socket_write(c, "HTTP/1.1 200 OK\r\n\r\nHello");
             argon_socket_close(c);
        }
    }
}
```

### 5.3 MVC Structure
Argon v2.1 promotes structured backend development:
- `controllers/`: Request handling.
- `services/`: Business logic.
- `models/`: Data persistence.

---

## 6. Roadmap
1.  [x] Self-Hosting (v1.0)
2.  [x] Native Networking (v2.1)
3.  [x] Tagged Integer Optimization
4.  [x] Verified Self-Hosting - Stage 1 == Stage 2 (v2.2)
5.  [ ] Multi-threading support (Arc/Mutex)
6.  [ ] Advanced Type System (Generics/Traits)
7.  [ ] Struct/Enum types
8.  [ ] Package Manager (dependency resolution)
9.  [ ] LSP (Language Server Protocol) for IDE support
