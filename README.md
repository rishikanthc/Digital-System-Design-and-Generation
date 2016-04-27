#Digital System Design and Generation - System Verilog Projects

This repository contains 3 digital design projects. Each folder contains the problem statement and the reports for the projects.
The projects are system verilog codes for ASIC design of modules as described below.
A brief description of the projects is given below:



1. Multiply and Accumulate - This is a basic multiply and accumulation unit that implements the equation f= f +a*b. The project is just for exploring system verilog and getting familiar with concepts of ASIC design. The effects of pipeling - with different stages and at different places are studied and analysis of area, critical path, clock and power is done. A testbench is also implemented which consists of a C file that generates test case inputs that are then fed into the design developed. The C file also generates the exepcted output values for the sample input given. The results from the design are then compared with the expected output values to verify operation of the design.

2. Matrix Vector Multiplication - A matrix vector multiplication for multiplying 3x3 matrix with a vector and similarly for 4x4 matrix witha a vector are implemented. A basic implementation is done followed by various optimized implementations for optimizing - delay, power and area are done. The optimizations are done by either pipelining, parallelization or modifying control logic to produce a better design. A testbench is also written to verify operation and functionality.


3. Hardware Generation Tool - This project is a code generation tool that generates System Verilog code for implementation of a Matrix Vector Multiplier. It takes as inputs from the user the following specifications for the Matrix Vector Multiplier: Number of bits (precision), Matrix and Vector dimensions, Degree of parallelism and Pipelining options. Based on the inputs given by the user, the tool generates the System Verliog code for the implementation of the system with the input specifications. Also, a testbench is also generated automatically to verify the design generated and produced. Performance reports of critical path, timing analysis, area and power are auto generated and stored. The report presents the implications of the design choices as well as the analysis of the tool in terms of efficiency of design and the performance parameters.
