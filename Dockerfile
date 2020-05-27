# First stage: build the release
FROM elixir:1.10-alpine AS builder

# Copy source code
WORKDIR /src
COPY mix.exs mix.lock /src/
COPY lib ./lib
COPY priv ./priv
COPY config ./config

# Build release
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix release --path /app --quiet


# Second stage build the execution image
FROM alpine:3.11

RUN apk add --update openssl ncurses-libs \
        && rm -rf /var/cache/apk/*

COPY --from=builder /app /app
WORKDIR /app
ENTRYPOINT ["/app/bin/chercheville"]
CMD ["start"]
