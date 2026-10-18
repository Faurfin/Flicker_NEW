FROM golang:1.22-alpine AS builder

WORKDIR /app
# Инициализация модуля и загрузка Gin
RUN go mod init flicker_go && go get -u github.com/gin-gonic/gin
COPY . .
RUN go build -o main .

FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/main .
EXPOSE 8080
CMD ["./main"]