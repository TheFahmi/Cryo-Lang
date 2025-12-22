# Stage 0: Recover Interpreter from previous build
FROM argon-bench as cache

# Stage 1: Build New Toolchain
FROM rust:slim
RUN apt-get update && apt-get install -y nodejs python3 clang llvm time

WORKDIR /app

# Recover interpreter binary (Linux)
# We assume it exists in the cache image
COPY --from=cache /app/argon ./argon

# Copy Source (Self-Host) and Scripts
# Note: We need to copy these folders from HOST (Cleaned root)
COPY benchmarks ./benchmarks
COPY self-host ./self-host
COPY bootstrap.sh .
COPY examples ./examples

# Setup Environment
# bootstrap.sh expects benchmarks in root for C++ compilation?
# Check bootstrap.sh logic: it creates generated files.
RUN cp -r benchmarks/* .

# Run Bootstrap
# This uses ./argon (Interpreter) to compile self-host/compiler.argon -> compiler_stage0.ll
# Then compiles runtime.rs (NEW networking) -> libruntime_rust.a
# Then links -> stage1_compiler
RUN chmod +x bootstrap.sh
RUN ./bootstrap.sh

# Install Global
# We use stage1_compiler as it contains the NEW Declaration strings (emitted by interp logic reading source)
RUN chmod +x benchmarks/run_benchmarks.sh
RUN cp stage1_compiler /usr/bin/argonc
RUN cp libruntime_rust.a /usr/lib/libruntime_argon.a

CMD ["./benchmarks/run_benchmarks.sh"]
