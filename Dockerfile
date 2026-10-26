FROM ubuntu:22.04

# free and uptime are provided by procps; df, date, nproc and sleep by coreutils.
RUN apt-get update \
    && apt-get install -y --no-install-recommends procps coreutils python3 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --uid 1000 --shell /bin/bash ubuntu \
    && mkdir -p /home/ubuntu/resource-monitor \
    && chown ubuntu:ubuntu /home/ubuntu/resource-monitor

COPY script.sh /usr/local/bin/script.sh
RUN sed -i 's/\r$//' /usr/local/bin/script.sh \
    && chmod +x /usr/local/bin/script.sh

USER ubuntu
WORKDIR /home/ubuntu/resource-monitor
EXPOSE 8080
CMD ["/bin/bash", "-c", "/usr/local/bin/script.sh & exec python3 -u -m http.server 8080"]
