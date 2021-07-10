FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive
ENV USER root
ENV VNC_PASSWORD=aabbccdd

# Base Ubuntu Desktop with VNC server
RUN apt-get update && \
    apt-get install -y --no-install-recommends ubuntu-desktop \
    novnc \
    websockify \
    tightvncserver

# Gnome
RUN apt-get update && \
    apt-get install -y --no-install-recommends gnome-panel \
    gnome-settings-daemon \
    gnome-session \
    metacity \
    nautilus

# Basic Tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential \
    software-properties-common \
    apt-utils \
    locales \
    unzip \
    bzip2 \
    wget \
    curl \
    sakura \
    openssh-client \
    nano \
    vim \
    vim-gtk3 \
    git \
    gnupg2 \
    net-tools

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

# Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
	apt-get install -y ./google-chrome-stable_current_amd64.deb

# Clean up
RUN apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /root/.vnc

# Create necessary directory
RUN mkdir /root/.config && chmod 777 /root/.config
RUN mkdir /root/Desktop && chmod 777 /root/Desktop

# Setup VNC
RUN mkdir /root/.vnc
ADD xstartup /root/.vnc/xstartup
RUN echo $VNC_PASSWORD | vncpasswd -f > /root/.vnc/passwd
RUN chmod 600 /root/.vnc/passwd

RUN apt-get update

# NoVNC
RUN openssl req -x509 -nodes -newkey rsa:2048 -keyout ~/novnc.pem -out ~/novnc.pem -days 3650 -subj "/C=US/ST=NY/L=NY/O=NY/OU=NY/CN=NY emailAddress=email@example.com"
CMD /usr/bin/vncserver :1 -geometry 1366x768 -depth 24 && websockify -D --web=/usr/share/novnc/ --cert=~/novnc.pem 80 localhost:5901 && tail -f /root/.vnc/*:1.log
EXPOSE 80

# VNC
# CMD /usr/bin/vncserver :1 -geometry 1280x800 -depth 24 && tail -f /root/.vnc/*:1.log
# EXPOSE 5901