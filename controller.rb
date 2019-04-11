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
def post()
    db = connect()
    img = params["file"]
    if img != nil
    new_name = SecureRandom.uuid + ".jpg"
    FileUtils.copy(img["tempfile"], "./public/img/#{new_name}")
    
        db.execute("INSERT INTO bloggposts(Header, Post, UserId, Images) VALUES(?, ?, ?, ?)", params["header"], params["post"], session[:userId], new_name) 
    else 
        db.execute("INSERT INTO bloggposts(Header, Post, UserId) VALUES(?, ?, ?)", params["header"], params["post"], session[:userId])
    end

end

