# coding: utf-8
require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'
require 'csv'
require 'pstore'

before do 
  @db = PStore.new("db")
end

helpers do
  def create_table csv
    CSV.parse(csv,col_sep: "\t")
  end
end

get '/' do
  @table = [["col"],["value"]]
  haml :index
end

post '/' do
  @table = create_table params[:csv]
  @title = params[:title]
  @db.transaction do |db|
    db[@title] = @table
  end
  haml :index
end

get "/:title" do
  @title = params[:title]
  @db.transaction do |db|
    @table = db[@title] 
  end
  redirect "/" if !@table
  haml :index
end

__END__
@@layout
-# coding: utf-8
!!!5
%html{lang: "ja"}
  %head
    %meta{charset: "utf-8"}
    %title= "TablizeWorld" + request.path.split("/").join(" - ")
    %link{:rel=>"stylesheet",:href=>"/bootstrap/css/bootstrap.min.css"}
    %link{:rel=>"stylesheet",:href=>"/bootstrap/css/bootstrap-responsive.min.css"}
    %link{:rel=>"stylesheet",:href=>"/asset/stylesheets/main.css"}
    %meta{:name=>"Description" ,:content=>""}
    %meta{:name=>"Keywords" ,:content=>""}
    %meta{:name=>"viewport",:content=>"width=device-width, user-scalable=no, initial-scale=1, maximum-scale=1"}
  %body
    %div.container-fluid
      %div.row-fluid
        != yield 

@@index
-# coding: utf-8
%div.span9
  %div.hero-unit
    %h2
      Hello,Tablize World
  .row-fluid
    .span
      %form{method: "POST", action: "/"}
        %div
          %input{name: "title",placeholder: "Title"}
        %div
          %textarea{name: "csv",placeholder: "Paste CSV"}
        %button{:type=>"submit"} Tablize
      %a{href: "http://#{request.host}:#{request.port}/#{@title.to_s}"}
        %h3= "Table: #{@title.to_s}"
      %table.table.table-striped
        %tbody
          %tr
            - first_row = @table.shift
            - first_row.each do |c|
              %th= c.to_s
          - @table.each do |row|
            %tr
            - row.each do |c|
              %td= c.to_s
