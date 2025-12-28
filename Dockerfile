# Argon Toolchain Build
FROM argon-bench as cache

FROM rust:slim
RUN apt-get update && apt-get install -y clang llvm

WORKDIR /app

# Get Rust interpreter from cache
COPY --from=cache /app/argon ./argon

# Copy source files
COPY self-host ./self-host
COPY bootstrap.sh .

# Run bootstrap
RUN chmod +x bootstrap.sh
RUN ./bootstrap.sh

# Install globally
RUN cp argonc /usr/bin/argonc
RUN cp libruntime_rust.a /usr/lib/libruntime_argon.a

CMD ["bash"]
