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
    if db.execute("SELECT Username FROM users WHERE Username = ?", params["username"]).first
        redirect('/failedregister')
    else
        db.execute("INSERT INTO users(Username, Password) VALUES(?, ?)", params["username"], hashed_pass)
    end
end

def post()
    db = connect()
    if params["publish"] != nil
        if params["header"].length == 0 || params["post"].length == 0
            return 
        end 

    end
    img = params["file"]

    if img != nil
        new_name = SecureRandom.uuid + ".jpg"
        FileUtils.copy(img["tempfile"], "./public/img/#{new_name}")

        db.execute("INSERT INTO bloggposts(Header, Post, UserId, Images) VALUES(?, ?, ?, ?)", params["header"], params["post"], session[:userId], new_name) 
    
    else 
        db.execute("INSERT INTO bloggposts(Header, Post, UserId) VALUES(?, ?, ?)", params["header"], params["post"], session[:userId])

    end

end

def likes_dislikes()
    db = connect()  

    liked_posts = db.execute("SELECT UploadId FROM likesdislikes WHERE UserId = ?", session[:userId])
    
    liked = false
    liked_posts.each do |post|
        if post["UploadId"] == params["like"].to_i || post["UploadId"] == params["dislike"].to_i
            liked = true
            break
        end
    end

    if liked == false
        if params["like"] != nil
            has_liked = 1
            db.execute("INSERT INTO likesdislikes(UploadId, UserId) VALUES(?, ?)", params["like"], session[:userId])
            postid = params['like']
        else
            has_liked = -1
            db.execute("INSERT INTO likesdislikes(UploadId, UserId) VALUES(?, ?)", params["dislike"], session[:userId])
            postid = params['dislike']
        end
        
        like_counter = db.execute("SELECT Likes FROM bloggposts WHERE PostId = ?", postid).first["Likes"]
        
        if like_counter == nil
            like_counter = 0
        end
        like_counter += has_liked

        db.execute("UPDATE bloggposts SET Likes = ? WHERE PostId = ?", like_counter, postid)
    end
end

def verif()
    db = connect()
    verification = db.execute("SELECT Username, Password FROM users WHERE Id = ?", session[:userId])
    if verification['Username'] == params["username"]
        if verification['Password'] == params["password"]
            
        end
    end

end

def del_post()
    db = connect() 
    db.execute("DELETE FROM bloggposts WHERE PostId = ?", params["delete"])
    db.execute("DELETE FROM likesdislikes WHERE UploadId = ?", params["delete"])
end
