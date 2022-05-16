import uuid
import os

#Generate file extention
def gen_file_extention(mime):
    """
    Extract file extention from a given mimetype string

    This function splits a mimetype string to extract file extention

    Parameters
    ----------
    mime: string

    Returns
    -------
    string
    """

    split_string = mime.split("/")

    return split_string[1]

#Save file to disk
def save_file(file):
    """
    Compress and save file to the disk

    Parameters
    ----------
    file: file

    Returns
    -------
    string
    """
    #Extract extention of the file
    extention = gen_file_extention(file.mimetype)

    #Generate unique filename for the file
    filename = uuid.uuid1()

    #Filename along with file extention
    full_filename = "{0}.{1}".format(filename, extention)

    #Create a filepath
    filepath = "./static/media/{0}.{1}".format(filename, extention)

    file.save(filepath)

    #Compress images
    os.system("bash ./compress.sh")

    #Remove uncompressed image
    cmd = "rm -rf {0}".format(filepath)
    os.system(cmd)

    return full_filename
