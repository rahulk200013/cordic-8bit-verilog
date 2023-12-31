**Introduction**

Coordinate Rotation Digital Computer (CORDIC) is a simple and efficient algorithm to
compute arithmetic, trigonometric and hyperbolic functions. CORDIC algorithm is an
iterative algorithm that evaluates a function by successive clockwise or anticlockwise
micro rotations of coordinates. The benefit of the CORDIC algorithm is that the
microrotations are calculated by simple shift-and-add operations, which is very efficient
in hardware.
In this assignment, the sine and cosine of the angle are calculated using the CORDIC
algorithm. The range of the angles covered is from -90° to 90°. The input angle is an
8-bit number with 1 sign bit, 1 integer bit and 6 fractional bits. The outputs are also an
8-bit number. The Verilog code for calculating the sine of the angle using CORDIC
algorithm is simulated in the ModelSim simulation environment. The design is then
synthesized using the Cadence Genus tool.

**Specifications**

Operating Frequency: 100MHz\
Rise and Fall time: 0.1ns\
Latency: 150ns (15 clock cycles)\
Average error: 0.45% (Cosine) and 0.36% (Sine)


| Slack | Setup (ns)    | Hold (ns)    |
| :---:   | :---: | :---: |
| Pre-CTS | 3.882   | 0.080   |
| Post-CTS | 3.892   | 0.076   |

\
**Tools Used**

Synthesis - Genus\
Place & Route - Innovus\
Simulation - ModelSim




