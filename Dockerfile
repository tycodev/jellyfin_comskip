FROM ghcr.io/jellyfin/jellyfin:12.3.20261023-013714@sha256:2038fe038ab3876a80f6e7b7e0aef6607b032c7dc0c9b3ad3296d0b2eba3bbb5 AS build

RUN apt update && apt -y upgrade && apt install -y \
    git \
    build-essential \
    pkg-config \
    autoconf \
    automake \
    libtool \
    libswscale-dev \
    libargtable2-dev \
    libavformat-dev \
    libsdl1.2-dev

RUN git clone https://github.com/erikkaashoek/Comskip.git \
    && cd Comskip \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install

FROM ghcr.io/jellyfin/jellyfin:12.3.20261023-013714@sha256:2038fe038ab3876a80f6e7b7e0aef6607b032c7dc0c9b3ad3296d0b2eba3bbb5 AS final
ENV PATH="/usr/lib/jellyfin-ffmpeg/:$PATH"
RUN apt update && apt install -y \
    libswscale-dev \
    libargtable2-dev \
    libavformat-dev \
    libsdl1.2-dev \
    vim \
    sqlite3

COPY --from=build /usr/local/bin/comskip /usr/local/bin/comskip
RUN mkdir /comskip
COPY comskip.ini /comskip
COPY comskip.sh /comskip