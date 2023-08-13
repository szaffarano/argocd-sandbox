FROM golang:1 AS build-stage

ARG VERSION
ARG GIT_COMMIT
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . ./

RUN CGO_ENABLED=0 GOOS=linux \
      go build -ldflags="-X main.version=$VERSION -X main.commit=$GIT_COMMIT"

FROM build-stage AS run-test-stage
RUN go test -v ./...

FROM gcr.io/distroless/base-debian11 AS build-release-stage

WORKDIR /

COPY --from=build-stage /app/argocd-sandbox /argocd-sandbox

EXPOSE 8080

USER nonroot:nonroot

ENTRYPOINT ["/argocd-sandbox"]
