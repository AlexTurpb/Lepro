#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'lepro.db'
	@db.results_as_hash = true
end

before do
	init_db
end

configure do
	init_db

	@db.execute 'Create table if not exists Posts
		(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			created_date DATE,
			content TEXT
		)'

	@db.execute 'Create table if not exists Coments
		(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			created_date DATE,
			content TEXT,
			post_id INTEGER
		)'	
end

get '/' do
	@results = @db.execute 'select * from posts order by created_date desc'
	erb :index			
end

get '/new' do
	erb :new
end

post '/new' do
	content = params[:content]

	if content.length <= 0
		@error = "Enter post text"
		return erb :new
	end

	@db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]

	redirect to '/'
end

#post info show
get '/details/:post_id' do
	post_id = params[:post_id]

	results = @db.execute 'select * from Posts where id = ?', [post_id]
	@row = results[0]

	@comments = @db.execute 'select * from Coments where post_id = ? order by id', [post_id] 
	erb :details
end

post '/details/:post_id' do
	post_id = params[:post_id]
	content = params[:content]

	@db.execute 'insert into Coments
	(
		content,
		created_date,
		post_id
	)
		values
	(
		?,
		datetime(),
		?
	)', [content, post_id]

	redirect to ('/details/' + post_id)
end
