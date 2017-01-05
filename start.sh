#! /bin/sh -


# handle the gitolite.rc
if [  -f "/home/git/repositories/gitolite.rc" ]; then
  echo 'import rc file'
  su git -c "cp /home/git/repositories/gitolite.rc /home/git/.gitolite.rc"
else
  echo 'export rc file'
  su git -c "cp /home/git/.gitolite.rc /home/git/repositories/gitolite.rc"
fi


chown -R git:git /home/git/repositories

#this directory required for gitolite logs
su git -c "mkdir -p ~/.gitolite/logs"

if [ -d /home/git/repositories/gitolite-admin.git ] && [ "$KEEP_USERSKEYS_AND_REPOSITORIES" ] ; then
  #to keep users keys we create a copy of gitolite-admin.git make additional commit with a new admin key(if the key is the same no commit is performed)
  #after gitolite perform host(container) setup we replace newly created gitolite-admin.git directory with our version.
  su git -c "mkdir ~/gitolite-copy; mv ~/repositories/gitolite-admin.git ~/gitolite-copy/"
  su git -c "git clone ~/gitolite-copy/gitolite-admin.git ~/gitolite-copy/gitolite-admin-temp"
  echo $SSH_KEY > /home/git/gitolite-copy/gitolite-admin-temp/keydir/admin.pub
  su git -c 'cd ~/gitolite-copy/gitolite-admin-temp; git config user.email "git@gitolite-docker.container"; git config user.name "git";'
  # if admin.pub key is exactly the same it won't commit and push anything
  su git -c 'cd ~/gitolite-copy/gitolite-admin-temp; git commit . -m "start.sh replaced admin.pub"'
  su git -c 'cd ~/gitolite-copy/gitolite-admin-temp; git push origin master'
fi

  # handle the ssh key
  echo "Replace the admin ssh key.\n">>/home/git/gitolog.txt
  echo $SSH_KEY > /home/git/admin.pub
  chown git:git /home/git/admin.pub
  chown git:git /home/git/gitolog.txt

  #For existing setup when we have gitolite-admin.git + our repos in /home/git/repositories
  #It must be run with -pk in a container as if you run that 
  #su git -c "/home/git/bin/gitolite setup" 
  #it won't work, because no required setup is performed(/home/git/.ssh/authorized_key + something else). 
  #If gitolite-admin.git exists it commits new admin key into keydir directory(if the same it leaves it) and drops
  # all users' keys from keydir directory and configures the machine to work with the specified admin ssh key.
  #IDEALLY I would like to leave all the keys, but admin key to be replaced. But seems no that option see help su git -c "/home/git/bin/gitolite setup -h"
  #I have decided to restore gitolite-admin.git from copy. 
  su git -c "/home/git/bin/gitolite setup -pk /home/git/admin.pub > /home/git/gitolog.txt 2>/home/git/gitolog.txt"

  if [ -d /home/git/gitolite-copy/gitolite-admin-temp ]; then
    #su git -c "mkdir -p ~/repositories/gitolite-admin.git"
    su git -c "rm -rf ~/repositories/gitolite-admin.git/*"
    su git -c "cp -r ~/gitolite-copy/gitolite-admin.git/* ~/repositories/gitolite-admin.git"
    su git -c "rm -rf ~/gitolite-copy"
  fi


/usr/sbin/sshd -D
