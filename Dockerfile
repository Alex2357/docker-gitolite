# Gitolite server
#
# Example:
# 	Build:
#		 docker build -t gitolite .
#
# 	Run:
#    docker run -d --name gitolite -p 22022:22 -v /docker/volumes/gitoliterepositories:/home/git/repositories -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)"  gitolite

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

# no git setup here. to make ssh key working I did setup in start.sh



# prevent the perl warning
RUN sed  -i 's/AcceptEnv/# \0/' /etc/ssh/sshd_config

# fix fatal: protocol error: bad line length character: Welc
RUN sed -i 's/session\s\+required\s\+pam_loginuid.so/# \0/' /etc/pam.d/sshd

RUN mkdir /var/run/sshd

ADD start.sh /start.sh
RUN chmod a+x /start.sh

EXPOSE 22
CMD ["/start.sh"]
