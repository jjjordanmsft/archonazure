FROM archlinux:latest

# Update and install dependencies
RUN pacman -Syu --noconfirm \
 && pacman -S --noconfirm gptfdisk qemu-headless dosfstools e2fsprogs git base-devel abs iproute2 \
 && useradd build
