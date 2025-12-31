FROM rust:slim

# Install C++ compiler (g++), clang, and LLVM
RUN apt-get update && apt-get install -y \
    g++ clang llvm time \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Source
COPY Cargo.toml .
COPY src/ ./src/
COPY self-host/ ./self-host/

# Build Argon Interpreter (Release mode for max speed)
RUN cargo build --release

# Copy binary to path
# Copy binary to path
RUN cp target/release/argon /usr/bin/argon

# Copy Scripts and Data
COPY build.sh .
COPY test_stdlib.ar .
COPY examples/ ./examples/
COPY benchmarks/comparison/ ./benchmarks/
COPY stdlib/ ./stdlib/

# Make scripts executable
RUN chmod +x build.sh benchmarks/run.sh

# Default command: Run stdlib tests then benchmarks
CMD ["bash", "-c", "./build.sh test && ./build.sh bench"]
