# 8-bit CORDIC Algorithm in Verilog

## Project Overview
This project implements an 8-bit CORDIC algorithm in Verilog to calculate the sine and cosine of an input angle ranging from -90 degrees to +90 degrees.

## Specifications
- **Input:**
  - 8 bits: 1 sign bit, 1 integer bit, and 6 fractional bits
- **Output:**
  - 8 bits: 1 sign bit and 7 fractional bits

## Design Details
- **Algorithm:** CORDIC
- **Operating Frequency:** 100 MHz
- **Latency:** 150 ns

## Tools Used
- **Simulation:** ModelSim
- **Synthesis:** Cadence Genus
- **Place and Route:** Cadence Innovus

## Synthesis Results
- **Area:** 10446.48 µm²
- **Timing Analysis:**
  | Timing Stage | Hold Slack | Setup Slack |
  |--------------|------------|-------------|
  | Pre-CTS      | +0.080 ns  | +3.882 ns   |
  | Post-CTS     | +0.076 ns  | +3.892 ns   |

## Performance
- **Average Error:**
  - Cosine: 0.45%
  - Sine: 0.36%

## Verification
- No DRC (Design Rule Check) violations
- No LVS (Layout Versus Schematic) violations

## Project Files
The repository contains the following files:
- Verilog source code
- Timing analysis reports (Check [Project_Report.pdf](docs/Project_Report.pdf) in docs)
- Documentation (Check [Project_Report.pdf](docs/Project_Report.pdf) in docs)

## Getting Started
To clone and run this project, use the following commands:
```bash
git clone https://github.com/yourusername/cordic-8bit-verilog.git
