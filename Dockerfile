############################
# STEP 1 build executable binary
############################
# golang alpine 1.12
FROM golang:alpine as builder

# Install git + SSL ca certificates.
# Git is required for fetching the dependencies.
# Ca-certificates is required to call HTTPS endpoints.
RUN apk update && apk add --no-cache git ca-certificates tzdata && update-ca-certificates

# Create appuser
RUN adduser -D -g '' appuser

WORKDIR $GOPATH/src/demo/hello-go/
COPY demo-go/ .

# Fetch dependencies.
RUN go get -d -v github.com/prometheus/client_golang/prometheus/promhttp

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -a -installsuffix cgo -o /go/bin/hello .

############################
# STEP 2 build a small image
############################
FROM scratch

# Import from builder.
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd

# Copy our static executable
COPY --from=builder /go/bin/hello /go/bin/hello

# Use an unprivileged user.
USER appuser

EXPOSE 8080 8081
 

# Run the hello binary.
ENTRYPOINT ["/go/bin/hello"]