# Base image includes java
FROM openjdk:17-slim

# Set the working directory
WORKDIR /usr/local/app

# Set the user to root
USER root

# Set the PATH environment variable to include .local/bin
ENV PATH="$PATH:/root/.local/bin"

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl bash git gnupg software-properties-common wget

# Install Nextflow
RUN curl -s https://get.nextflow.io | bash
RUN chmod +x nextflow && mkdir -p /root/.local/bin/ && mv nextflow /root/.local/bin/

# Install Terraform
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] && \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
RUN apt-get install terraform