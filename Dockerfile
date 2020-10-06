FROM golang:1.15
WORKDIR /go/src/app
COPY go.mod go.sum /go/src/app/
RUN go mod download
COPY fetch-secret.go .
RUN go build -ldflags="${LDFLAGS}" fetch-secret.go
ENTRYPOINT ["./fetch-secret"]
