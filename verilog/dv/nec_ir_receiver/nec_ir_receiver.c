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
  NEC IR receiver Test:
    - Configure IR receiver
    - Wait data from IR receiver
*/

#define reg_mprj_ir_cmd        (*(volatile uint32_t*)0x30000000)
#define reg_mprj_ir_multiplier (*(volatile uint32_t*)0x30000004)
#define reg_mprj_ir_divider    (*(volatile uint32_t*)0x30000008)
#define reg_mprj_ir_data       (*(volatile uint32_t*)0x3000000C)

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

  // Configuration of IR receiver
  // - Protocol tick period divided by 10 for simulation speed-up
  reg_mprj_ir_multiplier = 0x00000064;
  reg_mprj_ir_divider    = 0x00006DDD;
  reg_mprj_ir_cmd        = 0x94000000;

  // Flag start of the test
  reg_mprj_datal = 0xAB600000;

  // Wait data from IR receiver
  int ir_data;
  do {
     ir_data = reg_mprj_ir_data;
  } while ((ir_data & 0x80000000) != 0x80000000 );

  //Flage end of the test (and provide IR received data)
  reg_mprj_datal = 0xAB610000 | (ir_data & 0x0000FFFF) ;

}
