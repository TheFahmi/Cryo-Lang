#!/bin/bash
set -e

echo "============================================="
echo "   ARGON BOOTSTRAP (Rust Interpreter)"
echo "============================================="
echo ""

# Compile runtime
echo "[Runtime] Compiling Rust Runtime..."
rustc --crate-type staticlib -O -o libruntime_rust.a self-host/runtime.rs

# Use Rust interpreter to compile the Argon compiler
echo ""
echo "[Stage 0] Compiling compiler.argon with Rust Interpreter..."

# Clean up old files
rm -f self-host/compiler.ll self-host/compiler.argon.ll compiler_stage0.ll

# Append newline to source to avoid EOF parsing issues
echo "" >> self-host/compiler.argon

# Use the interpreter to compile the compiler source code
echo "Running: ./argon --emit-llvm self-host/compiler.argon"
./argon --emit-llvm self-host/compiler.argon
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "Error: Stage 0 compilation failed."
    exit 1
fi

# Find output - interpreter writes to file, not stdout
if [ -f "self-host/compiler.argon.ll" ]; then
    mv self-host/compiler.argon.ll compiler_stage0.ll
    echo "Found output at self-host/compiler.argon.ll"
elif [ -f "self-host/compiler.ll" ]; then
    mv self-host/compiler.ll compiler_stage0.ll
    echo "Found output at self-host/compiler.ll"
elif [ -f "compiler.argon.ll" ]; then
    mv compiler.argon.ll compiler_stage0.ll
    echo "Found output at compiler.argon.ll"
fi

echo "Generated IR:"
if [ -f "compiler_stage0.ll" ]; then
    wc -l compiler_stage0.ll
    head -20 compiler_stage0.ll
else
    echo "ERROR: No IR file generated!"
    ls -la self-host/
    ls -la *.ll 2>/dev/null || echo "No .ll files in current dir"
    exit 1
fi

# Link to create argonc
echo ""
echo "[Link] Creating argonc binary..."
clang++ -O0 -Wno-override-module compiler_stage0.ll libruntime_rust.a -o argonc -lpthread -ldl
echo ">> argonc created!"

# Test with simple file
echo ""
echo "[Test] Testing argonc..."
echo 'fn main() { print(42); }' > test_simple.argon
./argonc test_simple.argon

if [ -f "test_simple.argon.ll" ]; then
    echo ">> Compilation successful!"
    clang++ -O0 -Wno-override-module test_simple.argon.ll libruntime_rust.a -o test_simple -lpthread -ldl
    echo "Running test_simple:"
    ./test_simple
else
    echo ">> ERROR: No output generated"
    exit 1
fi

echo ""
echo "============================================="
echo "   BOOTSTRAP COMPLETE"
echo "============================================="
