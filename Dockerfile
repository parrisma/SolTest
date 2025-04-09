# Use Ubuntu 24.04 as the base image
FROM ubuntu:24.04

# Set /bin/bash as the default shell
SHELL ["/bin/bash", "-c"]

# Update package lists and install necessary dependencies
RUN apt-get update --fix-missing && \
    apt-get install -y curl build-essential pkg-config libudev-dev llvm libclang-dev protobuf-compiler libssl-dev

# Install git
RUN apt-get install -y git

# Install a real editor :)
# RUN apt-get install -y vim
RUN apt-get install -y bc
RUN apt-get install -y jq

# Purge unnecessary packages
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create rust-dev user
RUN groupadd -g 1678 rust-dev
RUN useradd -u 1678 -g 1678 -m -d /home/rust-dev -s /bin/bash rust-dev
USER rust-dev
ENV HOME=/home/rust-dev

# Install Rust using rustup as rust-dev user
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
ENV PATH="/home/rust-dev/.cargo/bin:${PATH}"
RUN rustc --version && cargo --version

# Install Solana CLI
RUN sh -c "$(curl -sSfL https://release.anza.xyz/stable/install)"
ENV PATH="/home/rust-dev/.local/share/solana/install/active_release/bin:${PATH}"
RUN solana --version

# Install Anchor CLI

RUN cargo install --git https://github.com/coral-xyz/anchor --tag v0.31.0 anchor-cli --locked
RUN anchor --version

# Install Seahorse, python support
RUN cargo install seahorse-dev
RUN seahorse -V

# Install Node Version Manager (NVM)
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash

# Export NVM directory to PATH using $HOME
ENV NVM_DIR=$HOME/.nvm
ENV PATH=$NVM_DIR:$NVM_DIR/bin:$PATH
RUN bash -c "source $NVM_DIR/nvm.sh && nvm --version"

# Install Node.js using NVM (specify a Node.js version as needed)
RUN bash -c "source $NVM_DIR/nvm.sh && nvm install --lts && nvm use --lts"
RUN bash -c "source $NVM_DIR/nvm.sh && node -v && npm -v"

# Install Yarn
RUN bash -c "source $NVM_DIR/nvm.sh && npm install --global yarn"
RUN bash -c "source $NVM_DIR/nvm.sh && yarn --version"

# Set local as default Solana Env.
RUN echo "solana config set --url localhost" >> ~/.bashrc

# Set the working directory to the rust-dev home directory
WORKDIR /home/rust-dev
