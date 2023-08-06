FROM rust:latest as builder

WORKDIR /usr/src

COPY . .

RUN cargo build --release

FROM debian:stable-slim

WORKDIR /usr/bin

COPY --from=builder /usr/src/target/release/argocd-sandbox .

EXPOSE 8080

ENTRYPOINT [ "./argocd-sandbox" ]
