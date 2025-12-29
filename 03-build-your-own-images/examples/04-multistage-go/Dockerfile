# ===========================================
# Multi-Stage Go Application Dockerfile
# ===========================================
# This demonstrates multi-stage builds for Go.
# The final image is tiny since Go compiles
# to a single static binary.
# ===========================================

# ============ STAGE 1: Build ============
# Use full Go image for building
FROM golang:1-alpine AS builder

# Install git (needed for some Go dependencies)
RUN apk add --no-cache git ca-certificates

# Set working directory
WORKDIR /app

# Copy go mod files first (better caching)
COPY go.mod ./
# If you have go.sum, copy it too:
# COPY go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY main.go ./

# Build the binary
# CGO_ENABLED=0 creates a static binary (no C dependencies)
# -ldflags="-w -s" reduces binary size by stripping debug info
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags="-w -s" \
    -o server \
    main.go


# ============ STAGE 2: Runtime ============
# Use minimal Alpine image for running
FROM alpine:3.18

# Add labels
LABEL maintainer="your-email@example.ir"
LABEL version="1.0"
LABEL description="Multi-stage Go application"

# Install CA certificates for HTTPS requests
# This is needed if your app makes HTTPS calls
RUN apk --no-cache add ca-certificates

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set working directory
WORKDIR /app

# Copy ONLY the binary from the builder stage
COPY --from=builder /app/server .

# Change ownership to non-root user
RUN chown appuser:appgroup server

# Switch to non-root user
USER appuser

# Document the port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD wget -q --spider http://localhost:8080/health || exit 1

# Run the binary
CMD ["./server"]
