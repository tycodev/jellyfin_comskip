FROM ghcr.io/jellyfin/jellyfin:10.10.7@sha256:e4d1dc5374344446a3a78e43dd211247f22afba84ea2e5a13cbe1a94e1ff2141

RUN apt update && apt -y upgrade && apt install -y comskip unzip && mkdir comskip

COPY comskip.ini /comskip
COPY comskip.sh /comskip
