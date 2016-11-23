#Gitolite on docker

## New gitolite installation
Use `docker run` directly. Example:

        $ docker run -d -p 2222:22 --name gitolite -e SSH_KEY="$(cat  ~/.ssh/id_rsa.pub)"  -v /docker/volumes/gitoliterepositories:/home/git/repositories  alex23/gitolite

where /docker/volumes/gitoliterepositories is a folder for all gitolite repositories. 

## Existing gitolite installation

1. Make sure that you have the latest backup of the gitolite repositories.

2. Run these 3 lines to create gitolite container

	sudo rm -rf /docker/volumes/gitoliterepositories
	sudo mkdir -p /docker/volumes/gitoliterepositories
	docker run -d -p 2222:22 --name gitolite -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" -v /docker/volumes/gitoliterepositories:/home/git/repositories alex2357/gitolite

     
    The user running the script must be a member of the group `docker`. Otherwise, you need to modify this script and prepend `sudo` to the appropriate command.

**Attention:**

 - Before running previous 3 lines make sure that you have a latest backup, as it deletes volume folder.

 - You should create a directory for persistent Git repositories. This directory must have read/write permissions for current user. 

 - The Git repositories directory you specify can also be a already exists gitolite repositories. 

3. Run that to stop gitolite, restore backup and start again
	docker stop gitolite
	sudo rm -rf /docker/volumes/gitoliterepositories
	sudo cp -a /docker/volumes/gitoliterepositories_2016_11_19/.  /docker/volumes/gitoliterepositories
	docker start gitolite


## .rc file
You can customize the gitolite `.rc` file by modify the `/path/to/git/data/gitolite.rc`. This file will sync to `~/.gitolite.rc`  when restart the container. So after change it you must run command like this:

       $ ./gitolite stop && ./gitolite start

## Container removed?
If the container accidentally removed by `docker rm` or `./gitolite remove` . You can start it with the command as same as before. But you must force push the `gitolite-admin` again. 

Example:

       $ GIT_DATA_PATH=/var/data/git ./gitolite start
       $ cd ~/gitolite-admin && git push -f

## Build your own image
Clone the source code and run:

       $ docker build -t gitolite .
