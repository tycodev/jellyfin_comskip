FROM ghcr.io/jellyfin/jellyfin:10.11.7@sha256:2b93aa3830dcd0aab7185c635e20edef1f8dc5d2e999768baf1724e88c078004 AS build

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

FROM ghcr.io/jellyfin/jellyfin:10.11.7@sha256:2b93aa3830dcd0aab7185c635e20edef1f8dc5d2e999768baf1724e88c078004 AS final
ENV PATH="/usr/lib/jellyfin-ffmpeg/:$PATH"
RUN apt update && apt install -y \
    libswscale-dev \
    libargtable2-dev \
    libavformat-dev \
    libsdl1.2-dev
COPY --from=build /usr/local/bin/comskip /usr/local/bin/comskip
RUN mkdir /comskip
COPY comskip.ini /comskip
COPY comskip.sh /comskip