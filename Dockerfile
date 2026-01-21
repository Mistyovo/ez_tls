FROM ubuntu:24.04

RUN (sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list.d/ubuntu.sources && \
    sed -i 's@//.*security.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list.d/ubuntu.sources) || \
    (echo "deb https://mirrors.ustc.edu.cn/ubuntu/ noble main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb https://mirrors.ustc.edu.cn/ubuntu/ noble-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.ustc.edu.cn/ubuntu/ noble-security main restricted universe multiverse" >> /etc/apt/sources.list)
RUN apt-get update && apt-get -y dist-upgrade && \
    apt-get install -y lib32z1 xinetd

RUN useradd -m -u 2000 ctf
WORKDIR /home/ctf

RUN cp -R /usr/lib* /home/ctf

RUN mkdir /home/ctf/dev && \
    mknod /home/ctf/dev/null c 1 3 && \
    mknod /home/ctf/dev/zero c 1 5 && \
    mknod /home/ctf/dev/random c 1 8 && \
    mknod /home/ctf/dev/urandom c 1 9 && \
    chmod 666 /home/ctf/dev/*

RUN mkdir /home/ctf/bin && \
    cp /bin/sh /home/ctf/bin && \
    cp /bin/ls /home/ctf/bin && \
    cp /bin/cat /home/ctf/bin && \
    cp /usr/bin/timeout /home/ctf/bin && \
    mkdir -p /home/ctf/etc && \
    echo "ctf:x:2000:2000::/home/ctf:/bin/sh" > /home/ctf/etc/passwd && \
    echo "ctf:x:2000:" > /home/ctf/etc/group

COPY ./docker/ctf.xinetd /etc/xinetd.d/ctf
RUN echo "Blocked by ctf_xinetd" > /etc/banner_fail

COPY ./docker/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

COPY ./vuln /home/ctf/vuln
RUN chmod +x /home/ctf/vuln

RUN chown -R root:ctf /home/ctf && \
    chmod -R 755 /home/ctf && \
    chmod 755 /home/ctf/vuln

COPY ./flag /home/ctf/flag
RUN chmod 644 /home/ctf/flag

EXPOSE 9999

ENTRYPOINT ["/bin/bash","/docker-entrypoint.sh"]