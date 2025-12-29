# ===========================================
# Simple Nginx Dockerfile
# ===========================================
# This Dockerfile creates a custom Nginx image
# serving static HTML content.
# ===========================================

# Use the official Nginx Alpine image as base
# Alpine variant is smaller (~23MB vs ~135MB)
FROM nginx:alpine

# Add metadata labels
LABEL maintainer="your-email@example.ir"
LABEL version="1.0"
LABEL description="Simple Nginx static website"

# Copy static files to Nginx html directory
# The default Nginx config serves files from /usr/share/nginx/html/
COPY index.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/

# Document the port that will be exposed
# This is informational - you still need -p when running
EXPOSE 80

# Nginx runs in the foreground in Docker
# daemon off; prevents Nginx from daemonizing
CMD ["nginx", "-g", "daemon off;"]
