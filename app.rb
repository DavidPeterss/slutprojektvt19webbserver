require 'slim'
require 'sqlite3'
require 'sinatra'
require 'bcrypt'
require 'byebug'
require_relative './controller.rb'

enable :sessions

get('/') do
    slim(:index)
end

get('/loggedin') do
    slim(:loggedin)
end

get('/register') do
    slim(:register)
end

post('/register') do
    register()
    redirect('/')
end

post('/login') do 
end