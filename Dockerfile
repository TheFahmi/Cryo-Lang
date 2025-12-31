# Argon Toolchain v2.19.0
# Full bootstrap using inotifywait trick
FROM rust:slim

# Install dependencies including inotify-tools for bootstrap
RUN apt-get update && apt-get install -y \
    clang llvm gdb wabt inotify-tools \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy runtime library
COPY self-host/libruntime_new.a /usr/lib/libruntime_argon.a

# Copy Rust interpreter binary (pre-built)
COPY argon /app/argon
RUN chmod +x /app/argon

# Copy compiler source for bootstrap
COPY self-host/compiler.ar /app/src.ar

# Bootstrap using inotifywait trick (capture LLVM IR before deletion)
RUN bash -c '\
    inotifywait -m -e modify /app/src.ar --format "%w%f" 2>/dev/null | while read f; do \
        cp /app/src.ar /app/compiler.ll 2>/dev/null; \
    done & \
    sleep 1; \
    /app/argon --emit-llvm /app/src.ar || true; \
    sleep 2; \
    kill %1 2>/dev/null || true \
'

# Compile LLVM IR to binary
RUN clang++ -O2 -Wno-override-module \
    /app/compiler.ll \
    /usr/lib/libruntime_argon.a \
    -lpthread -ldl \
    -o /usr/bin/argonc

RUN chmod +x /usr/bin/argonc

# Cleanup build artifacts
RUN rm -f /app/src.ar /app/compiler.ll

CMD ["bash"]
