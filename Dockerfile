FROM nvidia/cuda:13.1.1-devel-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PYTHONUNBUFFERED=1 \
    TORCH_CUDA_ARCH_LIST="8.6+PTX" \
    HF_HUB_ENABLE_HF_TRANSFER=1

RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv python3-dev python-is-python3 \
    git curl wget ca-certificates tmux openssh-server nginx \
    build-essential pkg-config cmake ninja-build \
    libgl1 libglib2.0-0 libsm6 libxext6 libxrender1 \
    libeigen3-dev libyaml-cpp-dev \
    && rm -rf /var/lib/apt/lists/*

COPY proxy/nginx.conf /etc/nginx/nginx.conf
COPY proxy/readme.html /usr/share/nginx/html/readme.html

WORKDIR /opt
RUN git clone --recursive https://github.com/luigifreda/pyslam.git

WORKDIR /opt/pyslam

RUN chmod +x pyenv-create.sh pyenv-activate.sh install_all.sh && \
    ./pyenv-create.sh && \
    ./install_all.sh

COPY scripts/start.sh /start.sh
RUN chmod 755 /start.sh

WORKDIR /workspace
CMD ["/start.sh"]