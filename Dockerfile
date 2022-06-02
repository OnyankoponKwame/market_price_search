FROM ruby:3.1.2

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -qq && apt-get install -y nodejs vim yarn zsh

RUN mkdir /frimachart
ENV APP_ROOT /frimachart
WORKDIR $APP_ROOT

COPY ./Gemfile $APP_ROOT/Gemfile
COPY ./Gemfile.lock $APP_ROOT/Gemfile.lock

RUN gem install bundler
RUN bundle install

COPY . $APP_ROOT

ENV RAILS_SERVE_STATIC_FILES="true"

RUN apt-get install -y cron 

# 日本語フォントをインストールする
ENV LANGUAGE ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
RUN apt-get install -y --no-install-recommends locales && \
    locale-gen ja_JP.UTF-8 && \
    apt-get install -y --no-install-recommends fonts-ipafont

RUN chsh -s /bin/zsh

# entrypoint.shをコピーし、実行権限を与える
COPY entrypoint.sh /usr/bin/
# chmodコマンドはファイルやディレクトリに権限設定するコマンド。`+`は後に記述した権限を付加する。`x`は実行権限。
# つまり今回は全てのユーザに該当ファイルの実行権限を付与する。
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# wheneverでcrontab書き込み
RUN bundle exec whenever --update-crontab 

# cronをフォアグラウンド実行
CMD ["cron", "-f"]