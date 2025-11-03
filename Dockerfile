FROM ghcr.io/jellyfin/jellyfin:10.11.2@sha256:749972be6e7d440a47531ee36c9e38ea7a6271c875f42e8a52851c39862b0773

# RUN apt update && apt -y upgrade && apt install -y comskip unzip && mkdir comskip

# COPY comskip.ini /comskip
# COPY comskip.sh /comskip
