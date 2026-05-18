FROM ubuntu:22.04

RUN useradd -m -s /bin/bash -u 1000 metrics

WORKDIR /app

COPY metrics.sh .
RUN chmod +x metrics.sh && \
chown -R metrics:metrics /app

USER metrics

ENTRYPOINT ["/bin/bash", "metrics.sh"]



