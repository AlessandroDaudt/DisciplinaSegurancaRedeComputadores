FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN printf '%s\n' \
      'deb http://archive.ubuntu.com/ubuntu bionic main restricted universe multiverse' \
      'deb http://archive.ubuntu.com/ubuntu bionic-updates main restricted universe multiverse' \
      'deb http://archive.ubuntu.com/ubuntu bionic-security main restricted universe multiverse' \
      > /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      bash \
      openssh-server \
      sudo=1.8.21p2-3ubuntu1 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --shell /bin/bash aluno \
    && echo 'aluno:aluno' | chpasswd \
    && printf 'aluno ALL=(ALL,!root) NOPASSWD: ALL\n' > /etc/sudoers.d/aluno \
    && chmod 0440 /etc/sudoers.d/aluno \
    && mkdir -p /run/sshd \
    && sed -ri 's/^#?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -ri 's/^#?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D", "-e"]
