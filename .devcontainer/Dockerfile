# Use Arch Linux as the base image
FROM archlinux:latest

# Update the system and install required packages
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
      base-devel \
      git \
      curl \
      inotify-tools \
      postgresql \
      postgresql-libs \
      zsh \
      openssl \
      ncurses \
      wxgtk3 \
      libxslt \
      libxml2 \
      zlib \
      go \
      unzip

# Set environment variables for PostgreSQL.
ENV POSTGRES_USER=postgres \
    POSTGRES_PASSWORD=postgres \
    POSTGRES_DB=garage_genie_dev

# Prepare PostgreSQL directories as root.
# Create the data directory and the runtime directory for sockets/lock file.
RUN mkdir -p /var/lib/postgres/data && \
    chown -R postgres:postgres /var/lib/postgres/data && \
    mkdir -p /run/postgresql && \
    chown -R postgres:postgres /run/postgresql

# Switch to postgres user to initialize and run PostgreSQL commands.
USER postgres

# Initialize the database, start PostgreSQL (forcing IPv4 binding),
# run our SQL commands, then stop the server—all in one RUN instruction.
RUN initdb -D /var/lib/postgres/data && \
    pg_ctl -D /var/lib/postgres/data -o "-c listen_addresses='127.0.0.1'" -w start && \
    psql -c "ALTER USER postgres PASSWORD 'postgres';" && \
    createdb garage_genie_dev && \
    pg_ctl -D /var/lib/postgres/data stop

# Switch back to root for the remaining installations.
USER root

# Set working directory for your application
WORKDIR /workspace

# (Optional) Reinstall inotify-tools if needed
RUN pacman -S --noconfirm inotify-tools

###############################
# Create a new user and install oh-my-zsh
###############################
# Create a non-root user named "developer" with zsh as the default shell.
RUN useradd -m -s /bin/zsh developer && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN git clone https://aur.archlinux.org/asdf-vm.git /opt/asdf-vm && \
    chown -R developer:developer /opt/asdf-vm

# Switch to the "developer" user.
USER developer
WORKDIR /home/developer

# Set the mix environment
ENV MIX_ENV=dev

###############################
# Install asdf from the AUR
###############################
RUN cd /opt/asdf-vm && \
    makepkg -si --noconfirm

# Install asdf version manager (version 0.11.3)
#RUN git clone https://github.com/asdf-vm/asdf.git /opt/asdf --branch v0.11.3
ENV ASDF_DIR=/opt/asdf-vm
ENV PATH="$ASDF_DIR/bin:$ASDF_DIR/shims:$PATH"
# Set kerl options to avoid building docs
ENV KERL_CONFIGURE_OPTIONS="--disable-debug --without-docs"

# Install Erlang and Elixir via asdf.
RUN asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git && \
    asdf install erlang 27.2.2 && \
    asdf plugin add elixir https://github.com/asdf-vm/asdf-elixir.git && \
    asdf install elixir 1.18.2-otp-27 && \
    asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git && \
    asdf install nodejs 22.14.0

ENV ASDF_ERLANG_VERSION=27.2.2
ENV ASDF_ELIXIR_VERSION=1.18.2-otp-27
ENV ASDF_NODEJS_VERSION=22.14.0
ENV PATH="/home/developer/.asdf/shims:$PATH"

# Install oh-my-zsh unattended.
# The official install script can run non-interactively by setting RUNZSH and CHSH to "no".
RUN RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

RUN echo "export ASDF_ERLANG_VERSION=27.2.2" >> /home/developer/.zshrc && \
    echo "export ASDF_ELIXIR_VERSION=1.18.2-otp-27" >> /home/developer/.zshrc && \
    echo "export ASDF_NODEJS_VERSION=22.14.0" >> /home/developer/.zshrc && \
    echo "export PATH=/home/developer/.asdf/shims:$PATH" >> /home/developer/.zshrc && \
    source /home/developer/.zshrc

# Install Hex and Rebar using mix (provided by the installed Elixir)
RUN /home/developer/.asdf/shims/mix local.hex --force && \
    /home/developer/.asdf/shims/mix local.rebar --force

# (Optionally, you can customize the .zshrc or add plugins here)

# Switch back to root (or leave as developer if you want the container to run as that user)
#USER root