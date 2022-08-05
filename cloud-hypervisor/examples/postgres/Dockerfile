FROM postgres:14-alpine

RUN rm -f    /sbin/init
ADD init     /sbin/init
RUN chmod +x /sbin/init

ADD postgresql.conf /etc/postgresql/postgresql.conf
