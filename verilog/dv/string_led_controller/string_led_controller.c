/*
 * SPDX-FileCopyrightText: 2022 , Julien OURY
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 * SPDX-FileContributor: Created by Julien OURY <julien.oury@outlook.fr>
 */

// This include is relative to $CARAVEL_PATH (see Makefile)
#include <defs.h>
#include <stub.c>

/*
  String led controller test:
    - Configure the controller
	- Start send 1 byte
	- Wait end of send before flag the end of test
*/

#define reg_mprj_led_config       (*(volatile uint32_t*)0x30030000)
#define reg_mprj_led_multiplier   (*(volatile uint32_t*)0x30030004)
#define reg_mprj_led_divider      (*(volatile uint32_t*)0x30030008)
#define reg_mprj_led_control      (*(volatile uint32_t*)0x3003000C)
#define reg_mprj_led_data_0       (*(volatile uint32_t*)0x30031000)
#define reg_mprj_led_data_1       (*(volatile uint32_t*)0x30031004)
#define reg_mprj_led_data_2       (*(volatile uint32_t*)0x30031008)
#define reg_mprj_led_data_3       (*(volatile uint32_t*)0x3003100C)

void main() {

  // Enable WishBone bus
  reg_wb_enable = 1;

  // I/Os is used by software
  reg_mprj_io_31 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_30 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_29 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_28 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_27 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_26 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_25 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_24 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_23 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_22 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_21 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_20 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_19 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_18 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_17 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_16 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_15 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_14 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_13 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_12 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_11 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_10 = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_9  = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_8  = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_7  = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_6  = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_5  = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_4  = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_3  = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_2  = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_1  = GPIO_MODE_MGMT_STD_OUTPUT;
  reg_mprj_io_0  = GPIO_MODE_MGMT_STD_OUTPUT;

  // Apply configuration
  reg_mprj_xfer = 1;
  while (reg_mprj_xfer == 1);

  // Flag start of the test
  reg_mprj_datal = 0xAB600000;

  // Configure the controller
  reg_mprj_led_multiplier = 0x00000001;
  reg_mprj_led_divider    = 0x0000000A;  
  reg_mprj_led_config     = 0x80000000;
  reg_mprj_led_data_0     = 0x000000AF;
  reg_mprj_led_data_1     = 0x0000005F;
  reg_mprj_led_data_2     = 0x000000AA;
  reg_mprj_led_data_3     = 0x000000AA;
  
  // Start the motor
  reg_mprj_led_control    = 0x80000000;
  
  // Wait end of step moving
  int data;
  do {
     data = reg_mprj_led_control;
  } while ((data & 0x40000000) == 0x40000000 );

  // Flag end of the test
  reg_mprj_datal = 0xAB610000;
}
