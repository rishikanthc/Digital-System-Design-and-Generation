*****************************************************************************
PART 1
The code in this folder is the implementation of 4x4 matrix & 4x1 vector 
multiplier.
This is the solution for Part 2.

The final name is part2.sv
The commands to be executed are:

cc test.c
./aout
vlog mem.sv
vsim tbench -c -do "run -all"

NOTE: Important
The folder already contains compiled expectedOutput and inputData files.
Hence it is sufficient to run
vlog mem.sv
vsim tbench -c -do "run -all"


NOTE 2: Important
The C program has a #define COUNT parameter on top which can be used to set
the number of test cases to be generated.
Simiary the tbench module in mem.sv has a parameter COUNT which should also be
set to the same value.


------------------------Testbench------------------------------------
The testbench comprhensively evaluates all possible cases.
It generates random test set matrices and vectors as per number set.
It also tests the start & reset signals
______________________________________________________________________
********************************************************************************