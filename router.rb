#!/usr/bin/env ruby
# frozen_string_literal: true

require 'sinatra'
require 'cgi'
require './memo'

set :environment, :production

configure do
  Memo.connet_to_db
  Memo.create_memos_table
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  # メモ一覧(ホーム画面)の表示
  @memos_id_title = Memo.fetch_memos_id_title
  @page_title = 'メモ一覧'

  erb :memos
end

get '/memos/new' do
  # 新規メモ作成画面の表示
  @page_title = '新規作成'

  erb :new
end

post '/memos' do
  # 新規メモの保存
  Memo.add_new_memo(params[:memo_title], params[:memo_content])

  redirect '/memos'
end

get '/memos/:id' do |id|
  # メモの表示
  memo_data = Memo.fetch_memo_data(id)
  halt 404 if memo_data.nil?

  @memo_id = memo_data[0]
  @memo_title = memo_data[1]
  @memo_content = memo_data[2]
  erb :show
end

get '/memos/:id/edit' do |id|
  # メモの編集画面の表示
  memo_data = Memo.fetch_memo_data(id)
  halt 404 if memo_data.nil?

  @memo_id = memo_data[0]
  @memo_title = memo_data[1]
  @memo_content = memo_data[2]
  erb :edit
end

patch '/memos/:id' do |id|
  # メモの更新
  Memo.update_memo(id, params[:memo_title], params[:memo_content])

  redirect '/memos'
end

delete '/memos/:id' do |id|
  # メモの削除
  Memo.delete_memo(id)

  redirect '/memos'
end

error do
  status 500
  '500 Server Error'
end

not_found do
  status 404
  '404 Not Found - ページが存在しません'
end
