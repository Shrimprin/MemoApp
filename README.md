# MemoApp
ブラウザ上でメモを作成できるアプリケーションです。

# 使い方
本アプリケーションを使用するためにはRubyとPostgreSQLのインストールが必要です。
1. このリポジトリを自身の端末にクローンする。
2. Gemをインストールする。
    ```
    bundle install
    ```
3. [config.yml](./config.yml)にメモを保存する任意のDBの情報を入力する。\
  DBが存在しない場合、アプリケーション起動時に自動で作成されます。\
  また、テーブルも自動で作成されます。
    * host : DBのホスト名
    * db : DB名
    * user : DBに接続するユーザー名
    * password : ユーザーがDBに接続するパスワード
    * port : DBのポート番号

4. アプリケーションを起動する。
    ```
    ruby router.rb
    ```
5. ブラウザからアプリケーションにアクセスする。\
http://localhost:4567
# 主な機能
* メモの閲覧\
ホームページにはメモの一覧が表示されます。タイトルをクリックすることでメモの内容を閲覧できます。
* メモの作成\
`新規メモ`ボタンを押すことで新しいメモを作成できます。
* メモの編集\
メモの閲覧中に`編集`ボタンを押すことで、メモのタイトルと内容を編集できます。
* メモの削除\
メモの閲覧中に`削除`ボタンを押すことで、メモを削除できます。
# 必要なライブラリ
* Sinatra
* Webrick
* pg
# プロジェクトの構成
* router.rb\
リクエストに対してルーティングを処理します。
* memo_manager.rb\
メモのデータ操作を行います。
* config.yml\
メモのデータを保存するDBの設定を記述するファイルです。
