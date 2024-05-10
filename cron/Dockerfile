FROM docker:latest

LABEL maintainer="Denis Martin-Bruillot <denis@irlmobile.com>"

# Install required packages
RUN apk add --no-cache \
    bash \
    bash-doc \
    bash-completion \
    jq \
    bind-tools \
    curl \
    tar \
    gzip \
    restic \ 
    && rm -rf /var/cache/apk/*

# Set a working directory
WORKDIR /

# Run as root user
USER root

# Copy the entrypoint script into the container
COPY ./docker-entrypoint.sh /

# Set the entrypoint to run the script
ENTRYPOINT ["/docker-entrypoint.sh"]

# Default command to execute
CMD ["bash"]
