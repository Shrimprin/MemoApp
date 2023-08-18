#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'cgi'

# メモのデータ操作クラス
class Memo
  MEMOS_PATH = './public/memos.json'

  class << self
    def sanitize_str(str)
      CGI.escapeHTML(str)
    end

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
      max_id = memo_list.map { |memo| memo['id'] }.max || 0
      sanitized_memo_title = memo_title
      sanitized_memo_content = memo_content
      new_memo_data = { 'id' => max_id + 1, 'title' => sanitized_memo_title, 'content' => sanitized_memo_content }
      memo_list.push(new_memo_data)
      File.write(MEMOS_PATH, JSON.generate(memo_list))
    end

    def fetch_memo_data(id, memo_list = nil)
      memo_list = fetch_memo_list if memo_list.nil?
      memo_list.find { |memo| memo['id'] == id.to_i }
    end

    def update_memo(id, memo_title, memo_content)
      memo_list = fetch_memo_list
      memo_data = fetch_memo_data(id, memo_list)
      sanitized_memo_title = memo_title
      sanitized_memo_content = memo_content
      memo_data['title'] = sanitized_memo_title
      memo_data['content'] = sanitized_memo_content
      File.write(MEMOS_PATH, JSON.generate(memo_list))
    end

    def delete_memo(id)
      memo_list = fetch_memo_list
      memo_list.reject! { |memo| memo['id'] == id.to_i }
      File.write(MEMOS_PATH, JSON.generate(memo_list))
    end
  end
end
