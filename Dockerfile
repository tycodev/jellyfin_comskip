FROM ghcr.io/jellyfin/jellyfin:12.4.20261026-211555@sha256:fea863d0cd9ec445985d9c75fc6ed64e38a1d2766cf0c250a33d553f4fc1b771 AS build

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

FROM ghcr.io/jellyfin/jellyfin:12.4.20261026-211555@sha256:fea863d0cd9ec445985d9c75fc6ed64e38a1d2766cf0c250a33d553f4fc1b771 AS final
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