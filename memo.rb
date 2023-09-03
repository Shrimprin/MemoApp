# frozen_string_literal: true

require 'securerandom'
require 'yaml'
require 'pg'

# メモのデータ操作モジュール
class Memo
  MEMOS_TABLE = 'memos'
  class << self
    def connet_to_db
      config = YAML.load_file('config.yml')
      dbname = config['db']
      host = config['host']
      user = config['user']
      password = config['password']
      port = config['port']
      begin
        @conn = PG.connect(host:, dbname:, user:, password:, port:)
      rescue PG::ConnectionBad => e
        puts "DBに接続できません。config.ymlを確認してください。\n#{e}"
        exit
      end
    end

    def create_memos_table
      result = @conn.exec("SELECT * FROM information_schema.tables WHERE table_name = 'memos'")
      @conn.exec('CREATE TABLE memos (id varchar(36) primary key, title varchar(255) not null, content text)') if result.values.empty?
    end

    def fetch_memo_list
      @conn.exec("SELECT * FROM #{MEMOS_TABLE}")
    end

    def fetch_memos_id_title
      memo_list = fetch_memo_list
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
