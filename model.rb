require 'slim'
require 'sqlite3'
require 'sinatra'
require 'bcrypt'
require 'byebug'
require 'securerandom'
require 'fileutils'

# Function opening up the database for use in other functions
#
# @return [Database] Database  
def connect()
    db = SQLite3::Database.new("db/users.db")
    db.results_as_hash = true
    return db
end

# Collects all the posts values including the likes and images attached to them and attempts to upload
#
# @param [Hash] params form data
# @option params [Integer] like Id of the liked post
# @option params [Integer] dislike Id of the disliked post
#
# @return [Array]
#   * :PostId [Integer] The ID of the post
#   * :header [String] the title of the post
#   * :post [String] The content of the post   
#   * :UserId [Integer] The ID of the user
#   * :score [Integer] Summarized dislikes and likes on the posts
#   * :Images [Blob] Images published to the website
# @return [nil] if not found
def bloggposts(params)
    db = connect()
    likes = db.execute("SELECT SUM(type) AS score FROM likesdislikes WHERE UploadId = ?", params["like"])
    dislikes = db.execute("SELECT SUM(type) AS score FROM likesdislikes WHERE UploadId = ?", params["dislike"])
    if likes.first["score"] == nil || dislikes.first["score"] == nil
        posts = db.execute("SELECT * FROM bloggposts ORDER BY TIMESTAMP DESC LIMIT 20")
    elsif likes.first["score"] != nil
        posts = db.execute("SELECT Header, Post, PostId, bloggposts.UserId, Images, SUM(likesdislikes.type) AS score FROM bloggposts INNER JOIN likesdislikes ON likesdislikes.UploadId = bloggposts.PostId  WHERE likesdislikes.UploadId = ? ORDER BY TIMESTAMP DESC LIMIT 20", params["like"])
    else
        posts = db.execute("SELECT Header, Post, PostId, bloggposts.UserId, Images, SUM(likesdislikes.type) AS score FROM bloggposts INNER JOIN likesdislikes ON likesdislikes.UploadId = bloggposts.PostId  WHERE likesdislikes.UploadId = ? ORDER BY TIMESTAMP DESC LIMIT 20", params["dislike"])
    end
    return posts
end

# Attempts login and creates a new session
#
# @param [Hash] params form data
# @option params [String] username The username
# @option params [String] password The password
# 
# @return [Hash]
#   * :error [Boolean] whether an error occurred
#   * :message [String] the error message
#   * :id [Integer] the users ID
#   * :password [String] the users password
def login(params)
    db = connect()
    result = db.execute("SELECT Id, Password FROM users WHERE Username = ?", params["username"])
    result = result.first
    if result == nil
        return {
            error: true,
            message: "Wrong password or username"
        }
    end
    hashed_pass = BCrypt::Password.new(result["Password"])
    
    if hashed_pass == params["password"] && params["password"].length > 0 && params["password"].length < 21 && params["username"].length < 21 && params["username"].length > 0
        session[:username] = params["username"]
        session[:userId] = result["Id"]
        return {
            error: false
        }
    else
        return {
            error: true,
            message: "Wrong password or username"
        }
    end
    return result
end

# Attempts to create an account
#
# @param [Hash] params form data
# @option params [String] username The username
# @option params [String] password The password
#
# @return [Hash] 
#   * :error [Boolean] whether an error occurred
#   * :message [String] the error message
def register(params)
    db = connect()
    hashed_pass = BCrypt::Password.create(params["password"])
    if db.execute("SELECT Username FROM users WHERE Username = ?", params["username"]).first || params["username"].length < 1 || params["password"].length < 1 || params["username"].length > 20 || params["password"].length > 20 || params["username"].length < 1 || params["username"].length > 20
        return {
            error: true,
            message: "That username is already in use or you're username or password was  more than 20 characters long. Or you had 0 characters"
        }
    else
        db.execute("INSERT INTO users(Username, Password) VALUES(?, ?)", params["username"], hashed_pass)
        return {
            error: false
        }
    end
end

# Attempts to insert new post into the database
#
# @param [Hash] params form data
# @param [Integer] userId ID of the user
# @option params [Button] publish The button that publishes
# @option params [String] header The header of the post
# @option params [String] post The content of the post
# @option params [Hash] file The picture being uploaded
#
# @return [Hash]
#   * :error [Boolean] whether an error has occurred
#   * :message [String] the error message
def post(params, userId)
    db = connect()
    if params["publish"] != nil
        if params["header"].length == 0 || params["post"].length == 0 || params["header"].length > 30 || params["post"].length > 200
            return {
                error: true,
                message: "Something went wrong while uploading, perhaps you had a tad too big of a post ya weezle. Or it was just empty."
            }
        end 

    end
    img = params["file"]
    byebug
    format = img["filename"].split(".")
    if img != nil
        new_name = SecureRandom.uuid + "." + format[-1].to_s
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

