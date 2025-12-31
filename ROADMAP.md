# Argon Roadmap

Argon is evolving rapidly. This document outlines the current state and future milestones for the language.

## ✅ Phase 1: Foundation (v1.0 - v2.25) [COMPLETED]
The core infrastructure is now stable and performant.

- **Runtime**:
    - [x] Tree-walk Interpreter
    - [x] Bytecode VM (Register-based, ~16x faster)
    - [x] Optimized HashMaps (`FxHashMap`)
    - [x] Standard Library (Math, String, Array, IO, Net)
- **Compiler**:
    - [x] Self-hosted Compiler (`argonc`)
    - [x] LLVM IR Backend (`native` target)
    - [x] WebAssembly Backend (`wasm32` / `wasi` target)
- **Tooling**:
    - [x] Package Manager (`apm`)
    - [x] Build System (`build.sh`)
    - [x] VS Code Extension (Syntax Highlighting)
    - [x] REPL

---

## ✅ Phase 2: Language Features (v2.26 - v2.28) [COMPLETED]
Advanced language features for production software.

### ✅ 1. Traits & Interfaces [v2.26.0]
- [x] `TraitDef` in runtime
- [x] `impl Trait for Type` support
- [x] Method dispatch with polymorphism

### ✅ 2. FFI (Foreign Function Interface) [v2.27.0]
- [x] `libloading` crate integration
- [x] `ffi_load()` and `ffi_call()` built-ins
- [x] Load .dll/.so dynamically

### ✅ 3. Garbage Collection [v2.28.0]
- [x] Mark-and-Sweep GC module
- [x] `gc_collect()` and `gc_stats()` built-ins
- [x] Object header & heap arena

---

## ✅ Phase 3: Developer Experience (v2.29) [COMPLETED]
Focus on tooling and developer productivity.

### ✅ 1. Language Server Protocol (LSP)
- [x] Diagnostics (syntax errors)
- [x] Hover (function signatures)
- [x] Go to Definition (Ctrl+Click)
- [x] Find References (Shift+F12)
- [x] Autocomplete with snippets
- [x] Signature help (parameter hints)
- [x] Document formatting

### ✅ 2. Debugger Support
- [x] DWARF debug info in LLVM IR
- [x] `-g` / `--debug` compiler flag
- [x] GDB/LLDB integration
- [x] Breakpoints & variable inspection

---

## 🚀 Phase 4: Enterprise Features (v3.0+) [IN PROGRESS]
Focus on ecosystem and enterprise readiness.

### ✅ Standard Library Expansion [COMPLETED]
- [x] `crypto` module (randomBytes, UUID, hash, HMAC, base64)
- [x] `http` module (Router, Request/Response, CORS, cookies)
- [x] `sql` module (in-memory database with CRUD operations)
- [x] `async` module (Future, async utilities)

### ✅ Concurrency [COMPLETED]
- [x] Channel-based communication (`channel` module)
- [x] Worker-based parallelism (`worker` module)
- [x] Spawn/Join semantics
- [x] Work-stealing queues
- [x] Pipeline patterns
- [x] **True OS Threading** (native `std::thread`)
  - [x] `thread_spawn()` / `thread_join()` built-ins
  - [x] `channel_new()` / `channel_send()` / `channel_recv()` built-ins
  - [x] Non-blocking `channel_try_recv()` and `channel_recv_timeout()`

### ✅ Tooling [COMPLETED]
- [x] Documentation generator (`argondoc`)
- [x] Code formatter (`argonfmt`)
- [ ] Package registry (apm.argon.dev)

---

## 🚀 Phase 5: Ecosystem (v3.1+) [IN PROGRESS]
Building a thriving developer ecosystem.

### ✅ Web Framework (`argonweb`) [COMPLETED]
- [x] Express-like HTTP server
- [x] NestJS-style architecture
- [x] Router with route parameters (`:id`)
- [x] Query string parsing
- [x] Middleware pipeline
- [x] Built-in middleware (Logger, CORS, JSON parser)
- [x] Response helpers (responseOk, responseError, etc.)
- [x] Context API (json, html, redirect, params)
- [x] Template Engine (EJS/Jinja2-style)
  - [x] Variable interpolation `{{ name }}`
  - [x] Conditionals `{% if %}...{% endif %}`
  - [x] Loops `{% for item in items %}`
  - [x] Includes `{% include "partial" %}`
  - [x] Filters `{{ name | upper }}`
  - [x] Layout inheritance `{% extends "base" %}`
- [x] WebSocket support
  - [x] WebSocket server
  - [x] Frame encoding/decoding
  - [x] Handshake protocol
  - [x] Broadcast messaging

### Package Registry
- [ ] `apm.argon.dev` web portal
- [ ] Package publishing workflow
- [ ] Version management & semver
- [ ] Dependency resolution

### Database Connectors
- [ ] PostgreSQL driver
- [ ] MySQL driver
- [ ] Redis client

---

## Release Schedule
| Version | Feature | Status |
|---------|---------|--------|
| v2.25.0 | Performance & Stdlib | ✅ |
| v2.26.0 | Traits & Interfaces | ✅ |
| v2.27.0 | FFI Support | ✅ |
| v2.28.0 | Garbage Collector | ✅ |
| v2.29.0 | LSP & Debugger | ✅ |
| v3.0.0  | Enterprise Stdlib | ✅ |
| v3.0.1  | Concurrency (channel, worker) | ✅ |
| v3.1.0  | True OS Threading | ✅ |
| v3.1.1  | ArgonWeb Framework | ✅ (Current) |
| v3.2.0  | Package Registry | 🔮 Next |
| v3.3.0  | Database Connectors | 🔮 Planned |
