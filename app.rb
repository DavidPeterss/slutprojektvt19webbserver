require 'slim'
require 'sqlite3'
require 'sinatra'
require 'bcrypt'
require 'byebug'
require 'securerandom'
require_relative './model.rb'
require 'fileutils'

enable :sessions

# Checks which paths a non-user is allowed to visit and redirects to '/failed' if the user is authorized to be in a certain path
#
before do 
    if request.path != '/' && request.path != '/login' && request.path != '/failed' && request.path != '/register' && session[:userId] == nil
        redirect('/failed')
    end
end

# Display landing page
#
# @param [Integer] like, Id of the post which has been liked
# @param [Integer] dislike, Id of the post which has been disliked
#
# @see Model#bloggposts 
get('/') do
    bloggposts = bloggposts(params)
    slim(:index, locals:{bloggposts:bloggposts})
end

# Displays logged in page
#
# @see Model#bloggposts
get('/loggedin') do
    bloggposts = bloggposts(params)
    slim(:loggedin, locals:{bloggposts:bloggposts, username:session[:username]})
end

#Displays register page
#
get('/register') do
    slim(:register)
end

# Displays failed login page
#
get('/failed') do
    slim(:failed)
end

# Displays edit profile page
#
get('/editprofile') do
    slim(:editprofile)
end

# Displays failed register when selected username already exists
#
get('/failedregister') do 
    slim(:failedregister)
end


post('/register') do
    register()
    redirect('/')
end

# Checks if username and password correspond with a signed up user in the database and redirects to '/loggedin' if successful and '/failed' if the credentials are incorrect
#
# @param [String] username, Username of current user  
# @param [String] password, Password of current user
#
# @see Model#login
post('/login') do 
    user = login(params)

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

# Uppladdning
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

post('/editpro') do
    updatepro()
    redirect('/editprofile')
end

post('/del') do 
    del_post()
    redirect('/loggedin')
end


error 404 do
    redirect('/failed')
end