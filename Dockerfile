FROM --platform=${BUILDPLATFORM:-linux/amd64} golang:1.23-bookworm AS builder

ARG BUILDPLATFORM

COPY . /code/external-dns-coredns-webhook
WORKDIR /code/external-dns-coredns-webhook
RUN CGO_ENABLED=0 go build

FROM --platform=${BUILDPLATFORM:-linux/amd64} debian:bookworm-slim

COPY --from=builder /code/external-dns-coredns-webhook/external-dns-coredns-webhook /usr/bin/external-dns-coredns-webhook

USER 20000:20000
# replace with your desire device count
ENTRYPOINT ["external-dns-coredns-webhook"]

LABEL org.opencontainers.image.title="ExternalDNS CoreDNS webhook Docker Image" \
      org.opencontainers.image.description="external-dns-coredns-webhook" \
      org.opencontainers.image.url="https://github.com/tannevaled/external-dns-coredns-webhook" \
      org.opencontainers.image.source="https://github.com/tannevaled/external-dns-coredns-webhook" \
      org.opencontainers.image.license="MIT"
