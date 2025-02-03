ARG GIT_REPOSITORY
#ARG BUILDPLATFORM

#FROM --platform=${ARG TARGETPLATFORM} golang:1.23-bookworm AS builder
FROM golang:1.23-bookworm AS builder

ARG GIT_REPOSITORY
#ARG BUILDPLATFORM
#ARG TARGETPLATFORM

COPY . /code/external-dns-coredns-webhook
WORKDIR /code/external-dns-coredns-webhook
RUN CGO_ENABLED=0 go build

#FROM --platform=${ARG TARGETPLATFORM} debian:bookworm-slim
FROM debian:bookworm-slim
ARG GIT_REPOSITORY
#ARG BUILDPLATFORM
#ARG TARGETPLATFORM
COPY --from=builder /code/external-dns-coredns-webhook/external-dns-coredns-webhook /usr/bin/external-dns-coredns-webhook

USER 20000:20000

CMD ["external-dns-coredns-webhook"]

LABEL org.opencontainers.image.title="ExternalDNS CoreDNS webhook Docker Image" \
      org.opencontainers.image.url="${GIT_REPOSITORY}" \
      org.opencontainers.image.source="${GIT_REPOSITORY}" \
      org.opencontainers.image.license="MIT"
