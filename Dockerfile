FROM lsstsqre/centos:7-stack-lsst_distrib-w_2021_04
MAINTAINER Heather Kelly <heather@slac.stanford.edu>

ARG LSST_STACK_DIR=/opt/lsst/software/stack

ARG LSST_USER=lsst
ARG LSST_GROUP=lsst

WORKDIR $LSST_STACK_DIR

USER root
RUN yum install -y time
USER lsst

# Additional packages to install
ARG DESC_GCR_VER=v0.9.2
ARG DESC_GCRCATALOGS_VER=v1.2.1

# versions CC includes with CVMFS w_2021_04 installation
ARG DESC_numba_VER=0.52.0
ARG DESC_llvmlite_VER=0.35.0

ARG DESC_NGMIX_VER=v1.3.8
ARG DESC_meas_extensions_ngmix_VER=0.9.6
ARG DESC_DC2_PRODUCTION_VER=v0.5.0
ARG DESC_GEN3_WORKFLOW_VER=u/jchiang/gen3_scripts
ARG DESC_IPP_VER=v1.0-dr2-parsl

# One RUN command to reduce docker image size
# conda install GCR, GCRCatalogs, numba, llvmlit, ngmix
#                   conda install -c conda-forge -y --freeze-installed llvmlite==$DESC_llvmlite_VER; \

# install gen3_workflow
# install sims_ci_pipe master 
# install DC2-production
# install DM's meas_extensions_ngmix


RUN echo "Environment: \n" && env | sort && \
    /bin/bash -c 'source $LSST_STACK_DIR/loadLSST.bash; \
                  export EUPS_PKGROOT=https://eups.lsst.codes/stack/src; \
                  setup lsst_distrib; \
                  conda install -c conda-forge -y --freeze-installed gcr==$DESC_GCR_VER; \
                  conda install -c conda-forge -y --freeze-installed lsstdesc-gcr-catalogs==$DESC_GCRCATALOGS_VER; \
                  conda install -c conda-forge -y --freeze-installed ngmix==$DESC_NGMIX_VER; \
                  git clone https://github.com/LSSTDESC/gen3_workflow.git; \
                  cd gen3_workflow; \
                  git checkout $DESC_GEN3_WORKFLOW_VER; \
                  setup -r . -j; \
                  cd ..;\
                  curl -LO https://github.com/LSSTDESC/ImageProcessingPipelines/archive/$DESC_IPP_VER.tar.gz; \
                  tar xvfz $DESC_IPP_VER.tar.gz; \
                  ln -s ImageProcessingPipelines-$DESC_IPP_VER ImageProcessingPipelines; \
                  git clone https://github.com/LSSTDESC/sims_ci_pipe; \
                  cd sims_ci_pipe; \
                  setup -r . -j; \   
                  scons; \
                  cd ..; \
                  curl -LO https://github.com/LSSTDESC/DC2-production/archive/$DESC_DC2_PRODUCTION_VER.tar.gz; \
                  tar xvfz $DESC_DC2_PRODUCTION_VER.tar.gz; \
                  rm $DESC_DC2_PRODUCTION_VER.tar.gz; \
                  ln -s DC2-production-$DESC_DC2_PRODUCTION_VER DC2-production; \
                  curl -LO https://github.com/lsst-dm/meas_extensions_ngmix/archive/v$DESC_meas_extensions_ngmix_VER.tar.gz; \
                  tar xzf v$DESC_meas_extensions_ngmix_VER.tar.gz; \
                  cd meas_extensions_ngmix-$DESC_meas_extensions_ngmix_VER; \
                  setup -r . -j; \
                  scons; \
                  cd ..; \
                  rm v$DESC_meas_extensions_ngmix_VER.tar.gz; \
                  ln -s meas_extensions_ngmix-$DESC_meas_extensions_ngmix_VER meas_extensions_ngmix;' 
