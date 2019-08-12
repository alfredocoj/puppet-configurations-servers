# vim:set ft=dockerfile:
FROM postgres:9.6

RUN apt update && apt install -y wget