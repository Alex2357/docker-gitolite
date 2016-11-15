# Gitolite server
#
# Example:
# 	Build:
#		 docker build -t gitolite .
#
# 	Run:
#    docker run -d --name gitolite -p 22022:22 -v /var/data/git:/home/git/repositories -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)"  gitolite

FROM ubuntu
MAINTAINER Alex K <akubenko@gmail.com>

# install requirements
RUN apt-get update
RUN apt-get install -y git perl openssh-server

# create 'git' user
RUN useradd git -m

# install gitolite
RUN su - git -c 'git clone git://github.com/sitaramc/gitolite'
RUN su - git -c 'mkdir -p $HOME/bin \
	&& gitolite/install -to $HOME/bin'

# setup with built-in ssh key
RUN echo about to output key
#RUN su - git -c 'echo "$SSH_KEY" > /tmp/admin.pub'
cmd echo "bla-bla" > $HOME/test.txt
CMD echo "$SSH_KEY" > "$HOME/admin.pub"
RUN su - git -c 'chmod 777 $HOME/admin.pub'
# It fails COPY ~/.ssh/id_rsa.pub /tmp/admin.pub
#ADD /home/john/.ssh/id_rsa.pub /tmp/admin.pub

RUN echo admin.pub done!!!

# http://stackoverflow.com/questions/12414555/error-setting-up-gitolite-doesnt-accept-ssh-key
CMD $GITOLITE_HTTP_HOME=''
RUN su - git -c '$HOME/bin/gitolite setup -pk "$HOME/admin.pub"'

# prevent the perl warning
RUN sed  -i 's/AcceptEnv/# \0/' /etc/ssh/sshd_config

# fix fatal: protocol error: bad line length character: Welc
RUN sed -i 's/session\s\+required\s\+pam_loginuid.so/# \0/' /etc/pam.d/sshd

RUN mkdir /var/run/sshd

ADD start.sh /start.sh
RUN chmod a+x /start.sh

EXPOSE 22
CMD ["/start.sh"]
