require 'slim'
require 'sqlite3'
require 'sinatra'
require 'bcrypt'
require 'byebug'
require 'securerandom'
require 'fileutils'
    
def connect()
    db = SQLite3::Database.new("db/users.db")
    db.results_as_hash = true
    return db
end

def bloggposts()
    db = connect()
    posts = db.execute("SELECT * FROM bloggposts ORDER BY Timestamp DESC LIMIT 20")
    return posts
end

def login()
    db = connect()
    result = db.execute("SELECT Id, Password FROM users WHERE Username = ?", params["username"])
    return result.first
end

def register()
    db = connect()
    hashed_pass = BCrypt::Password.create(params["password"])
    db.execute("INSERT INTO users(Username, Password) VALUES(?, ?)", params["username"], hashed_pass)
end


#Gör posts med bilder
#Sätta PostId i likesdislikes mot postid i bloggposts, de behöver vara samma. 
#Kanske göra uploadid som autoincrement och ta bort alla nuvarande inlägg, därav behöver jag endast lägga till session :userid
def post()
    db = connect()
    img = params["file"]
    id = db.execute("SELECT PostId FROM bloggposts WHERE UserId = ? ORDER BY PostId DESC LIMIT 1", session[:userId])
    if img != nil
    new_name = SecureRandom.uuid + ".jpg"
    FileUtils.copy(img["tempfile"], "./public/img/#{new_name}")
        db.execute("INSERT INTO bloggposts(Header, Post, UserId, Images) VALUES(?, ?, ?, ?)", params["header"], params["post"], session[:userId], new_name) 
        db.execute("INSERT INTO likesdislikes(UserId, UploadId) VALUES(?, ?)", session[:userId], id)
    else 
        byebug
        db.execute("INSERT INTO bloggposts(Header, Post, UserId) VALUES(?, ?, ?)", params["header"], params["post"], session[:userId])
        db.execute("INSERT INTO likesdislikes(UserId, UploadId) VALUES(?, ?)", session[:userId], id)
    end
end

def likes_dislikes()
    db = connect()    
    like_counter = 0
    dislike_counter = 0
    #db.execute("SELECT Id FROM bloggposts INNER JOIN likesdislikes ON bloggposts.PostId = likesdislikes.PostId")
    if params["like"] != nil
        like_counter += 1
        byebug
        db.execute("INSERT INTO likesdislikes(Likes) VALUES(?) WHERE Id ?", like_counter, params["like"])
    elsif params["dislike"] != nil
        dislike_counter += 1
        byebug
        db.execute("INSERT INTO bloggposts(Dislikes) VALUES(?) WHERE Id = ?", dislike_counter, params["dislike"])
    end
end

