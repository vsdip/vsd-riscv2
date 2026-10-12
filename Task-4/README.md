# Task-4: PWM IP Development

## Objective
Design and integrate a software-controlled PWM IP block into the RISC-V FPGA project.

## Register Map
| Offset | Register | Purpose |
|---|---|---|
| 0x00 | CTRL | Enable or disable PWM |
| 0x04 | PERIOD | Configure PWM period |
| 0x08 | DUTY | Configure duty value |
| 0x0C | STATUS | Read PWM status |

## Files
- `code/RTL/pwm.v` — PWM implementation
- `code/RTL/pwm_tb.v` — Standalone testbench
- `code/RTL/pwm_soc_tb.v` — SoC testbench
- `code/RTL/riscv.v` — SoC RTL
- `code/RTL/gpio.v` — GPIO dependency
- `code/RTL/Makefile` — FPGA build commands
- `code/Firmware/pwm_test.c` — Firmware test
- `evidence/` — Simulation and build screenshots

## Verification
- Standalone PWM simulation completed successfully in the previously shared run.
- PWM output toggling was observed with PERIOD = 8 and DUTY = 2.
- FPGA build was previously reported successful.
- SoC-level simulation had a reported timeout; final status is unconfirmed.
- Physical FPGA board LED behavior is unconfirmed.

## Run Standalone Simulation
From `code/RTL/`, run `iverilog -g2012 -o pwm_tb_sim pwm.v pwm_tb.v` followed by `vvp pwm_tb_sim`.

## Evidence
- `evidence/task4_pwm_standalone_sim_passed.png`
- `evidence/task4_pwm_standalone_sim_verified.png`
- `evidence/task4_pwm_soc_rebuild_success.png`
- `evidence/task4_pwm_cpu_soc_test_passed.png`
- `evidence/task4_pwm_hardware_build_success.png`
