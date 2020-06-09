FROM lsstsqre/centos:7-stack-lsst_distrib-v19_0_0
MAINTAINER Heather Kelly <heather@slac.stanford.edu>

ARG LSST_STACK_DIR=/opt/lsst/software/stack

ARG LSST_USER=lsst
ARG LSST_GROUP=lsst

WORKDIR $LSST_STACK_DIR

# Versions of additional packages to install
ARG DESC_GCR_VER=0.8.8
ARG DESC_GCRCatalogs_VER=v0.14.3
# numba version CC includes with CVMFS v19 installation
ARG DESC_numba_VER=0.46.0
ARG DESC_ngmix_VER=1.3.4
ARG DESC_ngmix_VER_STR=v$DESC_ngmix_VER
ARG DESC_meas_extensions_ngmix_VER=0.9.5
ARG DESC_DC2_PRODUCTION_VER=0.4.0
ARG DESC_DC2_PRODUCTION_VER_STR=v$DESC_DC2_PRODUCTION_VER
ARG DESC_OBS_LSST_VER=19.0.0-run2.2-v2
ARG DESC_SIMS_CI_PIPE_VER=0.1.1
ARG DESC_IPP_VER=DC2-Run2.2i-1.1.0

# One RUN command to reduce docker image size
# pip freeze captures all of the current DMstack python package versions so we avoid updating those
# pip install GCR and GCRCatalogs
# install DESC obs_lsst
# install sims_ci_pipe
# install DC2-production
# install Erin Sheldon's ngmix
# install DM's meas_extensions_ngmix

RUN echo "Environment: \n" && env | sort && \
    source scl_source enable devtoolset-8 && \
    echo -e "source scl_source enable devtoolset-8\n$(cat loadLSST.bash)" > loadLSST.bash && \
    /bin/bash -c 'source $LSST_STACK_DIR/loadLSST.bash; \
                  export EUPS_PKGROOT=https://eups.lsst.codes/stack/src; \
                  setup lsst_distrib; \
                  pip freeze > $LSST_STACK_DIR/dm-constraints.txt; \
                  pip install -c $LSST_STACK_DIR/dm-constraints.txt GCR==$DESC_GCR_VER; \
                  pip install -c $LSST_STACK_DIR/dm-constraints.txt https://github.com/LSSTDESC/gcr-catalogs/archive/$DESC_GCRCatalogs_VER.tar.gz; \
                  pip install -c $LSST_STACK_DIR/dm-constraints.txt numba==$DESC_numba_VER; \
                  curl -LO https://github.com/LSSTDESC/ImageProcessingPipelines/archive/$DESC_IPP_VER.tar.gz; \
                  tar xvfz $DESC_IPP_VER.tar.gz; \
                  ln -s ImageProcessingPipelines-$DESC_IPP_VER ImageProcessingPipelines; \
                  curl -LO https://github.com/lsst/obs_lsst/archive/$DESC_OBS_LSST_VER.tar.gz; \
                  tar xvfz $DESC_OBS_LSST_VER.tar.gz; \ 
                  ln -s obs_lsst-$DESC_OBS_LSST_VER obs_lsst; \
                  cd obs_lsst; \
                  setup -r . -j; \
                  scons; \
                  cd ..; \
                  curl -LO https://github.com/LSSTDESC/sims_ci_pipe/archive/$DESC_SIMS_CI_PIPE_VER.tar.gz; \
                  tar xvzf $DESC_SIMS_CI_PIPE_VER.tar.gz; \
                  ln -s sims_ci_pipe-$DESC_SIMS_CI_PIPE_VER sims_ci_pipe; \
                  cd sims_ci_pipe; \
                  setup -r . -j; \   
                  scons; \
                  cd ..; \
                  curl -LO https://github.com/LSSTDESC/DC2-production/archive/$DESC_DC2_PRODUCTION_VER_STR.tar.gz; \
                  tar xvfz $DESC_DC2_PRODUCTION_VER_STR.tar.gz; \
                  rm $DESC_DC2_PRODUCTION_VER_STR.tar.gz; \
                  ln -s DC2-production-$DESC_DC2_PRODUCTION_VER DC2-production; \
                  curl -LO https://github.com/esheldon/ngmix/archive/$DESC_ngmix_VER_STR.tar.gz; \
                  tar xzf $DESC_ngmix_VER_STR.tar.gz; \
                  cd ngmix-$DESC_ngmix_VER; \ 
                  python setup.py install; \
                  cd ..; \
                  rm $DESC_ngmix_VER_STR.tar.gz; \
                  ln -s ngmix-$DESC_ngmix_VER ngmix; \
                  curl -LO https://github.com/lsst-dm/meas_extensions_ngmix/archive/v$DESC_meas_extensions_ngmix_VER.tar.gz; \
                  tar xzf v$DESC_meas_extensions_ngmix_VER.tar.gz; \
                  cd meas_extensions_ngmix-$DESC_meas_extensions_ngmix_VER; \
                  setup -r . -j; \
                  scons; \
                  cd ..; \
                  rm v$DESC_meas_extensions_ngmix_VER.tar.gz; \
                  ln -s meas_extensions_ngmix-$DESC_meas_extensions_ngmix_VER meas_extensions_ngmix;' 
