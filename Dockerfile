# Stage 1: Builder image
FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu22.04 AS builder

# System utils for building
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y wget git poppler-utils chktex \
    python3.11 python3.11-distutils python3.11-dev python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Setup miniconda
ENV CONDA_DIR=/opt/conda
# Download and install Miniconda
RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p $CONDA_DIR && \
    rm /tmp/miniconda.sh
ENV PATH=$CONDA_DIR/bin:$PATH
RUN conda update -y -n base -c defaults conda

# Create and populate conda environment
RUN conda create -n ai_scientist python=3.11 -y
RUN conda install -n ai_scientist pytorch torchvision torchaudio pytorch-cuda=12.4 -c pytorch -c nvidia -y
RUN conda install -n ai_scientist anaconda::poppler conda-forge::chktex -y

# Install Python requirements
COPY requirements.txt /tmp/
RUN conda run -n ai_scientist pip install -r /tmp/requirements.txt
# Ensure tiktoken is properly installed
RUN conda run -n ai_scientist pip install --no-cache-dir tiktoken

# Export conda environment to yaml for later use
RUN conda env export -n ai_scientist > /tmp/environment.yml

# Stage 2: Runtime image
FROM nvidia/cuda:12.8.1-cudnn-runtime-ubuntu22.04

# Install only runtime dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y poppler-utils chktex \
    python3.11 python3.11-distutils libcudnn8 vim htop wget && \
    rm -rf /var/lib/apt/lists/*

# Add TeXLive packages for LaTeX compilation
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      texlive-latex-base \
      texlive-fonts-recommended \
      texlive-latex-extra \
      texlive-bibtex-extra && \
    rm -rf /var/lib/apt/lists/*

# Setup fresh miniconda in runtime stage
ENV CONDA_DIR=/opt/conda
RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p $CONDA_DIR && \
    rm /tmp/miniconda.sh
ENV PATH=$CONDA_DIR/bin:$PATH

# Copy only the environment.yml file from builder stage
COPY --from=builder /tmp/environment.yml /tmp/environment.yml

# Create environment from the exported yaml and clean up
RUN conda env create -f /tmp/environment.yml && \
    conda clean -afy && \
    rm -rf /tmp/environment.yml

# Explicitly install tiktoken in the runtime stage
RUN conda run -n ai_scientist pip install --no-cache-dir tiktoken

# Add conda environment to PATH so it's available in all shells without activation
ENV PATH=/opt/conda/envs/ai_scientist/bin:$PATH

# Project setup
WORKDIR /workspace/ai_scientist
COPY . /workspace/ai_scientist

# Run as non-root user for better security
RUN groupadd -r scientist && useradd -r -g scientist scientist
RUN chown -R scientist:scientist /workspace
USER scientist

# Entrypoint
ENTRYPOINT ["bash", "-c", "source activate ai_scientist && tail -f /dev/null"]