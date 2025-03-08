FROM alpine:3.20 AS tofu

ADD install-opentofu.sh /install-opentofu.sh
RUN chmod +x /install-opentofu.sh
RUN apk add gpg gpg-agent
RUN ./install-opentofu.sh --install-method standalone --install-path / --symlink-path -

FROM ubuntu
COPY --from=tofu /tofu /usr/local/bin/tofu
RUN apt-get update && \
    apt-get install -y \
        unzip \
        curl \
    && apt-get clean \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf \
        awscliv2.zip \
    && apt-get -y purge curl \
    && apt-get -y purge unzip \ 
    && apt-get install -y git \
    && rm -rf /var/lib/apt/lists/*

# Configure AWS CLI
RUN mkdir -p /root/.aws
COPY aws.config /root/.aws/config

# Verify installations
RUN tofu --version && aws --version 


