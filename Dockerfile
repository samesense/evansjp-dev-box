FROM biocontainers/biocontainers:v1.0.0_cv4

RUN apt-get update \
&& apt-get install -y tmux \
squashfs-tools \
build-essential \
libtool \
autotools-dev \
automake \
autoconf

ADD .tmux.conf .

ADD https://github.com/singularityware/singularity/releases/download/2.4.6/singularity-2.4.6.tar.gz ./
RUN tar xvzf singularity-2.4.6.tar.gz \
&& cd singularity-2.4.6 \
&& ./configure \
&& make \
&& make install

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
