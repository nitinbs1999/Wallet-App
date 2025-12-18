FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Install Java 17, PostgreSQL, and development tools
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        openjdk-17-jdk \
        postgresql \
        postgresql-contrib \
        maven \
        curl \
        wget \
        git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set Java environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Configure PostgreSQL
USER postgres
RUN /etc/init.d/postgresql start && \
    psql --command "CREATE USER postgres WITH SUPERUSER PASSWORD 'postgres';" && \
    psql --command "CREATE DATABASE test_db OWNER postgres;"

USER root

# Verify installations
RUN java -version && javac -version
