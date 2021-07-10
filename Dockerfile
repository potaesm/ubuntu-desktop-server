FROM ubuntu:18.04

ARG PORT

ENV DEBIAN_FRONTEND noninteractive
ENV USER root
ENV VNC_PASSWORD aabbccdd

# App utils
RUN apt-get update && \
    apt-get install -y apt-utils 2>&1 | grep -v "debconf: delaying package configuration, since apt-utils is not installed"

# Base Ubuntu Desktop with VNC server
RUN apt-get update && \
    apt-get install -y --no-install-recommends ubuntu-desktop \
    build-essential \
    software-properties-common \
    locales \
    novnc \
    websockify \
    tightvncserver

# Gnome
RUN apt-get update && \
    apt-get install -y --no-install-recommends gnome-session \
    gnome-applets \
    gnome-panel \
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
RUN apt-get install -y --no-install-recommends firefox

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
RUN mkdir /root/.config && chmod 777 /root/.config
RUN mkdir /root/Desktop && chmod 777 /root/Desktop
RUN mkdir -p /usr/share/gnome-panel/applets && chmod 777 /usr/share/gnome-panel/applets

# Setup VNC
RUN mkdir /root/.vnc
ADD xstartup /root/.vnc/xstartup
RUN echo $VNC_PASSWORD | vncpasswd -f > /root/.vnc/passwd
RUN chmod 600 /root/.vnc/passwd

RUN apt-get update

# NoVNC
RUN openssl req -x509 -nodes -newkey rsa:2048 -keyout ~/novnc.pem -out ~/novnc.pem -days 3650 -subj "/C=US/ST=NY/L=NY/O=NY/OU=NY/CN=NY emailAddress=email@example.com"
CMD /usr/bin/vncserver :1 -geometry 1366x768 -depth 24 && websockify -D --web=/usr/share/novnc/ --cert=~/novnc.pem 80 localhost:5901 && tail -f /root/.vnc/*:1.log
# EXPOSE 80
EXPOSE ${PORT}

# VNC
# CMD /usr/bin/vncserver :1 -geometry 1280x800 -depth 24 && tail -f /root/.vnc/*:1.log
# EXPOSE 5901