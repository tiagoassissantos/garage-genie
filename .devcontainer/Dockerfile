FROM elixir:1.18-otp-27-slim

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    inotify-tools \
    postgresql-client \
    nodejs \
    npm \
    git \
    curl \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Install Phoenix
RUN mix archive.install hex phx_new --force

# Set working directory
WORKDIR /workspace

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Install inotify-tools (for live reload)
RUN apt-get update && apt-get install -y inotify-tools

# Set environment variables
ENV MIX_ENV=dev