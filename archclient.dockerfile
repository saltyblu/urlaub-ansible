FROM base/archlinux:latest

RUN pacman --noconfirm -Suy openssh python \
    && rm -rf /var/cache/pacman/pkg/
RUN passwd -d root \
    && ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa

RUN sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PermitEmptyPasswords.*/PermitEmptyPasswords yes/' /etc/ssh/sshd_config

EXPOSE 22
CMD [ "/usr/sbin/sshd", "-D", "-p 22" ]
