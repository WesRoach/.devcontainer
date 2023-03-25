ARG VARIANT=bionic
FROM mcr.microsoft.com/devcontainers/base:${VARIANT}

ARG GO_VERSION=1.20.2

# Update apt-get packages

# Install nvm for node
# ARG NODE_VERSION="none"
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends --no-upgrade \
    # Certs
    ca-certificates \
    # Utilities
    curl \
    git \
    # Install Java
    default-jdk \
    mlocate \
    libgbm-dev \
    # Python Development
    python3 \
    python3-distutils \
    build-essential \
    zlib1g-dev \
    libncurses5-dev \
    libgdbm-dev \
    libnss3-dev \
    libssl-dev \
    libreadline-dev \
    libffi-dev \
    libncurses5-dev \
    libncursesw5-dev \
    bzip2

# Corporate Peeps:
# You'll likely need to insert corporate certificates
# ADD .devcontainer/cert/cacert.crt /usr/local/share/ca-certificates.crt
# RUN chmod 644 /usr/local/share/ca-certificates/cacert.crt && update-ca-certificates

# Bundle cert after running update-ca-certificates
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ENV AWS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ENV NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt

# GH CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt update \
    && apt install gh -y

# tflint
RUN curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# tfsec
ADD .devcontainer/software/tfsec_install.sh /tfsec_install.sh
RUN chmod +x /tfsec_install.sh \
    && bash /tfsec_install.sh \
    && rm -f /tfsec_install.sh

# terraform-docs
RUN curl -Lo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v0.16.0/terraform-docs-v0.16.0-$(uname)-$(dpkg --print-architecture).tar.gz \
    && tar -xzf terraform-docs.tar.gz \
    && chmod +x terraform-docs \
    && mv terraform-docs /usr/bin/terraform-docs \
    && rm -f ./terraform-docs.tar.gz

# Switch user or everything owned by root
# best if tfswitch/venv/nvm owned by user: vscode
USER vscode

# Terraform / tfswitch
RUN sudo curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh -o tfswitch_install.sh \
    && sudo bash tfswitch_install.sh \
    && sudo rm -f tfswitch_install.sh \
    # Install latest terraform
    && tfswitch -u

# pyenv
RUN git clone https://github.com/pyenv/pyenv.git /home/vscode/.pyenv \
    && git clone https://github.com/pyenv/pyenv-virtualenv.git /home/vscode/.pyenv/plugins/pyenv-virtualenv \
    # ~/.zshrc
    && echo "" >> /home/vscode/.zshrc \
    && echo "# Pyenv" >> /home/vscode/.zshrc \
    && echo 'export PYENV_ROOT="/home/vscode/.pyenv"' >> /home/vscode/.zshrc \
    && echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> /home/vscode/.zshrc \
    && echo 'eval "$(pyenv init --path)"' >> /home/vscode/.zshrc \
    && echo 'eval "$(pyenv init -)"' >> /home/vscode/.zshrc \
    && echo 'eval "$(pyenv virtualenv-init -)"' >> /home/vscode/.zshrc

# Poetry
RUN curl -sSL https://install.python-poetry.org | python3 - \
    # ~/.zshrc
    && echo "" >> /home/vscode/.zshrc \
    && echo "# Poetry" >> /home/vscode/.zshrc \
    && echo 'export PATH="/home/vscode/.local/bin:$PATH"' >> /home/vscode/.zshrc

# Configure /workspace
# This is where code will be bind-mounted
SHELL ["/bin/zsh", "-c"]
WORKDIR /workspaces/
RUN sudo chown -R vscode:vscode /workspaces

# Install poetry-dynamic-versioning
RUN source /home/vscode/.zshrc \
    && poetry self add "poetry-dynamic-versioning[plugin]"

# Go
RUN sudo curl -O -L https://golang.org/dl/go${GO_VERSION}.linux-$(dpkg --print-architecture).tar.gz \
    && sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-$(dpkg --print-architecture).tar.gz \
    # ~/.zshrc
    && echo "" >> /home/vscode/.zshrc \
    && echo "# Go" >> /home/vscode/.zshrc \
    && echo 'export PATH="$PATH:/usr/local/go/bin"' >> /home/vscode/.zshrc \
    # Validate
    && source /home/vscode/.zshrc \
    && go version
