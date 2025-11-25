# Multi-stage build for React frontend

# Stage 1: Build the React app
FROM node:18-alpine AS builder

# Install pnpm
RUN corepack enable && corepack prepare pnpm@10.23.0 --activate

WORKDIR /app

# Copy workspace configuration and .npmrc for pnpm settings
COPY package.json pnpm-lock.yaml* .npmrc ./

# Install dependencies (including devDependencies for build)
RUN pnpm install --frozen-lockfile

# Copy source code
COPY . .

# Build the app for production
RUN pnpm run build

# Stage 2: Serve with nginx
FROM nginx:alpine

# Copy built files from builder stage (Vite outputs to dist/)
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom nginx config (optional)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
