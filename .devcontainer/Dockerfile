FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

# 1) Core deps
RUN apt-get update && apt-get install -y \
    git curl wget ca-certificates vim \
    build-essential gcc g++ make pkg-config \
    autoconf automake autotools-dev libtool \
    bison flex texinfo gperf patchutils \
    gawk libmpc-dev libmpfr-dev libgmp-dev \
    zlib1g-dev libexpat1-dev \
    device-tree-compiler libfdt-dev \
    python3 iverilog gtkwave leafpad \
    libboost-regex-dev libboost-system-dev \
        libx11-dev libxext-dev libxrender-dev libxpm-dev libxaw7-dev libcairo2-dev libfontconfig1-dev \
    libreadline-dev libncurses-dev flex bison gawk tcsh \
    python3 python3-pip pkg-config curl ca-certificates \
    xfce4 xfce4-terminal x11vnc xvfb novnc websockify supervisor dbus-x11 gedit vim \
 && rm -rf /var/lib/apt/lists/*

# 2) Host GCC sanity (force clean host PATH so cross tools can't interfere)
RUN /usr/bin/env -i PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    bash -lc 'echo "int main(){return 0;}" > /tmp/cc.c && gcc /tmp/cc.c -o /tmp/cc && /tmp/cc'

# 3) Prebuilt SiFive toolchain (no PATH change yet)
WORKDIR /opt
RUN wget -q https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14.tar.gz \
 && tar -xzf riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14.tar.gz \
 && mv riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14 /opt/riscv \
 && rm -f *.tar.gz



# 4) Spike (host build) with CLEAN_PATH
WORKDIR /tmp
RUN set -eux; \
    CLEAN_PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"; \
    git clone --depth 1 https://github.com/riscv-software-src/riscv-isa-sim.git; \
    cd riscv-isa-sim; git submodule update --init --recursive; \
    mkdir -p build && cd build; \
    PATH="$CLEAN_PATH" ../configure --prefix=/opt/riscv \
      || { echo '--- spike config.log ---'; cat config.log || true; exit 1; }; \
    PATH="$CLEAN_PATH" make -j"$(nproc)"; \
    make install; \
    rm -rf /tmp/*

# 5) riscv-pk (cross) pinned to v1.0.0 to match 2019 toolchain
WORKDIR /tmp
RUN set -eux; \
    CROSS_PATH="/opt/riscv/bin:/opt/riscv/riscv64-unknown-elf/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"; \
    git clone https://github.com/riscv-software-src/riscv-pk.git; \
    cd riscv-pk; git checkout v1.0.0; \
    mkdir -p build && cd build; \
    PATH="$CROSS_PATH" \
    CC=riscv64-unknown-elf-gcc CXX=riscv64-unknown-elf-g++ \
    AR=riscv64-unknown-elf-ar RANLIB=riscv64-unknown-elf-ranlib \
    ../configure --prefix=/opt/riscv --host=riscv64-unknown-elf \
      || { echo '--- pk config.log ---'; cat config.log || true; exit 1; }; \
    PATH="$CROSS_PATH" make -j"$(nproc)" V=1; \
    make install; \
    rm -rf /tmp/*

# 6) Finally, set a clean PATH: system tools first, then RISC-V tools
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/riscv/bin:/opt/riscv/riscv64-unknown-elf/bin"

# 7) Ensure interactive shells always use the same clean PATH
RUN printf '%s\n' \
  'export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/riscv/bin:/opt/riscv/riscv64-unknown-elf/bin"' \
  > /etc/profile.d/00-reset-path.sh && \
  chmod +x /etc/profile.d/00-reset-path.sh

WORKDIR /workspaces

# -----------------------------
# noVNC desktop environment
# -----------------------------
COPY supervisord.conf /etc/supervisor/conf.d/vnc.conf

EXPOSE 6080
CMD ["/usr/bin/supervisord", "-n"]
