# frozen_string_literal: true

require 'securerandom'
require 'yaml'
require 'pg'

# メモのデータ操作モジュール
class Memo
  MEMOS_TABLE = 'memos'
  private_constant :MEMOS_TABLE

  class << self
    def create_table
      result = @conn.exec("SELECT * FROM information_schema.tables WHERE table_name = 'memos'")
      @conn.exec('CREATE TABLE memos (id uuid default gen_random_uuid() primary key, title text not null, content text)') if result.values.empty?
    end

    def create_db
      config = YAML.load_file('config.yml')
      conn = PG.connect(
        host: config['host'],
        dbname: 'postgres',
        user: config['user'],
        password: config['password'],
        port: config['port']
      )
      result = conn.exec("SELECT 1 FROM pg_database WHERE datname = '#{config['db']}'")
      conn.exec("CREATE DATABASE #{config['db']} ENCODING 'UTF-8' TEMPLATE template0") if result.values.empty?
    rescue PG::Error => e
      STDERR.puts "データベースの作成に失敗しました。: #{e.message}"
    ensure
      conn&.close
    end

    def connect_to_db
      config = YAML.load_file('config.yml')
      begin
        @conn = PG.connect(
          host: config['host'],
          dbname: config['db'],
          user: config['user'],
          password: config['password'],
          port: config['port']
        )
      rescue PG::ConnectionBad => e
        STDERR.puts "DBに接続できません。config.ymlを確認してください。\n#{e}"
        exit
      end
    end

    def setup
      create_db
      connect_to_db
      create_table
    end

    def fetch_memos_id_title
      memo_list = @conn.exec("SELECT * FROM #{MEMOS_TABLE}")
      memo_list.map { |memo| { 'id' => memo['id'], 'title' => memo['title'] } }
    end

    def add_new_memo(memo_title, memo_content)
      id = SecureRandom.uuid
      insert_query = "INSERT INTO #{MEMOS_TABLE} VALUES($1, $2, $3)"
      insert_params = [id, memo_title, memo_content]
      @conn.exec(insert_query, insert_params)
    end

    def fetch_memo_data(id)
      select_query = "SELECT * FROM #{MEMOS_TABLE} WHERE id = $1"
      select_params = [id]
      @conn.exec(select_query, select_params).tuple_values(0)
    end

    def update_memo(id, memo_title, memo_content)
      update_query = "UPDATE #{MEMOS_TABLE} SET title = $1, content = $2 WHERE id = $3"
      update_params = [memo_title, memo_content, id]
      @conn.exec(update_query, update_params)
    end

    def delete_memo(id)
      delete_query = "DELETE FROM #{MEMOS_TABLE} WHERE id = $1"
      delete_params = [id]
      @conn.exec(delete_query, delete_params)
    end
  end
end
