# Stage 1: Builder image
FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu22.04 AS builder

# System utils for building
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y wget git poppler-utils chktex \
    python3.11 python3.11-distutils python3.11-dev python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Setup miniconda
ENV CONDA_DIR=/opt/conda
RUN wget -qO- https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh | \
    bash -b -p $CONDA_DIR
ENV PATH=$CONDA_DIR/bin:$PATH
RUN conda update -y -n base -c defaults conda

# Create and populate conda environment
RUN conda create -n ai_scientist python=3.11 -y
RUN conda install -n ai_scientist pytorch torchvision torchaudio pytorch-cuda=12.4 -c pytorch -c nvidia -y
RUN conda install -n ai_scientist anaconda::poppler conda-forge::chktex -y

# Install Python requirements
COPY requirements.txt /tmp/
RUN conda run -n ai_scientist pip install -r /tmp/requirements.txt

# Export conda environment to yaml for later use
RUN conda env export -n ai_scientist > /tmp/environment.yml

# Stage 2: Runtime image
FROM nvidia/cuda:12.8.1-cudnn-runtime-ubuntu22.04

# Install only runtime dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y poppler-utils chktex \
    python3.11 python3.11-distutils libcudnn8 vim htop && \
    rm -rf /var/lib/apt/lists/*

# Copy conda from builder stage
ENV CONDA_DIR=/opt/conda
COPY --from=builder $CONDA_DIR $CONDA_DIR
ENV PATH=$CONDA_DIR/bin:$PATH

# Copy the exported environment
COPY --from=builder /tmp/environment.yml /tmp/environment.yml

# Create lightweight environment from exported yaml
RUN conda env create -f /tmp/environment.yml && \
    conda clean -afy && \
    rm -rf /tmp/environment.yml

# Project setup
WORKDIR /workspace/ai_scientist
COPY . /workspace/ai_scientist

# Run as non-root user for better security
RUN groupadd -r scientist && useradd -r -g scientist scientist
RUN chown -R scientist:scientist /workspace
USER scientist

# Entrypoint
ENTRYPOINT ["bash", "-c", "source activate ai_scientist && tail -f /dev/null"]