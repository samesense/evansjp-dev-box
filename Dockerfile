FROM biocontainers/biocontainers:v1.0.0_cv4

RUN apt-get update \
&& apt-get install -y tmux

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
