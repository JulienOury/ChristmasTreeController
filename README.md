[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![UPRJ_CI](https://github.com/JulienOury/ChristmasTreeController/actions/workflows/user_project_ci.yml/badge.svg)](https://github.com/JulienOury/ChristmasTreeController/actions/workflows/user_project_ci.yml)

# Christmas tree controller (ASIC)

This design implements a Christmas tree controller that include four dedicated modules :
 - Infrared receiver (protocol NEC)
 - StepMotor controller (full-step, half-step, with strenght control)
 - Led string controller (compatibles WS2812B)
 - Pseudo-random generator (32bits)

The purpose of this System On Chip (SoC) is to control a Christmas tree. This controller allows, thanks to an infrared remote control, to control an garland of RGB LEDs as well as its rotating star at its top.

### Architecture

This design is based on [Caravel user project](https://github.com/efabless/caravel_user_project.git) template.

Below is a representation of the architecture:

![multi macro](pictures/soc_architecture.png)


### Memory mapping

The Wishbone bus address mapping below :

| ADDRESS | DESCRIPTION |
| ------ | ------ |
| 0x30000000 | NEC IR receiver |
| 0x30010000 | PseudoRandom generator |
| 0x30020000 | Step motor controller |
| 0x30030000 | String Led controller |


### ASIC layout

Below is a representation of the ASIC layout:

![multi macro](pictures/layout.png)


# USAGE
## Install dependencies
```
sudo apt-get update
sudo apt-get install m4 --assume-yes
sudo apt-get install tcsh --assume-yes
sudo apt-get install csh --assume-yes
sudo apt-get install libx11-dev --assume-yes
sudo apt-get install tcl-dev tk-dev --assume-yes
sudo apt-get install libcairo2-dev --assume-yes
sudo apt-get install mesa-common-dev libglu1-mesa-dev --assume-yes
sudo apt-get install libncurses-dev --assume-yes
sudo apt-get install git --assume-yes
git clone https://github.com/RTimothyEdwards/magic.git
cd magic
./configure 
sudo make
sudo make install
sudo apt-get install build-essential clang bison flex \
	libreadline-dev gawk tcl-dev libffi-dev git \
	graphviz xdot pkg-config python3 libboost-system-dev \
	libboost-python-dev libboost-filesystem-dev zlib1g-dev --assume-yes
git clone https://github.com/YosysHQ/yosys.git
cd yosys
sudo make
sudo make install
sudo apt-get remove docker docker-engine docker.io containerd runc --assume-yes
sudo apt-get update --assume-yes
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release --assume-yes
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg --yes
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update --assume-yes
sudo apt-get install docker-ce docker-ce-cli containerd.io --assume-yes
```
## Build the project
```
project_name=EfablessMpw5
design_name=ChristmasTreeController

project_folder=$BASEDIR/$project_name
design_folder=$project_folder/$design_name

export OPENLANE_ROOT=$project_folder/openlane
export PDK_ROOT=$OPENLANE_ROOT/pdks
export CARAVEL_ROOT=$design_folder/caravel
export PRECHECK_ROOT=$project_folder/precheck

cd $design_folder
make install
make install_mcw
git clone https://github.com/efabless/caravel_pico.git

make user_proj_example
make user_project_wrapper

```
## Make RTL simulations
```
make simenv
make simlink

export SIM=RTL

make verify-all-rtl
```

## Make GL simulation
```
make simenv
make simlink

export SIM=GL

make verify-all-gl
```
## ZIP ASIC database files
```
make zip
```
## UNZIP ASIC database files
```
make unzip
```
## Clean
```
make clean
make clean-user_project_wrapper
make clean-user_proj_example
rm -rf openlane/user_proj_example/runs
rm -rf openlane/user_project_wrapper/runs
rm -f ./def/*
rm -f ./lef/*
rm -f ./gds/*
rm -f ./mag/*
rm -f ./maglef/*
rm -f ./spef/*
rm -f ./spi/lvs/*
rm -f ./sdf/*
rm -rf ./sdf
```
