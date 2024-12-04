# Базовый слой (base) для установки зависимостей
# Устанавливает зависимости с помощью go mod download.
FROM golang:1.22.0 AS base
  WORKDIR /src
  COPY go.mod go.sum .
  RUN go mod download
  COPY *.go .

# Основной слой (build) для сборки приложения.
# Копирует установленные зависимости и выполняет go mod tidy, чтобы обновить зависимости.
FROM base AS build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /parcel

# В финальном этапе scratch бинарные файлы, собранные на предыдущем этапе,
# копируются в файловую систему нового этапа
FROM scratch
COPY tracker.db .
COPY --from=build /parcel .

# Запуск приложения
ENTRYPOINT ["/parcel"]
