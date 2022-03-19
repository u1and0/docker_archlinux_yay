# Usage
# $ docker run -it u1and0/yay
# for update all packages
# $ sudo -u aur yay --noconfirm

FROM archlinux:base-devel AS builder
# Add yay option
RUN echo '[multilib]' >> /etc/pacman.conf &&\
    echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
# Add user for yay
ARG USERNAME=aur
RUN groupadd -g 1000 ${USERNAME} &&\
    useradd -u 1000 -g 1000 -m -s /bin/bash ${USERNAME} &&\
    passwd -d ${USERNAME} &&\
    mkdir -p /etc/sudoers.d &&\
    touch /etc/sudoers.d/${USERNAME} &&\
    echo "${USERNAME} ALL=(ALL) ALL" > /etc/sudoers.d/${USERNAME} &&\
    mkdir -p /home/${USERNAME}/.gnupg &&\
    echo 'standard-resolver' > /home/${USERNAME}/.gnupg/dirmngr.conf &&\
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME} &&\
    mkdir /build &&\
    chown -R ${USERNAME}:${USERNAME} /build
# Dependency
RUN pacman -Syu --noconfirm git go
WORKDIR "/build"
RUN git clone --depth 1 https://aur.archlinux.org/yay.git
WORKDIR "/build/yay"
RUN chown -R ${USERNAME}:${USERNAME} /build &&\
    CGO_ENABLED=0 sudo -u ${USERNAME} makepkg --noconfirm -si &&\
    sudo -u ${USERNAME} yay --afterclean --removemake --save

FROM archlinux:base-devel
COPY --from=builder /usr/bin/yay /usr/bin/yay
# Add yay option
RUN echo '[multilib]' >> /etc/pacman.conf &&\
    echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
# Add user for yay
ARG USERNAME=aur
RUN groupadd -g 1000 ${USERNAME} &&\
    useradd -u 1000 -g 1000 -m -s /bin/bash ${USERNAME} &&\
    passwd -d ${USERNAME} &&\
    mkdir -p /etc/sudoers.d &&\
    touch /etc/sudoers.d/${USERNAME} &&\
    echo "${USERNAME} ALL=(ALL) ALL" > /etc/sudoers.d/${USERNAME} &&\
    mkdir -p /home/${USERNAME}/.gnupg &&\
    echo 'standard-resolver' > /home/${USERNAME}/.gnupg/dirmngr.conf &&\
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME} &&\
    mkdir /build &&\
    chown -R ${USERNAME}:${USERNAME} /build

LABEL maintainer="u1and0 <e01.ando60@gmail.com>"\
      description="yay on archlinux image. AUR packages are able to install by yay. yay -S {package}"\
      description.ja="Archlinux コンテナ。yayによるAURパッケージインストール可能. yay -S {package}, dotfiles develop branch"\
      version="yay:0.1.1"
