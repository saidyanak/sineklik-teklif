# ── Aşama 1: Flutter web build ─────────────────────────────────────────────
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip ca-certificates wget \
    && rm -rf /var/lib/apt/lists/*

# Flutter SDK — stable branch
RUN git clone --depth 1 --branch stable \
    https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:${PATH}"

# Web için önbellek
RUN flutter precache --web --no-ios --no-android --no-linux --no-macos --no-windows --no-fuchsia

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

ARG SUPABASE_URL=""
ARG SUPABASE_ANON_KEY=""

RUN flutter build web --release --web-renderer canvaskit \
    --dart-define=SUPABASE_URL=${SUPABASE_URL} \
    --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}

# ── Aşama 2: Nginx ile servis ───────────────────────────────────────────────
FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
