#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'securerandom'

# メモのデータ操作クラス
class Memo
  MEMOS_PATH = './public/memos.json'

  class << self
    def fetch_memo_list
      json_data = File.read(MEMOS_PATH)
      JSON.parse(json_data)
    end

    def fetch_memos_id_title
      memo_list = fetch_memo_list
      memo_list.map { |memo| { 'id' => memo['id'], 'title' => memo['title'] } }
    end

    def add_new_memo(memo_title, memo_content)
      memo_list = fetch_memo_list
      id = SecureRandom.uuid
      new_memo_data = { 'id' => id, 'title' => memo_title, 'content' => memo_content }
      memo_list.push(new_memo_data)
      File.write(MEMOS_PATH, JSON.generate(memo_list))
    end

    def fetch_memo_data(id, memo_list = nil)
      memo_list = fetch_memo_list if memo_list.nil?
      memo_list.find { |memo| memo['id'] == id }
    end

    def update_memo(id, memo_title, memo_content)
      memo_list = fetch_memo_list
      memo_data = fetch_memo_data(id, memo_list)
      memo_data['title'] = memo_title
      memo_data['content'] = memo_content
      File.write(MEMOS_PATH, JSON.generate(memo_list))
    end

    def delete_memo(id)
      memo_list = fetch_memo_list
      memo_list.reject! { |memo| memo['id'] == id }
      File.write(MEMOS_PATH, JSON.generate(memo_list))
    end
  end
end
