FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends nmap default-mysql-client ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY mysql-auth-check /usr/local/bin/mysql-auth-check
RUN chmod 755 /usr/local/bin/mysql-auth-check

ENTRYPOINT ["nmap"]
