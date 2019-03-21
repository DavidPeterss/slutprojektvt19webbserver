require 'slim'
require 'sqlite3'
require 'sinatra'
require 'bcrypt'
require 'byebug'

db = SQLite3::Database.new("db/users.db")

def login()
    db.results_as_hash = true
    result = db.execute("SELECT Id, Password FROM users WHERE Username = ?", params["username"])

end

def register()
    db.results_as_hash = true
    hashed_pass = BCrypt::Password.create(params["password"])
    db.execute("INSERT INTO users(Username, Password) VALUES(?, ?)"params["username"], hashed_pass)
end