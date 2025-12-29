# ===========================================
# Node.js API Dockerfile
# ===========================================

FROM node:20-alpine

# Install wget for health checks
RUN apk add --no-cache wget

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY --chown=appuser:appgroup . .

# Switch to non-root user
USER appuser

EXPOSE 3000

CMD ["node", "server.js"]
