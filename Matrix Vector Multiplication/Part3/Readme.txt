*****************************************************************************
PART 1
This folder contains the codes for delay optimized matrix vector multipliers
for 4x4 matrix and 4x1 vector.

There are 4 different codes present inside the folder

Parallelism-pipeline-iooverlap.sv : Implements parallelism along with pipelining
									and input/output overlap

Parallelism-pipeline.sv			  : Implements parallelism along with pipelining

part3-iooverlap.sv				  : Implements input/output overlap

part3-pipeline-dw.sv 			  : Implements pipelining of multipliers using 											Design Ware components and a pipeline flipflop 										between multiplier and adder.


The commands to be executed are:

cc test.c
./aout
vlog <filename.sv>.
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
********************************************************************************