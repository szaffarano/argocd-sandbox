FROM rust:1.71 as builder

WORKDIR /usr/src

COPY . .

RUN cargo build --release

FROM debian:stable-slim

WORKDIR /usr/bin

COPY --from=builder /usr/src/target/release/argocd-sandbox .

EXPOSE 8080

USER nobody

ENTRYPOINT [ "./argocd-sandbox"]
