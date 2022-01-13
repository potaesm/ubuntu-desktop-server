FROM ubuntu:20.04

ARG PORT=8084

ENV DEBIAN_FRONTEND noninteractive
ENV USER root
ENV VNC_PASSWORD Ftvgbhryn@

# App utils
RUN apt-get update && \
    apt-get install -y apt-utils 2>&1 | grep -v "debconf: delaying package configuration, since apt-utils is not installed"

# Base Ubuntu Desktop with VNC server
RUN apt-get update && \
    apt-get install -y --no-install-recommends ubuntu-desktop \
    build-essential \
    software-properties-common \
    locales \
    x11-utils \
    tightvncserver \
    novnc \
    websockify

# Gnome
RUN apt-get update && \
    apt-get install -y --no-install-recommends gnome-panel \
    gnome-settings-daemon \
    metacity \
    nautilus

# Basic Tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends psmisc \
    unzip \
    bzip2 \
    wget \
    curl \
    openssh-client \
    nano \
    vim \
    git \
    gnupg2 \
    net-tools

# Vim and Terminal GUI
RUN apt-get update && \
    apt-get install -y --no-install-recommends vim-gtk3 \
    tilda

# Set Locale and Timezone
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    dpkg-reconfigure -f noninteractive locales

# Set Timezone
RUN rm /etc/localtime && \
    echo "Asia/Bangkok" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

RUN apt-get update

# Thai fonts
RUN apt-get install -y --no-install-recommends xfonts-thai

# AbiWord
RUN apt-get install -y --no-install-recommends abiword

# Firefox
RUN apt-get install -y --no-install-recommends firefox=75.0+build3-0ubuntu1 && \
    apt-mark hold firefox

# Pinta
RUN apt-get install -y --no-install-recommends pinta

# Geany
RUN apt-get install -y --no-install-recommends geany

# Okular
RUN apt-get install -y --no-install-recommends okular

# gThumb
RUN apt-get install -y --no-install-recommends gthumb

# Gnumeric
RUN apt-get install -y --no-install-recommends gnumeric

# Dillo
RUN apt-get install -y --no-install-recommends dillo

# Pdfshuffler
RUN apt-get install -y --no-install-recommends pdfshuffler

# Midori
RUN apt-get install -y --no-install-recommends libc6 \
    libcairo2 \
    libgcr-base-3-1 \
    libgcr-ui-3-1 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
    libpeas-1.0-0 \
    libsoup2.4-1 \
    libsqlite3-0 \
    libwebkit2gtk-4.0-37
RUN wget http://archive.ubuntu.com/ubuntu/pool/universe/m/midori/midori_7.0-2.1_amd64.deb && \
    dpkg -i midori_7.0-2.1_amd64.deb || true && \
    rm -rf midori_7.0-2.1_amd64.deb

# Flareget
RUN wget https://dl.flareget.com/downloads/files/flareget/debs/amd64/flareget_5.0-1_amd64.deb && \
    dpkg -i flareget_5.0-1_amd64.deb || true && \
    rm -rf flareget_5.0-1_amd64.deb

# NodeJS
RUN apt-get install -y --no-install-recommends npm && \
    npm install n -g && \
    n lts

# Ngrok
RUN wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip && \
    unzip ngrok-stable-linux-amd64.zip && \
    mv ./ngrok /usr/bin/ngrok && \
    rm -rf ngrok-stable-linux-amd64.zip

# Clean up
RUN apt-get clean -y && \
    echo "nameserver 8.8.8.8" > /etc/resolv.conf && \
    rm -rf /var/lib/apt/lists/*

# Create necessary directory
RUN chmod 777 /home
RUN mkdir /root/.Xauthority && chmod 777 /root/.Xauthority
# For ubuntu:20.04
RUN chmod 777 /root/.config
# For ubuntu:18.04
# RUN mkdir /root/.config && chmod 777 /root/.config
RUN mkdir /root/Desktop && chmod 777 /root/Desktop
RUN mkdir -p /usr/share/gnome-panel/applets && chmod 777 /usr/share/gnome-panel/applets

# Setup VNC
RUN mkdir /root/.vnc
ADD xstartup /root/.vnc/xstartup
RUN echo $VNC_PASSWORD | vncpasswd -f > /root/.vnc/passwd
RUN chmod 600 /root/.vnc/passwd
RUN cp -R /usr/share/novnc/vnc.html /usr/share/novnc/index.html

RUN apt-get update

# Turn off swap
RUN swapoff -a

# NoVNC
# RUN openssl req -x509 -nodes -newkey rsa:2048 -keyout ~/novnc.pem -out ~/novnc.pem -days 3650 -subj "/C=US/ST=NY/L=NY/O=NY/OU=NY/CN=NY emailAddress=email@example.com"
CMD while true; do echo $VNC_PASSWORD | /usr/bin/vncserver :1 -geometry 1300x600 -depth 16 && websockify -D --web=/usr/share/novnc/ ${PORT} localhost:5901 && tail -f /root/.vnc/*:1.log; done
EXPOSE ${PORT}

# VNC
# CMD /usr/bin/vncserver :1 -geometry 1280x800 -depth 24 && tail -f /root/.vnc/*:1.log
# EXPOSE 5901
