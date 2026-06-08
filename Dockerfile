FROM ghcr.io/jellyfin/jellyfin:10.11.11@sha256:45f648c382a0c8b552582fcea40e95cb17c5d475473a891cba0eb7523fb92112 AS build

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

FROM ghcr.io/jellyfin/jellyfin:10.11.11@sha256:45f648c382a0c8b552582fcea40e95cb17c5d475473a891cba0eb7523fb92112 AS final
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