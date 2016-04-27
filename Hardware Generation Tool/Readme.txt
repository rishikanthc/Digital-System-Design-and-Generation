############################################################
Rishikanth Chandrasekaran
Gunjan Shrivasthava


The code files are classifed question wise.
Each folder contains the sv files and synthesis reports


--------------------Execution------------------------

sh generator.sh k p b g COUNT
or
./generator.sh k p b g COUNT
where COUNT is the number of test cases you want to run it against.
correponding number of random test sets will be generated and tested.

The generator automatically generates sv file as well as test bench c code.
It also automatically compiles the c code to produce the
aData
xData
expectedOutput files for testing

It will also run vlog command and run all the test benches.


##################################################################