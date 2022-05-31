# whenever 定期実行
#  rake 'ファイル名':タスク名'
# Rails.root(Railsメソッド)を使用するために必要
require File.expand_path(File.dirname(__FILE__) + '/environment')

# rake用job_typeの再定義
set :job_template, "/bin/zsh -l -c ':job'"
# .zshrcとrbenvのパスを指定するrakeを定義
job_type :rake, 'source $HOME/.zshrc; cd :path && RAILS_ENV=:environment bundle exec rake :task :output'
# job_type :rake, 'source $HOME/.zshrc; exportPATH =\"$HOME/.rbenv/bin:$PATH\"; cd :path && RAILS_ENV=:environment bundle exec rake :task :output'

# cronを実行する環境変数(:development, :product, :test)
# 環境変数'RAILS_ENV'にセットされている変数またはdevelopmentを指定
rails_env = ENV['RAILS_ENV'] || :development

# cronを実行する環境変数をセット
# 今回はdevelopmentをセット
set :environment, rails_env

# cronのログの吐き出し場所
set :output, "#{Rails.root}/log/cron.log"

# test
# every 10.minute do
#   rake 'items:update_items'
# end

# 毎日4:30に実行
every 1.day, at: '4:30 am' do
  rake 'items:update_items'
end
