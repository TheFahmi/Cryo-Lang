---
description: How to add a new language feature to Argon
---

# Adding New Language Features

## 1. Update Lexer

Edit `src/lexer.rs`:
- Add new token to `Token` enum
- Add keyword mapping in `tokenize()` function

## 2. Update Parser

Edit `src/parser.rs`:
- Add AST node to `Expr` or `Stmt` enum
- Add parsing logic in appropriate parse function
- Update `TopLevel` if it's a top-level construct

## 3. Update Interpreter

Edit `src/interpreter.rs`:
- Add evaluation logic for new AST node
- Handle runtime semantics

## 4. Update Native Compiler (Optional)

Edit `src/native_compiler.rs`:
- Add LLVM IR generation for new construct

## 5. Add Tests

Create example in `examples/`:
```bash
./argon.exe examples/new_feature.ar
```

## 6. Update Documentation

- Update `docs/` with design document
- Update `AGENTS.md` if relevant
- Update `README.md` if user-facing

## Key Files

| Purpose | File |
|---------|------|
| Tokens | `src/lexer.rs` |
| AST | `src/parser.rs` |
| Execution | `src/interpreter.rs` |
| LLVM IR | `src/native_compiler.rs` |
| Optimizations | `src/optimizer.rs` |
| Macros | `src/expander.rs` |
