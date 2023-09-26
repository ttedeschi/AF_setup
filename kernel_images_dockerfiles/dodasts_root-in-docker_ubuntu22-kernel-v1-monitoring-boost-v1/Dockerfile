FROM ubuntu:20.04

# ROOT deps
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive TZ=Europe/Zurich apt-get -y -q install \
    git python3 python3-pip curl sudo

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN chmod +x /bin/tini

RUN python3 -m pip install -U pip setuptools wheel

RUN curl -fsSL https://research.cs.wisc.edu/htcondor/repo/keys/HTCondor-Release.gpg.key | apt-key add - \
    && echo  "deb [arch=amd64] https://research.cs.wisc.edu/htcondor/repo/ubuntu/8.9 focal main\ndeb-src https://research.cs.wisc.edu/htcondor/repo/ubuntu/8.9 focal main" > /etc/apt/sources.list.d/htcondor.list

RUN apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Europe/Zurich apt-get install -y htcondor

RUN pip3 install \
    htcondor==9.0.4 \
    click==7.1.2 \
    ipython \
    "dask[complete]==2021.11.1" \
    dask-jobqueue==0.7.3

WORKDIR /usr/local/share/comp-dev-cms-ita

# Install dask remote jobqueue
RUN git clone --branch v0.6.0 https://github.com/comp-dev-cms-ita/dask-remote-jobqueue
# WORKDIR /usr/local/share/comp-dev-cms-ita/dask-remote-jobqueue
# RUN python3 setup.py install
# WORKDIR /usr/local/share/comp-dev-cms-ita
RUN cd /usr/local/share/comp-dev-cms-ita/dask-remote-jobqueue \
    && python3 -m pip install -U .

COPY ./condor_config /etc/condor/condor_config
COPY ./ca.crt /ca.crt

RUN apt-key adv --keyserver hkp://pgp.surfnet.nl --recv-keys ACDFB08FDC962044D87FF00B512839863D487A87

RUN apt-get -y install software-properties-common && add-apt-repository "deb http://repo.data.kit.edu/ubuntu/bionic ./" && add-apt-repository universe

RUN wget http://archive.ubuntu.com/ubuntu/pool/universe/q/qrencode/libqrencode3_3.4.4-1build1_amd64.deb && dpkg -i libqrencode3_3.4.4-1build1_amd64.deb

RUN apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Europe/Zurich apt-get -y install oidc-agent-cli

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive TZ=Europe/Zurich apt-get -y -q install \
    dpkg-dev cmake g++ gcc binutils libx11-dev libxpm-dev \
    libxft-dev libxext-dev libssl-dev gfortran libpcre3-dev \
    xlibmesa-glu-dev libglew-dev libftgl-dev \
    libmysqlclient-dev libfftw3-dev libcfitsio-dev \
    graphviz-dev libavahi-compat-libdnssd-dev \
    libldap2-dev libxml2-dev libkrb5-dev wget \
    libgsl0-dev git python3 python3-pip curl sudo \
    libblas-dev protobuf-compiler

RUN pip3 install ipykernel ipywidgets matplotlib

RUN apt-get -y install davix

#RUN git clone https://github.com/root-project/root.git root_src
RUN git clone https://github.com/vepadulano/root.git -b infn-branch root_src
RUN mkdir root_build
RUN cmake -Dgminimal=ON -Dpyroot=ON -Ddataframe=ON -Dgnuinstall=ON -Ddev=ON \
          -Dbuiltin_xrootd=ON -Dxrootd=ON -Dbuiltin_davix=ON -Ddavix=ON  \
          -Dtmva=ON -Dmlp=ON -Dtmva-pymva=ON -Dtmva-cpu=ON -Dtmva-sofie=ON \
          -Dasimage=ON -Druntime_cxxmodules=ON \
          -B root_build -S root_src
RUN cmake --build root_build -- install -j$(nproc)

# Remove artifacts
RUN rm -rf root_build root_src

# Change environment so that libraries are properly found
RUN echo /usr/local/lib/root >> /etc/ld.so.conf && ldconfig
ENV PYTHONPATH /usr/local/lib/root:$PYTHONPATH
ENV CLING_STANDARD_PCH none

#RUN git clone https://gitlab.cern.ch/cp3-cms/CMSJMECalculators.git \
RUN ls
RUN git clone https://gitlab.cern.ch/ttedesch/CMSJMECalculators.git \
    && cd CMSJMECalculators \
    #&& sed -i 's/\/\/ #define/#define/' src/JMESystematicsCalculators.cc \
    && mkdir build && cd build \
    && cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMSJMECALCULATOR_VERSION:STRING=0.1.dev34+g60e6d09 \
        -DCMAKE_INSTALL_PREFIX=/ \
        -DCMAKE_VERBOSE_MAKEFILE=ON \
        -S .. \
    && cmake --build . -- install -j8 \
    && cp G__CMSJMECalculators_rdict.pcm /lib/G__CMSJMECalculators_rdict.pcm

RUN pip3 install rucio-clients

COPY ./boost_1_77_0 /usr/lib/boost_1_77_0
