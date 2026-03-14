FROM nvidia/cuda:13.1.1-devel-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive \
    TORCH_CUDA_ARCH_LIST="8.6+PTX" \
    HF_HUB_ENABLE_HF_TRANSFER=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONUNBUFFERED=1 \
    VENV_PATH=/opt/venv

# --------------------------------------------------------
# 1. Base system packages
# --------------------------------------------------------
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv python3-dev \
    git tmux wget curl ca-certificates openssh-server nginx \
    build-essential pkg-config \
    libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Make python/pip the default commands
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# --------------------------------------------------------
# 2. Prepare host (SSH, NGINX)
# --------------------------------------------------------
RUN rm -f /etc/ssh/ssh_host_*

COPY proxy/nginx.conf /etc/nginx/nginx.conf
COPY proxy/readme.html /usr/share/nginx/html/readme.html

# --------------------------------------------------------
# 3. Create isolated Python environment
# --------------------------------------------------------
RUN python -m venv ${VENV_PATH}
ENV PATH="${VENV_PATH}/bin:${PATH}"

RUN python --version && pip --version && \
    pip install --upgrade pip setuptools wheel

# --------------------------------------------------------
# 4. Install PyTorch
# --------------------------------------------------------
RUN pip install \
    torch==2.9.1 \
    torchvision==0.24.1 \
    torchaudio==2.9.1 \
    --index-url https://download.pytorch.org/whl/cu130

# --------------------------------------------------------
# 5. Install JupyterLab
# --------------------------------------------------------
RUN pip install jupyterlab

# --------------------------------------------------------
# 6. Workspace
# --------------------------------------------------------
WORKDIR /workspace

# --------------------------------------------------------
# 7. Start script
# --------------------------------------------------------
COPY scripts/start.sh /start.sh
RUN chmod 755 /start.sh

CMD ["/start.sh"]