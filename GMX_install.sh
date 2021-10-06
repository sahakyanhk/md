#!/bin/bash
# !!! This script was tested for nvidia/cuda:10.2-devel-ubuntu18.04 image 

echo y | apt-get install wget emacs cmake

#download gromacs
wget  ftp://ftp.gromacs.org/pub/gromacs/gromacs-2020.4.tar.gz

tar xfz gromacs-2020.4.tar.gz
cd gromacs-2020.4
mkdir build 
cd build 

#installation, https://manual.gromacs.org/documentation/current/install-guide/index.html
cmake .. -DGMX_BUILD_OWN_FFTW=ON -DGMX_GPU=on  #-DGMX_SIMD=SSE4.1
make -j 8
make install

echo source /usr/local/gromacs/bin/GMXRC >> ~/.bashrc

cd 
rm -r grom*
bash
