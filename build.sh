#!/bin/bash
# Argon Build Script - Simple Version
# Run Argon programs with interpreter

set -e

ARGON="./argon.exe"

usage() {
    echo "Argon Build Tool v2.25.0"
    echo ""
    echo "Usage: ./build.sh [command] [file]"
    echo ""
    echo "Commands:"
    echo "  run <file.ar>         Run with interpreter"
    echo "  test                  Run stdlib tests"
    echo "  bench [n]             Run fibonacci benchmark (default n=35)"
    echo "  docker                Run benchmarks in Docker"
    echo "  clean                 Clean build directory"
    echo ""
    echo "Examples:"
    echo "  ./build.sh run examples/hello.ar"
    echo "  ./build.sh test"
    echo "  ./build.sh bench 35"
}

case "$1" in
    run)
        if [ -z "$2" ]; then
            echo "Error: No input file"
            exit 1
        fi
        $ARGON "$2"
        ;;
    test)
        echo "=== Running Standard Library Tests ==="
        $ARGON test_stdlib.ar
        ;;
    bench)
        N="${2:-35}"
        echo "=== Fibonacci Benchmark (n=$N) ==="
        echo ""
        echo "Native (Rust baseline):"
        $ARGON --native-bench $N
        echo ""
        echo "Bytecode VM:"
        $ARGON --vm-bench $N
        ;;
    docker)
        echo "=== Building and running Docker benchmark ==="
        docker build -t argon-bench . && docker run --rm argon-bench
        ;;
    clean)
        rm -rf build/
        mkdir -p build
        echo "Build directory cleaned"
        ;;
    -h|--help|"")
        usage
        ;;
    *)
        # Default: run the file
        $ARGON "$1"
        ;;
esac
