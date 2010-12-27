#!/usr/bin/env ruby

require "compass"

require "sinatra"
require "sinatra/reloader" if development?

require "haml"
require "sass"

configure do
  Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config', 'compass.rb'))
end

get "/stylesheets/:name.css" do
  content_type 'text/css', :charset => 'utf-8'
  sass(:"stylesheets/#{params[:name]}", Compass.sass_engine_options)
end

get "/" do
  haml :index
end
