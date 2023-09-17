#!/usr/bin/env ruby
# frozen_string_literal: true

require 'sinatra/base'
require_relative './memo_manager'

class Router < Sinatra::Base
  enable :method_override

  def initialize
    super
    @memo_manager = MemoManager.new
  end

  get '/' do
    redirect '/memos'
  end

  get '/memos' do
    # メモ一覧(ホーム画面)の表示
    @memos = @memo_manager.find_all
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
    @memo_manager.add(params[:title], params[:content])

    redirect '/memos'
  end

  get '/memos/:id' do |id|
    # メモの表示
    @memo = @memo_manager.find(id)
    halt 404 if @memo.nil?

    erb :show
  end

  get '/memos/:id/edit' do |id|
    # メモの編集画面の表示
    @memo = @memo_manager.find(id)
    halt 404 if @memo.nil?

    erb :edit
  end

  patch '/memos/:id' do |id|
    # メモの更新
    @memo_manager.update(id, params[:title], params[:content])

    redirect '/memos'
  end

  delete '/memos/:id' do |id|
    # メモの削除
    @memo_manager.delete(id)

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
end

Router.run!
