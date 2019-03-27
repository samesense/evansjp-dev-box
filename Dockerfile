# Base image
FROM ubuntu:16.04

################## METADATA ######################

LABEL base_image="ubuntu:16.04"
LABEL version="4"
LABEL software="biocontainers"
LABEL software.version="1.0.0"
LABEL about.summary="Base image for BioDocker"
LABEL about.home="http://biocontainers.pro"
LABEL about.documentation="https://github.com/BioContainers/specs/wiki"
LABEL about.license_file="https://github.com/BioContainers/containers/blob/master/LICENSE"
LABEL about.license="SPDX:Apache-2.0"
LABEL about.tags="Genomics,Proteomics,Transcriptomics,General,Metabolomics"

################## MAINTAINER ######################
MAINTAINER Felipe da Veiga Leprevost <felipe@leprevost.com.br>

ENV DEBIAN_FRONTEND noninteractive

RUN mv /etc/apt/sources.list /etc/apt/sources.list.bkp && \
    bash -c 'echo -e "deb mirror://mirrors.ubuntu.com/mirrors.txt xenial main restricted universe multiverse\n\
deb mirror://mirrors.ubuntu.com/mirrors.txt xenial-updates main restricted universe multiverse\n\
deb mirror://mirrors.ubuntu.com/mirrors.txt xenial-backports main restricted universe multiverse\n\
deb mirror://mirrors.ubuntu.com/mirrors.txt xenial-security main restricted universe multiverse\n\n" > /etc/apt/sources.list' && \
    cat /etc/apt/sources.list.bkp >> /etc/apt/sources.list && \
    cat /etc/apt/sources.list

RUN apt-get clean all && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y  \
        autotools-dev   \
        automake        \
        cmake           \
        curl            \
        grep            \
        sed             \
        dpkg            \
        fuse            \
        git             \
        wget            \
        zip             \
        openjdk-8-jre   \
        build-essential \
        pkg-config      \
        python          \
	python-dev      \
        python-pip      \
        bzip2           \
        ca-certificates \
        libglib2.0-0    \
        libxext6        \
        libsm6          \
        libxrender1     \
        mercurial       \
        subversion      \
        zlib1g-dev &&   \
        apt-get clean && \
        apt-get purge && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda2-4.0.5-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh

RUN TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

RUN mkdir /data /config

# Add user biodocker with password biodocker
RUN groupadd fuse && \
    useradd --create-home --shell /bin/bash --user-group --uid 958133 --groups sudo,fuse biodocker && \
    echo `echo "biodocker\nbiodocker\n" | passwd biodocker` && \
    chown biodocker:biodocker /data && \
    chown biodocker:biodocker /config

# give write permissions to conda folder
RUN chmod 777 -R /opt/conda/

# Change user
USER biodocker

ENV PATH=$PATH:/opt/conda/bin
ENV PATH=$PATH:/home/biodocker/bin
ENV HOME=/home/biodocker

RUN mkdir /home/biodocker/bin

RUN conda config --add channels r
RUN conda config --add channels bioconda

RUN conda upgrade conda

VOLUME ["/data", "/config"]



USER root

RUN apt-get update && \
apt-get install -y tmux \
software-properties-common \
squashfs-tools \
build-essential \
libtool \
silversearcher-ag \
autotools-dev \
automake \
autoconf \
htop zsh git-core ruby-full fontconfig && \
add-apt-repository ppa:kelleyk/emacs && \
apt-get update && \
apt install -y emacs26

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
USER root
ENV NNG_URL="https://github.com/google/fonts/raw/master/ofl/nanumgothic/NanumGothic-Regular.ttf" \
    SCP_URL="https://github.com/adobe-fonts/source-code-pro/archive/2.030R-ro/1.050R-it.tar.gz"
RUN mkdir -p /usr/local/share/fonts \
    && wget -qO- "${SCP_URL}" | tar xz -C /usr/local/share/fonts \
    && wget -q "${NNG_URL}" -P /usr/local/share/fonts \
    && fc-cache -fv \
    && rm -rf /tmp/* /var/lib/apt/lists/* /root/.cache/*

USER biodocker
ADD .spacemacs /home/biodocker/
ADD .emacs.d /home/biodocker/.emacs.d
RUN chown -R biodocker .emacs.d

#RUN git clone https://github.com/syl20bnr/spacemacs /home/biodocker/.emacs.d

ENV SINGULARITY_CACHEDIR /mnt/isilon/dbhi_bfx/perry/tmp/
ENV SINGULARITY_LOCALCACHEDIR /mnt/isilon/dbhi_bfx/perry/tmp
WORKDIR /home/biodocker/
