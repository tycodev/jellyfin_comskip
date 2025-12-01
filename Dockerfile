FROM ghcr.io/jellyfin/jellyfin:10.11.4@sha256:37f2625f5d5d70c5b1ceb57f4d8f2a7ff666ea723fb96b468275bbafbde2c06c

# RUN apt update && apt -y upgrade && apt install -y comskip unzip && mkdir comskip

# COPY comskip.ini /comskip
# COPY comskip.sh /comskip
