# ============================================
# CRYO PRODUCTION DOCKER IMAGE
# Optimized Alpine-based image for Cryo
# ============================================

# --------------------------------------------
# Stage 1: Builder
# --------------------------------------------
FROM rust:1.75-alpine AS builder

# Install build dependencies
RUN apk add --no-cache \
    musl-dev \
    clang \
    llvm \
    make \
    git

WORKDIR /build

# Copy manifest configuration
COPY Cargo.toml Cargo.lock ./

# Copy source code
COPY src ./src
COPY stdlib ./stdlib
COPY examples ./examples
COPY build.sh ./

# Build release binary with static linking for portability
# We use +crt-static to ensure no external deps are needed
RUN RUSTFLAGS="-C target-feature=+crt-static" \
    cargo build --release --target x86_64-unknown-linux-musl

# --------------------------------------------
# Stage 2: Runtime (Minimal)
# --------------------------------------------
FROM alpine:3.19 AS runtime

# Metadata
LABEL org.opencontainers.image.title="Cryo Runtime"
LABEL org.opencontainers.image.description="Cryo Programming Language Runtime"
LABEL org.opencontainers.image.version="3.4.0"
LABEL org.opencontainers.image.vendor="Cryo Team"

# Install minimal runtime dependencies
RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    bash \
    && rm -rf /var/cache/apk/*

# Create non-root user for security
RUN addgroup -g 1000 cryo && \
    adduser -u 1000 -G cryo -s /bin/sh -D cryo

# Set up directory structure
WORKDIR /app
RUN chown cryo:cryo /app

# Copy binary from builder
COPY --from=builder /build/target/x86_64-unknown-linux-musl/release/cryo /usr/local/bin/cryo
COPY --from=builder /build/target/x86_64-unknown-linux-musl/release/cryo /usr/bin/argon

# Copy standard library (Essential)
COPY --from=builder /build/stdlib /usr/local/lib/cryo/stdlib
COPY --from=builder /build/stdlib /app/stdlib

# Copy examples and scripts (Optional but useful)
COPY --from=builder /build/examples /app/examples
COPY --from=builder /build/build.sh /app/build.sh

# Set environment variables
ENV CRYO_STDLIB_PATH=/usr/local/lib/cryo/stdlib
ENV TZ=UTC

# Build script executable
RUN chmod +x /app/build.sh

# Switch to non-root user
USER cryo

# Health check (Generic version check)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD cryo --version || exit 1

# Default command
CMD ["cryo", "--help"]
