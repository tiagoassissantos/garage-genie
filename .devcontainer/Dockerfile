# Use the Alpine-based Elixir image
FROM elixir:1.18.2-otp-27-alpine

# Install basic dependencies using apk
RUN apk update && apk add --no-cache \
    build-base \
    inotify-tools \
    postgresql-client \
    postgresql \
    postgresql-contrib \
    nodejs \
    npm \
    git \
    curl \
    zsh

# Set environment variables for PostgreSQL
ENV POSTGRES_USER=postgres \
    POSTGRES_PASSWORD=postgres \
    POSTGRES_DB=garage_genie_dev

# Prepare PostgreSQL directories as root.
# Create the data directory and the runtime directory for sockets/lock file.
RUN mkdir -p /var/lib/postgresql/data && \
    chown -R postgres:postgres /var/lib/postgresql/data && \
    mkdir -p /run/postgresql && \
    chown -R postgres:postgres /run/postgresql

# Switch to postgres user to initialize and run PostgreSQL commands.
USER postgres

# Initialize the database, start the server, run our SQL commands, then stop the server.
# We wait until the server is ready using pg_ctl -w.
RUN /usr/bin/initdb -D /var/lib/postgresql/data && \
    pg_ctl -D /var/lib/postgresql/data -o "-c listen_addresses='localhost'" -w start && \
    psql -c "ALTER USER postgres PASSWORD 'postgres';" && \
    createdb garage_genie_dev && \
    pg_ctl -D /var/lib/postgresql/data stop

# Switch back to root for further installations.
USER root

# Install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Install Phoenix archive
RUN mix archive.install hex phx_new --force

# Set working directory
WORKDIR /workspace

# (Optional) Reinstall Node.js (if you need a specific version) – note: Node.js was installed above.
#RUN curl -fsSL https://deb.nodesource.com/setup_18.x | sh && \
#    apk add --no-cache nodejs npm

# (Optional) Reinstall inotify-tools (if needed)
RUN apk add --no-cache inotify-tools

# Set environment variable for mix environment
ENV MIX_ENV=dev