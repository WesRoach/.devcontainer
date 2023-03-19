#!/bin/bash

ARCH=$(dpkg --print-architecture)

if [ $ARCH = 'arm64' ]
then
    echo Detected arm64 architecture
    # Download the arm version
    wget https://github.com/aquasecurity/tfsec/releases/download/v1.28.1/tfsec-linux-arm64 -O /usr/bin/tfsec
fi

if [ $ARCH = 'amd64' ]
then
    echo Detected amd64 architecture
    # Download the arm version
    wget https://github.com/aquasecurity/tfsec/releases/download/v1.28.1/tfsec-linux-amd64 -O /usr/bin/tfsec
fi

# Make executable
chmod 555 /usr/bin/tfsec

# Verify installation
tfsec --version
