Part 3 
This file contains the code for mac with the pipeline. There are 2 parts in this. The first part pipe lines the the whole design by putting an extra register in between adder and multiplier. 
In the next part we pipeline the multiplier. There are stages from 2 to 6. Each have separate synthesis report. 
 q3.sv  ---> code for part 3 
stage 2 .txt -- > sysnthesis report for stage 2
stage3_1 .txt -- sysnthesis report for stage 3
stage 4_1 .txt -- sysnthesis report for stage 4
stage5 .txt -- sysnthesis report for stage 5
stage 6 .txt -- sysnthesis report for stage 6
Commands : 
Compile  == > vlog q3.sv 
Synthesis == > dc_shell –f runsynth.tcl  
