import re

#Regex for matching email addresses
regex = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'

#Validator function for validating emails
def is_valid_email(email):
    """
    Use a RegEx to check whether an email is valid or not

    Parameters
    ----------
    email: string

    Returns
    -------
    bool
    """

    if re.fullmatch(regex, email):
        return True
    else:
        return False

#Validator function for validating password
def is_valid_password(password):
    """
    Check whether a password is minimum six characters

    Parameters
    ----------
    password: string

    Returns
    -------
    bool
    """

    return len(password) >= 6

#Validator function for validating caption
def is_valid_caption(caption):
    """
    Check whether a caption is maximum 200 characters

    Parameters
    ----------
    caption: string

    Returns
    -------
    bool
    """
    return len(caption) <= 200
