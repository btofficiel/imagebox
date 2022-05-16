import sqlite3

#Path to sqlite db file
DATABASE = './config/imagebox.db'

#Check if user exists in the database
def check_user_exists(email):
    """
    Check if a user exists in the database or not

    This function takes email as input and runs a SQL query to see if a user with the email exists already or not.

    Parameters
    ----------
    email: string

    Returns
    -------
    tuple

    """
    #Creating a database connection
    con = sqlite3.connect(DATABASE)

    cur = con.cursor()

    #SQL Query
    query = "SELECT * FROM users WHERE email='{0}'".format(email)

    #Execute Query
    rows = cur.execute(query).fetchall()

    #Closing database connection
    con.close()

    #Return whether email found or not
    if len(rows) > 0:
        return rows[0][0], rows[0][2], rows[0][3]
    else:
        return None, None, None

#Create a new user in the database
def create_user(email, hashedpw, salt):
    """
    Create a new user in the database

    This function creates a new user in the databased based on the arguments supplied
    Parameters
    ----------
    email: string
    hashedpw: string
    salt: string

    Returns
    -------
    int
    """
    #Creating a database connection
    con = sqlite3.connect(DATABASE)
    cur = con.cursor()

    #SQL Query to be insert into users table
    query = "INSERT INTO users(email, password, salt) VALUES('{0}', '{1}', '{2}')".format(email, hashedpw, salt)

    #Execute SQL Query
    cur.execute(query)

    # Save (commit) the changes
    con.commit()
    #Closing database connection
    con.close()

    #Retrieve created user id
    user_id, hashedpw, salt = check_user_exists(email)

    return user_id

#Create a new post in the database
def create_post(user_id, caption, filename):
    """
    Creates a new post in the database

    This function creates a new post in the database based on arguments supplied

    Parameters
    ----------
    user_id: int
    caption: string
    filename: string
    """
    #Creating a database connection
    con = sqlite3.connect(DATABASE)
    cur = con.cursor()

    #SQL Query to be insert into posts table
    query = "INSERT INTO posts(user_id, caption, file) VALUES('{0}', '{1}', '{2}')".format(user_id, caption, filename)

    #Execute SQL Query
    cur.execute(query)

    # Save (commit) the changes
    con.commit()
    #Closing database connection
    con.close()

#Convert a tuple of query response into a dict
def dict_from_tuple(record):
    """
    Convert a tuple of user record into a dict

    Parameters
    ----------
    record: tuple

    Returns
    -------
    dict
    """
    return {
        "id": record[0],
        "caption": record[1],
        "image_url": record[2]
    }

#Retrieve a list of photos uploaded by the user
def fetch_photos(user_id):
    """
    Fetch a list of posts from a given user

    Parameters
    ----------
    user_id: int

    Returns
    -------
    list
    """
    #Creating a database connection
    con = sqlite3.connect(DATABASE)

    cur = con.cursor()

    #SQL Query
    query = "SELECT id, caption, file FROM posts WHERE user_id={0}".format(user_id)

    #Execute Query
    rows = cur.execute(query).fetchall()

    #Closing database connection
    con.close()


    #Convert records to dict from tuples
    posts = map(dict_from_tuple, rows)

    return list(posts)

