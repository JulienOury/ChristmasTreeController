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

