FROM ghcr.io/jellyfin/jellyfin:10.11.3@sha256:fab30d85f4ec3e19556ca1d91b82b12329fc4a6d2a4b330673354af9218e1d28

# RUN apt update && apt -y upgrade && apt install -y comskip unzip && mkdir comskip

# COPY comskip.ini /comskip
# COPY comskip.sh /comskip
