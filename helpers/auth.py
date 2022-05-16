import bcrypt
import jwt
import os

#Generate salt and hashed paswword
def gen_hashed_password(password):
    """
    Generate salt and hashed password for a plain text password

    Parameters
    ----------
    password: string

    Returns
    -------
    tuple
    """

    salt = bcrypt.gensalt(rounds=16)
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return salt.decode('utf-8'), hashed.decode('utf-8')

#Check if password matches
def check_password(password, salt, hashed):
    """
    Hash plain text password using salt and compare with hashed password

    Parameters
    ----------
    password: string
    salt: string
    hashed: string

    Returns
    -------
    bool
    """

    #Hash plain text password with salt
    hashpw = bcrypt.hashpw(password.encode('utf-8'), salt.encode('utf-8'))

    #Compare with hashed password stored in the db
    return hashpw.decode('utf-8') == hashed


#Generate JWT token for the user
def generate_token(user_id):
    """
    Generate a JWT token using secret stored in environment variable

    Parameters
    ----------
    user_id: int

    Returns
    -------
    string
    """

    #Retrieve token secret from environment
    secret = os.environ.get("JWT_SECRET")

    #Create JWT token
    token = jwt.encode({"user_id": user_id}, secret, algorithm="HS256")

    return token

#Validate and decode the access token
def decode_token(token):
    """
    Decode and validate a JWT token

    Parameters
    ----------
    toke: string

    Returns
    -------
    int
    """

    #Retrieve token secret from environment
    secret = os.environ.get("JWT_SECRET")
    
    #Validate and decode access token
    decoded = jwt.decode(token, secret, algorithms="HS256")

    #Return decoded user_id
    return decoded.get("user_id")

