FROM rust:latest as builder

WORKDIR /usr/src

COPY . .

RUN cargo build --release

FROM debian:buster-slim

WORKDIR /usr/bin

COPY --from=builder /usr/src/target/release/argocd-sandbox .

EXPOSE 8080

CMD ["./argocd-sandbox", "-p", "8080", "-H", "0.0.0.0" ]
