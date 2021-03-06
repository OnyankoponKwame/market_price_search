# README
## ■ URL
https://frimachart.com/
## ■ サービス概要
フリマサイトで売り時が知りたい方や売れる価格が知りたい人のためのサービスです。  
価格情報を取得して、価格推移、価格散布図、直近で売れた価格のヒストグラムを表示します。  
また定期実行登録をすることで毎日指定した条件で価格情報を取得し、自動で保存します。

## ■メインのターゲットユーザー
- フリマで出品する人
- 物での投機がしたい人

## ■ユーザーが抱える課題
商品をいくらで出品すれば売れるか分からない。価格推移が分からない。

## ■解決方法
実際に売れている価格と売り出し中の価格がグラフで直感的に把握でき、値付けを適切にサポートします。  
定期実行登録をすることで価格推移を自動でトラッキングしてくれます。

## ■機能
実装中の機能
- 検索機能
- 定期実行機能
- 管理機能（管理者向け）

追加予定の機能
- 日別、週別、月別のグラフ表示機能

## ■なぜこのサービスを作ったのか
トレーディングカードのように価格が大きく変動する投機対象になりうる品物について  
株式市場のようなチャートが存在しないため、このサービスによって価格を追跡できるようにし  
分析することで有利な投資行動を取れると考えたため。  
また、物を売る際に売れている価格と出品されている価格に差異があったりして実際の  
相場を把握することが難しいと感じたことから、売る際の価格決定を補助したいという思いから。

## ■言語・使用技術等
フロントエンド　HTML/CSS/Sass/JavaScript/TypeScript/Bootstrap 5.2.0/Vue 3.2.31/chart.js 3.7.1

バックエンド　Ruby 3.1.2/Rails 6.1.5/Selenium 4.0.0/cron

## ■インフラ
本番環境
- Sakura VPS
- Puma 5.6.4
- Capistrano 3.17.0
- Nginx 1.22.0
- MySQL 8.0.29 

開発環境
- Docker
- docker-compose

## ■工夫した点
- 取得した知識が無駄にならないよう、できるだけ最新のバージョン(Vue3,Chart.js3等)を使用するようにした。
- レスポンシブ対応。スマートフォンでは絞り込みを折りたたみメニューにすることで視認性を向上。
- グラフの表示にあたっては、ただ取得したデータを表示しているだけでなく様々な加工を行なっている。ヒストグラムではデータ数・価格に応じて自動的に階級数・階級幅を決定。外れ値除外。平均値・中央値・最頻値の取得など。
- あえて会員登録を省き、ローカルストレージを使用することで気軽に使えるように。検索履歴が表示されるため再アクセス時にもすぐに前回の検索条件で検索できる。
- chart.jsのカスタマイズ。価格散布図の点から実際の商品リンクへ飛べるように
自力でカスタマイズしている。

## ■ER図
https://i.gyazo.com/bac61c9fc0e7bd8c20db37bf8eb32cfe.png

## ■動作イメージ
PC表示  

![イメージ１](https://i.gyazo.com/4219180e3a1c64d857bd1c5f16213d0c.gif)
スマートフォン表示  

![イメージ2](https://i.gyazo.com/6e8ad3daf8c562360c558add82375a9c.gif)
