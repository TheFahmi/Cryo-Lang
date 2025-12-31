#!/bin/bash
# Argon Build Script
# Compile .ar files to native binaries or WASM

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ARGON="./argon.exe"
COMPILER="./self-host/compiler.ar"
BUILD_DIR="./build"

usage() {
    echo -e "${BLUE}Argon Build Tool${NC}"
    echo ""
    echo "Usage: ./build.sh [command] [options]"
    echo ""
    echo "Commands:"
    echo "  compile <file.ar>     Compile to LLVM IR"
    echo "  native <file.ar>      Compile to native binary"
    echo "  wasm <file.ar>        Compile to WebAssembly"
    echo "  run <file.ar>         Run with interpreter"
    echo "  clean                 Clean build directory"
    echo ""
    echo "Options:"
    echo "  -o, --output <path>   Output path"
    echo "  -O, --optimize        Enable optimizations"
    echo ""
    echo "Examples:"
    echo "  ./build.sh compile examples/hello.ar"
    echo "  ./build.sh native examples/fib.ar -O"
    echo "  ./build.sh wasm examples/game.ar"
}

ensure_dirs() {
    mkdir -p "$BUILD_DIR/llvm"
    mkdir -p "$BUILD_DIR/wasm"
    mkdir -p "$BUILD_DIR/bin"
}

get_basename() {
    local file="$1"
    local base=$(basename "$file" .ar)
    echo "$base"
}

compile_llvm() {
    local input="$1"
    local output="$2"
    local base=$(get_basename "$input")
    
    if [ -z "$output" ]; then
        output="$BUILD_DIR/llvm/${base}.ll"
    fi
    
    echo -e "${YELLOW}Compiling${NC} $input -> $output"
    $ARGON $COMPILER "$input" -o "$output"
    echo -e "${GREEN}✓${NC} LLVM IR generated: $output"
}

compile_native() {
    local input="$1"
    local output="$2"
    local optimize="$3"
    local base=$(get_basename "$input")
    local llvm_file="$BUILD_DIR/llvm/${base}.ll"
    
    if [ -z "$output" ]; then
        output="$BUILD_DIR/bin/${base}"
    fi
    
    # First compile to LLVM IR
    compile_llvm "$input" "$llvm_file"
    
    # Then compile to native
    echo -e "${YELLOW}Linking${NC} $llvm_file -> $output"
    
    if [ "$optimize" = "true" ]; then
        clang -O3 -march=native "$llvm_file" -o "$output"
    else
        clang -O2 "$llvm_file" -o "$output"
    fi
    
    echo -e "${GREEN}✓${NC} Native binary: $output"
}

compile_wasm() {
    local input="$1"
    local output="$2"
    local base=$(get_basename "$input")
    local wat_file="$BUILD_DIR/wasm/${base}.wat"
    
    if [ -z "$output" ]; then
        output="$BUILD_DIR/wasm/${base}.wasm"
    fi
    
    echo -e "${YELLOW}Compiling${NC} $input -> $wat_file"
    $ARGON $COMPILER "$input" --wasm -o "$wat_file"
    
    echo -e "${YELLOW}Assembling${NC} $wat_file -> $output"
    wat2wasm "$wat_file" -o "$output"
    
    echo -e "${GREEN}✓${NC} WebAssembly: $output"
}

run_interp() {
    local input="$1"
    echo -e "${BLUE}Running${NC} $input"
    $ARGON "$input"
}

clean_build() {
    echo -e "${YELLOW}Cleaning${NC} build directory..."
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR/llvm" "$BUILD_DIR/wasm" "$BUILD_DIR/bin"
    echo -e "${GREEN}✓${NC} Build directory cleaned"
}

# Parse arguments
COMMAND=""
INPUT=""
OUTPUT=""
OPTIMIZE="false"

while [[ $# -gt 0 ]]; do
    case $1 in
        compile|native|wasm|run|clean)
            COMMAND="$1"
            shift
            ;;
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        -O|--optimize)
            OPTIMIZE="true"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            if [ -z "$INPUT" ]; then
                INPUT="$1"
            fi
            shift
            ;;
    esac
done

# Execute command
ensure_dirs

case $COMMAND in
    compile)
        if [ -z "$INPUT" ]; then
            echo -e "${RED}Error:${NC} No input file specified"
            exit 1
        fi
        compile_llvm "$INPUT" "$OUTPUT"
        ;;
    native)
        if [ -z "$INPUT" ]; then
            echo -e "${RED}Error:${NC} No input file specified"
            exit 1
        fi
        compile_native "$INPUT" "$OUTPUT" "$OPTIMIZE"
        ;;
    wasm)
        if [ -z "$INPUT" ]; then
            echo -e "${RED}Error:${NC} No input file specified"
            exit 1
        fi
        compile_wasm "$INPUT" "$OUTPUT"
        ;;
    run)
        if [ -z "$INPUT" ]; then
            echo -e "${RED}Error:${NC} No input file specified"
            exit 1
        fi
        run_interp "$INPUT"
        ;;
    clean)
        clean_build
        ;;
    *)
        usage
        exit 1
        ;;
esac
