# ---- Build stage ----
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    yasm \
    autoconf \
    automake \
    libtool \
    pkg-config \
    libzmq3-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY . .

RUN ./autogen.sh && ./configure && make -j$(nproc)

# ---- Runtime stage ----
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    libzmq5 \
    libssl3 \
    libcap2-bin \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/src/ckpool /usr/local/bin/ckpool
COPY entrypoint.sh /entrypoint.sh

RUN setcap cap_net_bind_service=+eip /usr/local/bin/ckpool \
    && mkdir -p /etc/ckpool /var/log/ckpool \
    && chmod +x /entrypoint.sh

EXPOSE 3333 4444

ENTRYPOINT ["/entrypoint.sh"]
CMD ["-B", "-c", "/etc/ckpool/ckpool.conf"]
