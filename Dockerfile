FROM ghcr.io/jellyfin/jellyfin:10.11.6@sha256:25db4eb10143c1c12adb79ed978e31d94fc98dc499fbae2d38b2c935089ced3e

# RUN apt update && apt -y upgrade && apt install -y comskip unzip && mkdir comskip

# COPY comskip.ini /comskip
# COPY comskip.sh /comskip
