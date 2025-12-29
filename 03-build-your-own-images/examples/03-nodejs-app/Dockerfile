# ===========================================
# Node.js Application Dockerfile
# ===========================================
# This Dockerfile demonstrates best practices
# for containerizing Node.js applications.
# ===========================================

# Use official Node.js Alpine image
# Alpine keeps the image small (~50MB vs ~350MB for full)
FROM node:20-alpine

# Add metadata labels
LABEL maintainer="your-email@example.ir"
LABEL version="1.0"
LABEL description="Node.js Express application example"

# Create a non-root user
# Node images include a 'node' user, but creating our own is more explicit
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set working directory
WORKDIR /app

# Copy package files first (better layer caching)
# If package.json doesn't change, npm install layer is cached
COPY package*.json ./

# Install dependencies
# --omit=dev excludes devDependencies
# npm ci is faster and more reliable than npm install for CI/CD
RUN npm ci --omit=dev

# Copy application code
COPY --chown=appuser:appgroup server.js ./

# Set environment to production
ENV NODE_ENV=production

# Switch to non-root user
USER appuser

# Document the port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -q --spider http://localhost:3000/health || exit 1

# Run the application
CMD ["node", "server.js"]
