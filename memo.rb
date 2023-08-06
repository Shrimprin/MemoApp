require 'sinatra'

set :environment, :production

def fetch_memo_titles
  text_files = Dir.glob(File.join('./public/memos', '*.txt'))
  text_files.map { |file| File.basename(file, '.txt') }
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  # メモ一覧(ホーム画面)の表示
  @memo_titles = fetch_memo_titles
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
  file_name = params[:memo_title]
  file_path = "./public/memos/#{file_name}.txt"

  File.open(file_path, "w") do |file|
    file.puts(params[:memo_content])
  end

  redirect '/memos'
end

get '/memos/:title' do |memo_title|
  # メモの表示
  @memo_title = memo_title
  memo_file = "./public/memos/#{memo_title}.txt"
  @memo_content = File.read(memo_file)

  erb :show
end

get '/memos/:title/edit' do |memo_title|
  # メモの編集画面の表示
  @memo_title = memo_title
  file_path = "./public/memos/#{memo_title}.txt"
  File.open("./public/memos/#{memo_title}.txt", "r") do |file|
    @memo_content = file.read
  end

  erb :edit
end

patch '/memos/:title' do |memo_title|
  # メモの更新
  file_name = params[:memo_title]

  # タイトルが変わっていたら古いファイルを削除する
  if memo_title != file_name
    old_file_path = "./public/memos/#{memo_title}.txt"
    File.delete(old_file_path) if File.exist?(old_file_path)
  end

  file_path = "./public/memos/#{file_name}.txt"
  File.open(file_path, "w") do |file|
    file.puts(params[:memo_content])
  end

  redirect '/memos'
end

delete '/memos/:title' do |memo_title|
  # メモの削除
  file_path = "./public/memos/#{memo_title}.txt"
  File.delete(file_path) if File.exist?(file_path)

  redirect '/memos'
end
