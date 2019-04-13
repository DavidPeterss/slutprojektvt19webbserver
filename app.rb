require 'slim'
require 'sqlite3'
require 'sinatra'
require 'bcrypt'
require 'byebug'
require 'securerandom'
require_relative './controller.rb'
require 'fileutils'

enable :sessions

get('/') do
    bloggposts = bloggposts()
    slim(:index, locals:{bloggposts:bloggposts})
end

get('/loggedin') do
    bloggposts = bloggposts()
    slim(:loggedin, locals:{bloggposts:bloggposts})
end

get('/register') do
    slim(:register)
end

get('/failed') do
    slim(:failed)
end

post('/register') do
    register()
    redirect('/')
end

post('/login') do 
    user = login()

    if user == nil
        redirect('/failed')
    end
    hashed_pass = BCrypt::Password.new(user["Password"])

    if hashed_pass == params["password"]
        session[:username] = params["username"]
        session[:userId] = user["Id"]
    else
        redirect('/failed')
    end
    redirect('/loggedin')
end

#Uppladdning
post('/upload') do
    post()
    redirect('/loggedin')
end

post('/logout') do
    session.destroy
    redirect('/')
end

post('/like') do
    likes_dislikes()
    redirect('/loggedin')
end
