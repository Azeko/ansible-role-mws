FROM python:3.11-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Install Ansible
RUN pip install --no-cache-dir ansible

# Install MWS CLI
RUN curl -sSL https://storage.mwsapis.ru/mws-cli/install.sh | bash

# Ensure MWS CLI is in PATH
ENV PATH="/root/.local/bin:${PATH}"

# Set working directory
WORKDIR /role

# Copy role files
COPY . /role/

# Default command
CMD ["/bin/bash"]

