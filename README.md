# Installation Guide

## Setting up python

### Creating a virtual environment
Enter the following commands into the terminal to setup python virtual environment. Make sure you enter this in the project directory
<pre>
mkdir myproject
cd myproject
python3 -m venv venv
</pre>
### Installing Flask
<pre>
pip install flask
</pre>
### Installing dependencies
<pre>
pip install -r requirements.txt
</pre>

## Installing img4web.py compression library
We've already placed the img4web.py file in our project. Enter the following commands to install its system dependencies.
<pre>
sudo apt install pngcrush
sudo apt install libjpeg-progs
sudo apt install gifsicle
</pre>
## Building elm file
Our frontend is built in Elm and the bundle is already included in static/js folder. You can build the file yourself by doing the following.
### Installing Elm
<pre>
echo Installing Node 14...
curl -sL https://deb.nodesource.com/setup_14.x | bash -
apt-get install -y nodejs
npm install uglify-js -g
curl -L -o elm.gz https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz
gunzip elm.gz
chmod +x elm
</pre>
### Building our Elm bundle
<pre>
bash build_elm.sh
</pre>
## Installing SQLite3
SQLite3 could install by enterring the following commands.
<pre>
sudo apt update
sudo apt install sqlite3
sqlite3 --version
</pre>
## Running the program
<pre>
export JWT_SECRET=secret && flask run
</pre>
