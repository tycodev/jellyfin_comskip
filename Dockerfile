FROM ghcr.io/jellyfin/jellyfin:10.11.1@sha256:66f8c685241cb6d1611ddf90c593d47f18fb851d07d696b821280497f6f2b5b7

# RUN apt update && apt -y upgrade && apt install -y comskip unzip && mkdir comskip

# COPY comskip.ini /comskip
# COPY comskip.sh /comskip
