FROM resin/raspberrypi3-python:3.6.0-20170308

ENV INITSYSTEM on

RUN apt-get update && apt-get install -y \
		dbus \
		dnsmasq \
		hostapd \
		rfkill \
	&& rm -rf /var/lib/apt/lists/*

COPY hostapd.conf /etc/hostapd/hostapd.conf
COPY dnsmasq.conf /etc/dnsmasq.conf
COPY interfaces /etc/network/interfaces
COPY start.sh ./start.sh

CMD ["bash", "start.sh"]
