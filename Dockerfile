# This docker file is for DGL regression(CPU) that runs on AWS batch.
FROM ubuntu:22.04

ENV TZ=US
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update --fix-missing
RUN apt update && apt install -y \
        apt-utils git build-essential make wget unzip sudo \
        libz-dev libxml2-dev libopenblas-dev libopencv-dev \
        graphviz graphviz-dev libgraphviz-dev ca-certificates \
        systemd vim openssh-client openssh-server cmake \
        bzip2 ca-certificates curl git python3-dev net-tools \
        awscli iputils-ping rsync tree jq x11-utils

# Update AWS CLI.
RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
RUN unzip awscliv2.zip
RUN sudo ./aws/install
RUN aws --version

# Install python packages.
RUN cd /tmp && wget https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py && cd -
# Below packages are required by DistDGL as conda environment is not supported.
# We should remove them once DistDGL supports conda.
RUN pip3 install nose numpy cython scipy networkx matplotlib nltk
RUN pip3 install requests[security] tqdm psutil pyyaml pydantic
RUN pip3 install pandas rdflib ogb filelock pyarrow
RUN pip3 install torch==1.13.1 torchvision torchaudio \
    -f https://download.pytorch.org/whl/torch_stable.html

# Install Conda.
RUN LANG=C.UTF-8 LC_ALL=C.UTF-8 PATH=/opt/conda/bin:$PATH wget --quiet \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    -O ~/miniconda.sh && /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc

# Fetch latest hello_dgl code.
RUN git clone https://github.com/dglai/hello_dgl.git --branch main /hello_dgl
