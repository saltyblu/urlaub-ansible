FROM alpine:3.6 as pass

ADD https://git.zx2c4.com/password-store/snapshot/password-store-1.7.1.tar.xz /

RUN apk --no-cache add \
        make \
        wget \
        ca-certificates \
        openssl \
    && rm -rf /var/cache/apk \
    && tar xvf password-store-1.7.1.tar.xz \
    && cd password-store-1.7.1 \
    && make install

FROM alpine:3.6 as ansible

RUN apk --no-cache add \
        linux-headers \
        python \
        python-dev \
        curl \
        openssh \
        py-pip \
        libffi \
        libffi-dev \
        openssl \
        openssl-dev \
        g++ \
        make \
        gcc \
    && /usr/bin/pip2 install 'virtualenv' \
    && rm -rf /var/cache/apk

RUN /usr/bin/virtualenv --no-site-packages /ansible

ENV VIRTUAL_ENV=/ansible
ENV PATH=${VIRTUAL_ENV}/bin:${PATH}
ENV PYTHONHOME+_=""

RUN /ansible/bin/pip2 install 'ansible==2.4.0'

FROM alpine:3.6
ARG USER=ansible

RUN adduser -D -u 1000 -h /home/$USER $USER users

USER $USER
COPY --from=ansible /ansible /ansible
COPY --from=pass /usr/lib/password-store /usr/lib/
COPY --from=pass /usr/bin/pass /usr/bin/

ENV VIRTUAL_ENV=/ansible
ENV PATH=${VIRTUAL_ENV}/bin:${PATH}
ENV PYTHONHOME+_=

WORKDIR /home/$USER/playbook
ENTRYPOINT [ "ansible" ]
