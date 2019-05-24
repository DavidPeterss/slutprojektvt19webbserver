require 'slim'
require 'sqlite3'
require 'sinatra'
require 'bcrypt'
require 'byebug'
require 'securerandom'
require_relative './model.rb'
require 'fileutils'

# Displays an error message
#
helpers do
    def get_error()
        error = session[:msg].dup
        session[:msg] = nil
        return error
    end

    def error?
        !session[:msg].nil?
    end
end
enable :sessions

# Checks which paths a non-user is allowed to visit and redirects to '/failed' if the user is unauthorized to be in a certain path
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
    likes = count_likes()
    slim(:loggedin, locals:{bloggposts:bloggposts, username:session[:username], likes:likes})
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

# Attempts register and redirects to index page if successful
# @param [String] password, The password
# @param [String] username, The username
#
# @see Model#register
post('/register') do
    res = register(params)
    if res[:error] == true
        session[:msg] = res[:message]
        return redirect('/register')
    end
    redirect('/')
end

# Attempts login and updates session
#
# @param [String] username, Username of current user  
# @param [String] password, Password of current user
#
# @see Model#login
post('/login') do 
    res = login(params)

    if res[:error] == true
        session[:msg] = res[:message]
        return redirect('/')
    end
    redirect('/loggedin')
end

# All information about to be posted to the website gets inserted to the database through this function.
#
# @param [Button] publish, Button that user pushes when ready to publish
# @param [String] header, Header of the actual post
# @param [String] post, larger text under the header of the post
#
# @see Model#post
post('/upload') do
    res = post(params, userId)

    if res[:error] == true
        session[:msg] = res[:message]
    end
    redirect('/loggedin')
end

# If logout button is pushed the session is destroyed and the user is directed back to the index page
#
post('/logout') do
    session.destroy
    redirect('/')
end

# Attempts to like or dislike a post
#
# @param [Integer] like, Id of the post which has been liked
# @param [Integer] dislike, Id of the post which has been disliked
#
# @see Model#likes_dislikes
post('/like') do
    res = likes_dislikes(params, userId)

    if res[:error] == true
        session[:msg] = res[:message]
    end

    if session['userId'] != nil
        likes_dislikes(params, userId) 
        redirect('/loggedin')
    end
end

# Attempts to update the users credentials (Username, and password)
#
# @param [Button] profilechange, Button pressed when the user is ready to change credentials
# @param [String] new_name, New username
# @param [String] new_pass, New password
#
# @see Model#updatepro
post('/editpro') do
    res = updatepro(params, userId)
    if res[:error] == true
        session[:msg] = res[:message]
    end

    if session['userId'] != nil
        updatepro(params, userId)
    end
    redirect('/editprofile')
end

# Deletes current users post
#
# @param [Button] delete, Delete button
#
# @see Model#del_post
post('/del') do 
    res = del_post(params, userId)
    if res[:error] == true
        session[:msg] = res[:message]
    end

    if session['userId'] != nil
        del_post(params, userId)
    end
    redirect('/loggedin')
end

# Redirects to failed page if site crashes
#
error 404 do
    redirect('/failed')
end