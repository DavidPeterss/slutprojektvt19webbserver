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

def bloggposts(params)
    db = connect()
    likes = db.execute("SELECT SUM(type) AS score FROM likesdislikes WHERE UploadId = ?", params["like"])
    dislikes = db.execute("SELECT SUM(type) AS score FROM likesdislikes WHERE UploadId = ?", params["dislike"])
    if likes.first["score"] == nil || dislikes.first["score"] == nil
        posts = db.execute("SELECT * FROM bloggposts ORDER BY TIMESTAMP DESC LIMIT 20")
        byebug
    elsif likes.first["score"] != nil
        posts = db.execute("SELECT Header, Post, PostId, bloggposts.UserId, Images, SUM(likesdislikes.type) AS score FROM bloggposts INNER JOIN likesdislikes ON likesdislikes.UploadId = bloggposts.PostId  WHERE likesdislikes.UploadId = ? ORDER BY TIMESTAMP DESC LIMIT 20", params["like"])
        byebug
    else
        posts = db.execute("SELECT Header, Post, PostId, bloggposts.UserId, Images, SUM(likesdislikes.type) AS score FROM bloggposts INNER JOIN likesdislikes ON likesdislikes.UploadId = bloggposts.PostId  WHERE likesdislikes.UploadId = ? ORDER BY TIMESTAMP DESC LIMIT 20", params["dislike"])
    end
    return posts
end

def login(params)
    db = connect()
    result = db.execute("SELECT Id, Password FROM users WHERE Username = ?", params["username"])
    return result.first
end

def register(params)
    db = connect()
    hashed_pass = BCrypt::Password.create(params["password"])
    if db.execute("SELECT Username FROM users WHERE Username = ?", params["username"]).first
        redirect('/failedregister')
    else
        db.execute("INSERT INTO users(Username, Password) VALUES(?, ?)", params["username"], hashed_pass)
    end
end

def post(params, session)
    db = connect()
    if params["publish"] != nil
        if params["header"].length == 0 || params["post"].length == 0
            return {
                error: true,
                message: "Something went wrong while uploading, please try again"
            }
        end 

    end
    img = params["file"]

    if img != nil
        new_name = SecureRandom.uuid + ".jpg"
        FileUtils.copy(img["tempfile"], "./public/img/#{new_name}")

        db.execute("INSERT INTO bloggposts(Header, Post, UserId, Images) VALUES(?, ?, ?, ?)", params["header"], params["post"], session['userId'], new_name) 
        return {
            error: false
        }
    else 
        db.execute("INSERT INTO bloggposts(Header, Post, UserId) VALUES(?, ?, ?)", params["header"], params["post"], session['userId'])
        return {
            error: false
        }
    end

end

def likes_dislikes(params, session)
    db = connect()  

    liked_posts = db.execute("SELECT UploadId FROM likesdislikes WHERE UserId = ?", session['userId'])
    
    liked = false
    liked_posts.each do |post|
        if post["UploadId"] == params["like"].to_i || post["UploadId"] == params["dislike"].to_i
            liked = true
            break
        elsif post["UploadId"] == nil
            redirect('/failed')
        end
    end


    if liked == false
        if params["like"] != nil
            has_liked = 1
            db.execute("INSERT INTO likesdislikes(UploadId, UserId, type) VALUES(?, ?, ?)", params["like"], session['userId'], has_liked)
            postid = params["like"]
        elsif params["dislike"] != nil
            has_liked = -1
            db.execute("INSERT INTO likesdislikes(UploadId, UserId, type) VALUES(?, ?, ?)", params["dislike"], session['userId'], has_liked)
            postid = params["dislike"]
        else
            redirect('/failed')
        end
    end

end

#validering
def updatepro(params, session)
    db = connect()
    if params["profilechange"] != nil
        if db.execute("SELECT Username FROM users WHERE Username = ?", params["username"]).first
            redirect('/failedregister')
        else
            hashed_pass = BCrypt::Password.create(params["new_pass"])
            db.execute("UPDATE users SET Username = ?, Password = ? WHERE Id = ?", params["new_name"], hashed_pass, session['userId'])
        end
    end
end

#validering
def del_post(params)
    db = connect() 
    db.execute("DELETE FROM bloggposts WHERE PostId = ?", params["delete"])
    db.execute("DELETE FROM likesdislikes WHERE UploadId = ?", params["delete"])
end
