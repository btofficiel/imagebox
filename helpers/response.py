#Function for returning response when api request is successful
def request_succeeded(data=None):
    """
    Return a dict which which will be sent as a response to a request

    Parameters
    ----------
    data: object

    Returns
    -------
    dict
    """

    return {
        "status": "success",
        "statusCode": 200,
        "data": data
    }

#Function for returning response when api request is unsuccessful
def request_failed(code=409,message=None):
    """
    Return a dict which which will be sent as a response to a request

    Parameters
    ----------
    code: int
    message: string

    Returns
    -------
    dict
    """

    return {
        "status": "success",
        "statusCode": code,
        "message": message
    }
