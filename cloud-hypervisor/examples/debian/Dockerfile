FROM debian:11

RUN set -e \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		curl \
		iproute2 \
		procps \
		systemd-sysv \
		busybox \
		lsb-release \
	&& ln -s /bin/busybox /bin/cttyhack

RUN rm -f    /sbin/init
ADD init     /sbin/init
RUN chmod +x /sbin/init
