FROM alpine:3.3
MAINTAINER Eric Rauer

RUN apk add --no-cache git curl bash g++ make expat-dev openssl-dev \
                       zlib-dev ncurses-dev bzip2-dev gdbm-dev \
                       sqlite-dev libffi-dev readline-dev linux-headers paxmark \
                       perl

ENV ASDF_DIR /usr/local/asdf



RUN /bin/bash -c 'git clone https://github.com/asdf-vm/asdf.git $ASDF_DIR  --branch v0.2.1'

#Set up elixir
ENV ELIXIR_VERSION 1.3.4
RUN /bin/bash -c '. $ASDF_DIR/asdf.sh \
    && asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git \
    && asdf install elixir $ELIXIR_VERSION && \
    asdf global elixir $ELIXIR_VERSION'

#Set up python
ENV PYTHON_VERSION 3.6.0
RUN /bin/bash -c '. $ASDF_DIR/asdf.sh \
    && asdf plugin-add python https://github.com/tuvistavie/asdf-python.git \
    && asdf install python $PYTHON_VERSION && \
    asdf global python $PYTHON_VERSION'


#Set up erlang
ENV ERLANG_VERSION 18.3
RUN /bin/bash -c '. $ASDF_DIR/asdf.sh \
    && asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git \
    && asdf install erlang $ERLANG_VERSION && \
    asdf global erlang $ERLANG_VERSION'


#Set Working Directory
WORKDIR /usr/src/app/

RUN  /bin/bash -c  "git clone https://github.com/eclipse/paho.mqtt.testing.git integration"
