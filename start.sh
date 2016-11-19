#! /bin/sh -




# handle the gitolite.rc
if [  -f "/home/git/repositories/gitolite.rc" ]; then
  echo 'import rc file'
  su git -c "cp /home/git/repositories/gitolite.rc /home/git/.gitolite.rc"
else
  echo 'export rc file'
  su git -c "cp /home/git/.gitolite.rc /home/git/repositories/gitolite.rc"
fi

if [ -f /home/git/repositories/gitolite-configured ]; then
  echo "gitolite already configured. performing setup" >>/home/git/gitolog.txt
  su git -c "/home/git/bin/gitolite setup>>/home/git/gitolog.txt"
else
  # handle the ssh key
  if [ -n "$SSH_KEY" ]; then
    echo "Replace the admin ssh key.\n">>/home/git/gitolog.txt
    echo $SSH_KEY > /home/git/admin.pub
    chown git:git /home/git/admin.pub
    chown -R git:git /home/git/repositories

    su git -c "/home/git/bin/gitolite setup -pk /home/git/admin.pub > /home/git/gitolog2.txt 2>/home/git/gitolog2.txt"
  else
    su git -c "/home/git/bin/gitolite setup"
    echo "The built-in private key for admin:\n"
    cat /admin
  fi

  su git -c "touch /home/git/repositories/gitolite-configured"
fi

/usr/sbin/sshd -D
