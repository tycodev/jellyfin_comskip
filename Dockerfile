FROM ghcr.io/jellyfin/jellyfin:12.1.20260915-010956@sha256:008ec8024bdaaa6f0a3f0de468e185633eeba9d67c56936e8dbf5ef6b8d6200f AS build

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

FROM ghcr.io/jellyfin/jellyfin:12.1.20260915-010956@sha256:008ec8024bdaaa6f0a3f0de468e185633eeba9d67c56936e8dbf5ef6b8d6200f AS final
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