# Attempts to like or dislike a post and checks if current user already has liked said post. Stripping her of the feature to like or dislike again
#
# @param [Hash] params form data
# @param [Integer] userId ID of the current user
# @option params [Integer] like ID of the liked post
# @option params [Integer] dislike ID of the disliked post
# 
# @return [Hash] 
#   * :error [Boolean] whether an error occurred
#   * :message [String] the error message
def likes_dislikes(params, userId)
    db = connect()  

    liked_posts = db.execute("SELECT UploadId FROM likesdislikes WHERE UserId = ?", session['userId'])
    
    liked = false
    liked_posts.each do |post|
        if post["UploadId"] == params["like"].to_i || post["UploadId"] == params["dislike"].to_i
            liked = true
            return {
                error: false
            }
            break
        elsif post["UploadId"] == nil
            return {
                error: true,
                message: "Something went wrong liking that post, try again"
            }
        end
    end


    if liked == false
        if params["like"] != nil
            has_liked = 1
            db.execute("INSERT INTO likesdislikes(UploadId, UserId, type) VALUES(?, ?, ?)", params["like"], session['userId'], has_liked)
            postid = params["like"]
            return {
                error: false
            }
        elsif params["dislike"] != nil
            has_liked = -1
            db.execute("INSERT INTO likesdislikes(UploadId, UserId, type) VALUES(?, ?, ?)", params["dislike"], session['userId'], has_liked)
            postid = params["dislike"]
            return {
                error: false
            }
        else
            return {
                error: true,
                message: "Something went wrong liking that post, please try again"
            }
        end
    end

end

# Counts the likes on every post
#
# @return [Hash]
#   * :likes [Integer] likes on post
def count_likes()
    db = connect()
    votes = db.execute("SELECT * FROM likesdislikes ORDER BY UploadId")
    
    id = votes[0][1]
    likes = {votes[0][1]=>0}
    votes.each do |vote|
        if id != vote[1]
            id = vote[1]
            likes[vote[1]] = 0
        end
        likes[vote[1]] += vote[2].to_i
    end
    
    return likes
end

# Attempts to update current user's credentials (username and password) 
#
# @param [Hash] params form data
# @param [Integer] userId ID of current user
# @option params [String] new_name New username
# @option params [String] new_pass New password
#
# @return [Hash]
#   * :error [Boolean] whether an error occurred
#   * :message [String] the error message
def updatepro(params, userId)
    db = connect()
    if params["profilechange"] != nil && params["new_name"].length < 21 && params["new_pass"].length < 21 && params["new_name"].length > 0 && params["new_pass"].length > 0
        user = db.execute("SELECT Username FROM users WHERE Username = ?", params["new_name"])
        if user.length > 0
            return {
                error: true, 
                message: "That username is already in use"
            }
        else
            hashed_pass = BCrypt::Password.create(params["new_pass"])
            db.execute("UPDATE users SET Username = ?, Password = ? WHERE Id = ?", params["new_name"], hashed_pass, session['userId'])
            return {
                error: false
            }
        end
    else
        return {
            error: true,
            message: "Either too many characters or you had 0 characters"
        }
    end
end

# Deletes a post which the logged in user has created
#
# @param [Hash] params form data
# @param [Integer] userId ID of the current user
# @option params [Button] delete Button that deletes the post
#
# @return [Hash]
#   * :error [Boolean] whether an error occurred
#   * :message [String] the error message
def del_post(params, userId)
    db = connect() 
    if session['userId'] == nil
        return {
            error: true,
            message: "Something went wrong trying to delete the post"
        }
    end

    userId = db.execute("SELECT UserId FROM bloggposts WHERE UserId = ?", session['userId'])
    if userId.first[0] == session['userId']
        db.execute("DELETE FROM bloggposts WHERE PostId = ?", params["delete"])
        db.execute("DELETE FROM likesdislikes WHERE UploadId = ?", params["delete"])
        return {
            error: false
        }
    else
        return {
            error: true,
            message: "Something went wrong trying to delete that post"
        }
    end
end
