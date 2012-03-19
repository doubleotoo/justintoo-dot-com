require 'sinatra'
require 'haml'
require 'builder'
require 'yaml'
require 'cgi'

require 'index'
require 'index_reader'
require 'article_not_found'
require 'article'
require 'oldness'
require 'contents_storage'
require 'disqus'
require 'contents'
require 'archive'
require 'helpers'

include Helpers

set :haml, :format => :html5, :ugly => true
set :root, File.expand_path('../..', __FILE__)

before do
  no_www!
  no_dates!
  no_trailing_slashes!
  @description = "justintoo.com is a blog to write things on purpose, written by Justin Too."
end

get '/' do
  static
  @intro = :index_intro
  haml :index
end

get '/channel.html' do
  static
  cache_expire=60*60*24*365
  expires cache_expire, :public, :max_age => cache_expire
  haml :channel
end

get '/feed' do
  static archive.last.published_at.to_s
  builder :rss
end

get '/articles' do
  static
  @title = "All articles on justintoo.com"
  @intro = :archive_intro
  haml :archive
end

get '/articles/:article' do |article_title|
  redirect to("/#{article_title}")
end
get '/:article' do |article_title|
  # matches "GET /hello-world"
  # params[:article] is 'hello-world'
  @article = Index.find(article_title)
  if @article.found?
    static
    @title       = "#{@article.title} - justintoo"
    @description = @article.summary
    @intro       = :article_intro
    haml :article # render views/article.haml
  else
    pass # punt processing to the next matching route
  end
end

not_found do
  static "NOTFOUND"
  @intro = :not_found_intro
  haml :not_found
end

