# This Dockerfile is based off of orchardos, but stops the potion_proxy service
# so we can run it as the entry point instead, so Docker has something to "be"

FROM 947357864285.dkr.ecr.us-east-1.amazonaws.com/orchard/orchardos-amd64:latest

COPY potion-proxy-amd64-20180311.tar.gz .
RUN mkdir potion-proxy
RUN mv potion-proxy-amd64-20180311.tar.gz potion-proxy/
WORKDIR /potion-proxy
RUN tar zxvf potion-proxy-amd64-20180311.tar.gz
WORKDIR /
RUN rm -fr /opt/potion-proxy
RUN mv potion-proxy /opt/potion-proxy

RUN . /etc/profile && env-update
#RUN /etc/init.d/potion-proxy stop

# ENTRYPOINT ["/opt/potion-proxy/bin/potion_proxy"]
# CMD ["console"]
CMD ["/bin/bash"]
