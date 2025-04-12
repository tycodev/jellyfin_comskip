FROM linuxserver/jellyfin:10.10.7@sha256:fcb2581301682bb25eb3a5c560718df90445640dd2584541b9fdefad717b4630

RUN apt update && apt -y upgrade && apt install -y comskip unzip && mkdir comskip

COPY comskip.ini /comskip
COPY comskip.sh /comskip
