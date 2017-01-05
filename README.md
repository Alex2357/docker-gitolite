#Gitolite on docker

## New gitolite installation
Use `docker run` directly. Example:

        $ docker run -d -p 2222:22 --name gitolite -e SSH_KEY="$(cat  ~/.ssh/id_rsa.pub)"  -v /docker/volumes/gitoliterepositories:/home/git/repositories  alex23/gitolite

where /docker/volumes/gitoliterepositories is a folder for all gitolite repositories. 


## Existing gitolite installation

When that line `su git -c "/home/git/bin/gitolite setup -pk /home/git/admin.pub"` is executed(see `start.sh`), gitolite configures machine and creates new gitolite-admin.git repository.
If repository was in place, then it just performs new commit with the default content. It drops all users' SSH keys from keydir directory. It also puts just 2
repositories(gitolite-admin.git & testing.git) into conf/gitolite.conf. 

In most cases there's no need to drop everything(users' SSH keys and repository details) from gitolite-admin.git. For that there's a workaraound to keep everything, by providing
additional argument `KEEP_USERSKEYS_AND_REPOSITORIES`. BEWARE admin.pub will be replaced anyway if it is different, just in case if it is required to replace by the new one.

1. Make sure that you have the latest backup of the gitolite repositories.

2. Make sure that all repositories are copied from your backup to your `/docker/volumes/gitoliterepositories` folder.

3. Run any of those. Most likely you need 2nd option

```
$ docker run -d -p 2222:22 --name gitolite -e SSH_KEY="$(cat  ~/.ssh/id_rsa.pub)"  -v /docker/volumes/gitoliterepositories:/home/git/repositories  alex23/gitolite
```

```
$ docker run -d -p 2222:22 --name gitolite -e SSH_KEY="$(cat  ~/.ssh/id_rsa.pub)" -e KEEP_USERSKEYS_AND_REPOSITORIES=dummytextvalue -v /docker/volumes/gitoliterepositories:/home/git/repositories  alex23/gitolite
```


## .rc file
You can customize the gitolite `.rc` file by modify the `/path/to/git/data/gitolite.rc`. This file will sync to `~/.gitolite.rc`  when restart the container. So after change it you must run command like this:

       $ ./gitolite stop && ./gitolite start

## Build your own image
Clone the source code and run:

       $ docker build -t gitolite .
