FROM biocontainers/biocontainers:v1.0.0_cv4

USER root

RUN apt-get update && \
apt-get install -y tmux \
squashfs-tools \
build-essential \
libtool \
autotools-dev \
automake \
autoconf \
htop zsh git-core ruby-full

RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh

ADD .tmux.conf /home/biodocker/
ADD .condarc /home/biodocker/


ADD https://github.com/singularityware/singularity/releases/download/2.4.6/singularity-2.4.6.tar.gz ./
RUN tar xvzf singularity-2.4.6.tar.gz \
&& cd singularity-2.4.6 \
&& ./configure \
&& make \
&& make install

RUN useradd -m -s /bin/bash evansj \
	&& echo 'evansj ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN echo 'biodocker ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN mkdir -p /home/biodocker/.linuxbrew/  
RUN git clone https://github.com/Linuxbrew/brew && mv brew /home/biodocker/.linuxbrew/Homebrew
RUN cd /home/biodocker/.linuxbrew \
	&& mkdir -p bin etc include lib opt sbin share var/homebrew/linked Cellar \
	&& ln -s ../Homebrew/bin/brew /home/biodocker/.linuxbrew/bin/ \
	&& chown -R biodocker: /home/biodocker/.linuxbrew \
	&& cd /home/biodocker/.linuxbrew/Homebrew \
	&& git remote set-url origin https://github.com/Linuxbrew/brew

USER biodocker
WORKDIR /home/biodocker
ENV PATH=/home/biodocker/.linuxbrew/bin:/home/biodocker/.linuxbrew/sbin:$PATH \
	SHELL=/bin/zsh \
	USER=biodocker

# Install portable-ruby and tap homebrew/core.
RUN HOMEBREW_NO_ANALYTICS=1 HOMEBREW_NO_AUTO_UPDATE=1 brew tap homebrew/core \
	&& rm -rf ~/.cache

#USER biodocker
#RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"

CMD zsh
RUN brew install fzf
#RUN $(brew --prefix)/opt/fzf/install
# spacemacs
