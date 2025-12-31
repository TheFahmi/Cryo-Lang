# Argon Toolchain v2.19.0
# Using pre-built compiler binary (v2.18 binary with v2.19 source)
FROM rust:slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    clang llvm gdb wabt \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy runtime library
COPY self-host/libruntime_new.a /usr/lib/libruntime_argon.a

# Use argonc_v218 as the compiler (this works for most programs)
# v2.19.0 source is available but needs updated Rust interpreter for bootstrap
COPY self-host/argonc_v218 /usr/bin/argonc
RUN chmod +x /usr/bin/argonc

# Copy stdlib for reference
COPY stdlib/ /app/stdlib/

CMD ["bash"]
