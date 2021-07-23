FROM golang:1.13.15
RUN pt-get clean && apt-get update && \ 
apt-get install -y git build-essential make
