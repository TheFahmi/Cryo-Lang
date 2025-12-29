#!/bin/bash
# Argon Compiler Script
# Uses Rust interpreter as Stage 0

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "$1" ]; then
    echo "Usage: arcc <file.ar>"
    exit 1
fi

# Use Rust interpreter to run compiler.ar on the input file
"$SCRIPT_DIR/argon" "$SCRIPT_DIR/self-host/compiler.ar" "$1"
