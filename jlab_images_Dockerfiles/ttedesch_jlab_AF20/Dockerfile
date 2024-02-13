ARG BASE_IMAGE="cern/alma8-base:latest@sha256:f6e9c613a6e25f8dedb69141222a3c04f977497187bfceb87e7787ce54d27a28"
FROM ${BASE_IMAGE}

COPY packages /tmp/
RUN yum -y clean metadata \
    && yum install -y dnf-plugins-core \
    && yum -y install epel-release python39 python39-pip python39-devel boost-python3 jq \
    && xargs yum -y install < /tmp/packages \
    && yum -y clean all
    #&& rm -f /tmp/packages \
    #&& yum clean all

WORKDIR /

ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda
# Put conda in path so we can use conda activate
ENV PATH=$CONDA_DIR/bin:$PATH

RUN conda install -c conda-forge jupyterlab==4.0.9 -y
RUN conda install -c conda-forge nodejs==20.9.0 -y
RUN conda install -c conda-forge jupyterhub==4.0.2 -y
RUN conda install -c conda-forge dask==2023.11.0 -y
RUN conda install -c conda-forge bokeh==3.3.0 -y
RUN conda install -c conda-forge jupyter_bokeh==2.0.4 -y
#RUN conda install -c conda-forge dask-labextension==7.0.0 -y
#RUN conda install -c conda-forge dask-kubernetes==2023.9.0 -y
#RUN conda install -c conda-forge kr8s==0.8.16 -y
#COPY labextension.yaml /opt/conda/lib/python3.11/site-packages/dask_labextension/labextension.yaml

#RUN git clone --branch v1.0.18 https://github.com/comp-dev-cms-ita/jupyterlab-custom-kernel \
#    && cd jupyterlab-custom-kernel \
#    && jlpm \
#   && jlpm build \
#    && npm cache clean --force \
#    && python3 -m pip install -U --user . \
#    && jupyter kernelspec install ./singularity-kernel \
#    && jupyter labextension install --overwrite .

RUN pip3 install ksmm

#RUN conda config --set channel_priority strict
#RUN conda install -c conda-forge root

WORKDIR /usr/local/share/comp-dev-cms-ita

# Install DASK remote jobqueue
#RUN git clone --branch v2.0.5 https://github.com/comp-dev-cms-ita/dask-remote-jobqueue
RUN git clone --branch AF20 https://github.com/ttedeschi/dask-remote-jobqueue
RUN cd /usr/local/share/comp-dev-cms-ita/dask-remote-jobqueue \
    && python3 -m pip install -U .

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN chmod +x /bin/tini

RUN mkdir -p /root/.ipython

COPY ./condor_config /etc/condor/condor_config
COPY ./jupyterhub-singleuser.sh /usr/local/bin/jupyterhub-singleuser.sh
COPY ./jupyterhub-singleuser /usr/local/bin/jupyterhub-singleuser
COPY ./spawn.sh /root/.init/spawn.sh
RUN chmod +x /usr/local/bin/jupyterhub-singleuser.sh
RUN chmod +x /usr/local/bin/jupyterhub-singleuser && chmod +x /root/.init/spawn.sh

RUN mkdir -p /root/.ipython



COPY ./ca.crt /ca.crt

WORKDIR /etc/yum.repos.d/
RUN wget http://repository.egi.eu/sw/production/cas/1/current/repo-files/egi-trustanchors.repo
RUN wget http://linuxsoft.cern.ch/wlcg/wlcg-centos8.repo
WORKDIR /etc/pki/rpm-gpg
RUN wget http://linuxsoft.cern.ch/wlcg/RPM-GPG-KEY-wlcg

RUN yum search voms
RUN yum install -y  apptainer voms-clients-cpp ca-policy-lcg


RUN mkdir -p /.init \
    && wget https://github.com/DODAS-TS/sts-wire/releases/download/v2.0.0/sts-wire_linux -O /.init/sts-wire \
    && chmod +x /.init/sts-wire

# Install tailwind css
#RUN jupyter labextension install jupyterlab-tailwind-theme

#RUN mkdir -p ~/.jupyter/lab/settings && \
#    echo '{"@jupyterlab/apputils-extension:themes": {"theme":"Tailwind Light"}}'> ~/.jupyter/lab/settings/overrides.json

RUN yum install -y https://research.cs.wisc.edu/htcondor/repo/9.0/htcondor-release-current.el8.noarch.rpm

RUN sed -i 's/current/8.9/g' /etc/yum.repos.d/htcondor.repo

RUN yum install -y condor

# Install DASK labextension
RUN pip3 install loguru

WORKDIR /usr/local/share/comp-dev-cms-ita
RUN git clone --branch 7.0.0-af-plugin https://github.com/ttedeschi/dask-labextension.git
#RUN git clone --branch v2.0.1 https://github.com/comp-dev-cms-ita/dask-labextension.git
#RUN git clone https://github.com/comp-dev-cms-ita/dask-labextension.git

COPY labextension.yaml /usr/local/share/comp-dev-cms-ita/dask-labextension/dask_labextension/
WORKDIR /usr/local/share/comp-dev-cms-ita/dask-labextension
RUN jlpm \
    && jlpm build \
    && npm cache clean --force

#RUN python3 -m pip install . #--use-feature=fast-deps
#RUN jupyter labextension develop . --overwrite
#RUN jupyter labextension develop . --overwrite
RUN python3 -m pip install .
COPY _version.py /opt/conda/lib/python3.11/site-packages/dask_labextension/
RUN jupyter server extension enable --sys-prefix dask_labextension

WORKDIR /usr/local/share/comp-dev-cms-ita
COPY singularity-kernel /usr/local/share/comp-dev-cms-ita/singularity-kernel
RUN jupyter kernelspec install /usr/local/share/comp-dev-cms-ita/singularity-kernel

RUN jupyter lab build

RUN sed -i 's/kwargs.pop("host_allowlist", \["localhost", "127.0.0.1"\])/lambda app, host: True/' /opt/conda/lib/python3.11/site-packages/jupyter_server_proxy/handlers.py

WORKDIR /opt/workspace
