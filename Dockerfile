# syntax = docker/dockerfile:1

# Rubyのバージョンを確認
ARG RUBY_VERSION=3.2.3
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# アプリケーションのラベル設定
LABEL fly_launch_runtime="rails"

# Railsアプリの作業ディレクトリ
WORKDIR /rails

# 本番環境とその他の設定
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    RUBYOPT="--yjit" \
    RUBY_YJIT_ENABLE=1
    
# RubyとBundlerの更新
RUN gem update --system --no-document && \
    gem install -N bundler

# 一時的なビルドステージで最終イメージのサイズを減少させる
FROM base AS build

# 必要なパッケージのインストール
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl cron libjemalloc2 libvips postgresql-client \
    build-essential git libpq-dev node-gyp pkg-config python-is-python3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# JavaScriptの依存関係をインストール
ARG NODE_VERSION=18.19.0
ARG YARN_VERSION=1.22.22
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    npm install -g yarn@$YARN_VERSION && \
    rm -rf /tmp/node-build-master

# アプリケーションのGemをインストール
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Nodeモジュールをインストール
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# アプリケーションコードをコピー
COPY . .

# bootsnapのコードをプリコンパイルし、起動時間を短縮
RUN bundle exec bootsnap precompile app/ lib/

# 本番環境用のアセットをプリコンパイル
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# node_modulesを削除してイメージサイズを減少
RUN rm -rf node_modules

# cronジョブを更新
RUN bundle exec whenever --update-crontab

# 最終的なアプリイメージのステージ
FROM base

# ビルド済みのアーティファクト（Gem、アプリケーション）をコピー
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# セキュリティのため、ランタイムファイルのみを非rootユーザーで実行
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# エントリーポイントでデータベースの準備を実行
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# cronをバックグラウンドで起動し、Railsサーバーを起動
CMD cron && ./bin/rails server -b 0.0.0.0

# Railsサーバーのポートを公開
EXPOSE 3000