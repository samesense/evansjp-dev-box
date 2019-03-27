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

ADD https://github.com/singularityware/singularity/releases/download/2.4.6/singularity-2.4.6.tar.gz ./
RUN tar xvzf singularity-2.4.6.tar.gz \
&& cd singularity-2.4.6 \
&& ./configure \
&& make \
&& make install

USER biocontainer
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"

CMD zsh
