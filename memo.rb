# frozen_string_literal: true

require 'securerandom'
require 'yaml'
require 'pg'

# メモのデータ操作クラス
class Memo
  MEMOS_TABLE = 'memos'
  private_constant :MEMOS_TABLE

  def find_memos
    memo_list = @conn.exec("SELECT * FROM #{MEMOS_TABLE}")
    memo_list.map { |memo| { 'id' => memo['id'], 'title' => memo['title'] } }
  end

  def find_memo(id)
    select_query = "SELECT * FROM #{MEMOS_TABLE} WHERE id = $1"
    select_params = [id]
    memo = @conn.exec(select_query, select_params).tuple_values(0)
    {
      id: memo[0],
      title: memo[1],
      content: memo[2]
    }
  end

  def add_new_memo(memo_title, memo_content)
    insert_query = "INSERT INTO #{MEMOS_TABLE} (title, content) VALUES($1, $2)"
    insert_params = [memo_title, memo_content]
    @conn.exec(insert_query, insert_params)
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

  private

  def initialize
    @config = YAML.load_file('config.yml')
    create_db
    connect_to_db
    create_table
  end

  def create_db
    conn = PG.connect(
      host: @config['host'],
      dbname: 'postgres',
      user: @config['user'],
      password: @config['password'],
      port: @config['port']
    )
    select_query = 'SELECT 1 FROM pg_database WHERE datname = $1'
    select_params = [@config['db']]
    result = conn.exec(select_query, select_params)
    conn.exec("CREATE DATABASE #{@config['db']} ENCODING 'UTF-8' TEMPLATE template0") if result.values.empty?
  rescue PG::Error => e
    warn "データベースの作成に失敗しました。config.ymlを確認してください。: #{e.message}"
    exit
  ensure
    conn&.close
  end

  def connect_to_db
    @conn = PG.connect(
      host: @config['host'],
      dbname: @config['db'],
      user: @config['user'],
      password: @config['password'],
      port: @config['port']
    )
  rescue PG::ConnectionBad => e
    warn "DBに接続できません。\n#{e}"
  end

  def create_table
    result = @conn.exec("SELECT * FROM information_schema.tables WHERE table_name = 'memos'")
    @conn.exec("CREATE TABLE #{MEMOS_TABLE} (id uuid default gen_random_uuid() primary key, title text not null, content text)") if result.values.empty?
  end
end
