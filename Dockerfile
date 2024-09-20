# syntax = docker/dockerfile:1

# Adjust NODE_VERSION as desired
ARG NODE_VERSION=20.13.1
FROM node:${NODE_VERSION}-slim as base

LABEL fly_launch_runtime="Node.js"

# Node.js app lives here
WORKDIR /app

# Set production environment
ENV NODE_ENV="production"

# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages needed to build node modules
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential node-gyp pkg-config python-is-python3

# Install node modules
COPY --link package-lock.json package.json ./
RUN npm ci --include=dev

# Install Chromium
RUN npx playwright install chromium

# Copy application code
COPY --link . .

# Remove development dependencies
RUN npm prune --omit=dev

#Final stage for app image
FROM base

# Install dependencies of Playwright
RUN npx playwright install-deps

COPY --from=build /app /app
COPY --from=build /app/node_modules /app/node_modules
COPY --from=build /root/.cache /root/.cache

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD [ "npm", "run", "start" ]