from flask import Flask, render_template, request
from flask_caching import Cache
import json
import bcrypt
import helpers
import jwt

config = {
    "DEBUG": True,     
    "CACHE_TYPE": "SimpleCache",
    "CACHE_DEFAULT_TIMEOUT": 300
}

app = Flask(__name__)

app.config.from_mapping(config)
cache = Cache(app)

@app.route("/app", defaults={'path': ''})
@app.route("/app/", defaults={'path': ''})
@app.route("/app/<path:path>")
@cache.cached(timeout=50)
def hello_world(path):
    return render_template('index.html')


@app.route("/api/login", methods=["POST"])
def login():
    email = request.json.get('email')
    password = request.json.get('password')

    #Validating email 
    if not helpers.is_valid_email(email):
        return helpers.request_failed(400, "Please enter a valid email"), 400
    
    #Validating password
    if not helpers.is_valid_password(password):
        return helpers.request_failed(400, "Please enter a valid password (minimum 6 characters)"), 400

    #Checking if any user exists with the given email
    user_id, hashed, salt = helpers.check_user_exists(email)

    if not user_id:
        return helpers.request_failed(409, "No user found with such email. Please check again"), 409

    if not helpers.check_password(password, salt, hashed):
        return helpers.request_failed(403, "Please enter the correct password"), 403


    #Create access token
    token = helpers.generate_token(user_id)

    return helpers.request_succeeded({ "token": token}), 200


@app.route("/api/signup", methods=["POST"])
def signup():
    #Extracting payload from request
    email = request.json.get('email')
    password = request.json.get('password')

    #Validating email 
    if not helpers.is_valid_email(email):
        return helpers.request_failed(400, "Please enter a valid email"), 400
    
    #Validating password
    if not helpers.is_valid_password(password):
        return helpers.request_failed(400, "Please enter a valid password (minimum 6 characters)"), 400

    #Checking if any user exists with the given email
    user, hashed, salt = helpers.check_user_exists(email)

    if user:
        return helpers.request_failed(409, "A user already exists with the same email"), 409


    #Generate salt and hashed password
    salt, hashed = helpers.gen_hashed_password(password)

    #ID of the newly created user
    user_id = helpers.create_user(email, hashed, salt)

    #Create access token
    token = helpers.generate_token(user_id)

    return helpers.request_succeeded({ "token": token}), 200

@app.route("/api/upload", methods=["POST"])
def upload():
    try:
        token = request.headers.get("Authorization")
        caption = request.form.get("caption")

        #Decoded user_id
        user_id = helpers.decode_token(token)

        if not helpers.is_valid_caption(caption):
            return helpers.request_failed(400, "Caption cannot have more than 200 characters"), 400
        
        image = request.files.get("image")

        #Check if the image fits our file type restrictions
        if image.mimetype not in ["image/jpeg", "image/jpg", "image/png" ]:
            return helpers.request_failed(400, "Sorry! your image needs to be in JPG or PNG format"), 400


        #Saving the image and returning filename
        filename = helpers.save_file(image)
        
        #Creating a post
        helpers.create_post(user_id, caption, filename)

        return helpers.request_succeeded(), 200

    except (jwt.InvalidTokenError, jwt.DecodeError, jwt.InvalidSignatureError) as err:
        return helpers.request_failed(401), 401


@app.route("/api/profile", methods=["GET"])
def profile():
    try:
        token = request.headers.get("Authorization")
        caption = request.form.get("caption")

        #Decoded user_id
        user_id = helpers.decode_token(token)

        #Retrieve photos uploaded by the user
        posts = helpers.fetch_photos(user_id)

        return helpers.request_succeeded({"posts": posts}), 200

    except (jwt.InvalidTokenError, jwt.DecodeError, jwt.InvalidSignatureError) as err:
        return helpers.request_failed(401), 401

