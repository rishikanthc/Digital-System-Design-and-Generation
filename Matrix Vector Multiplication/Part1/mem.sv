////////////////////////////////////////////////////////////////////////////////
//
//       This code is the implementaition of Part 1 of Project 2.
//     It implements the code for Matrix-Vector Multiplication using MAC
//     The code also includes a comprehensive testbench for evaluation.
//
//
//						****************************
//                    		   (C) RISHIKANTH 
//                           ALL RIGHTS RESERVED
//									;-)
//      				****************************
//    
//
// AUTHOR:    Rishikanth                 Oct. 22, 2015
//
// 
//
// Release: Part 1
// 
//
////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Matrix (3X3)-Vector(3X1) Multiplier - 8 Bit input values
//           A: 3 X 3 Matrix * B: 3 X 1 Matrix => Y: 3 X 1 Matrix
//           Operands A and X are both signed (two's complement).
//	     		clk  	: 	Clock Source
//           	resets  : Reset signal => resets everything to initial values and output to 0
//	         	data_in : 8 Bit input data => first X, then A
//				data_out: 16 Bit Output data
//				done 	:  goes high just before output values are pushed out
// 
// 
//	
//---------------------------------------------------------------------------------


// ----------------TOP LEVEL MODULE------------------------------------------------
module mvm3_part1(clk, reset, start, data_in, data_out, done);
	input clk, reset, start;
	input signed [7:0] data_in;
	output logic signed [15:0] data_out;
	output done;
	reg [3:0] addr_a;
	reg [1:0] addr_x, addr_y;
	logic wr_en_x, wr_en_a, done, wr_en_y;
	always_ff @(posedge clk) begin
	//		always_comb begin
                if (reset ==1 ) 
                    data_out <=0;
    end 
	datapath d(clk, clear_acc, data_in, addr_x, wr_en_x, addr_a, wr_en_a, data_out, addr_y, wr_en_y);
	control c(clk, start, reset, addr_x, wr_en_x, addr_a, wr_en_a, done, clear_acc, addr_y, wr_en_y);
endmodule

//---------------------------CONTROL PATH MODULE------------------------------------------------------
module control(clk, start, reset, addr_x, wr_en_x, addr_a, wr_en_a, done, clear_acc, addr_y, wr_en_y);
	input clk, start, reset;
	output logic [3:0] addr_a;
	output logic [1:0] addr_x, addr_y;
	output logic done, wr_en_x, wr_en_a, clear_acc, wr_en_y;
	logic write_done_x, write_done_a, mac_done, write_done_y, entry, display_done;
	logic [2:0] state, next_state;
	logic [1:0] multiplier, counter;
	logic check;

	always_ff @(posedge clk) begin
		if(reset == 1) begin
			state<=0;
		end
		else 
			state<=next_state;
	end

	always_comb begin
		if (state == 0) begin
			if (start==1)
				next_state = 1;
			else
				next_state=0;
		end
		else if (state ==1 )
			if (write_done_x==1 )
				next_state=2;
			else
				next_state=1;
		else if(state == 2)
			if(write_done_a==1)
				next_state=3;
			else
				next_state=2;
		else if(state == 3)
			if(mac_done==1)
				next_state=4;
			else begin
				next_state=3;
			end
		else if(state==4)
			if(display_done==1)
				next_state=0;
			else
				next_state=4; 
		else
			next_state=0;

	end

	assign wr_en_x = (state==1);
	assign wr_en_a = (state==2);
	assign wr_en_y = (((counter==1)|(mac_done==1))&(state==3));
	assign clear_acc = ((counter==1)|(mac_done==1));
	

	assign write_done_x = ((state==1)&(addr_x==2));
	assign write_done_a = ((state==2)&(addr_a==8));
	assign write_done_y = ((state==3)&(addr_y==2));
	assign display_done = ((state==5)&(addr_y==2)&(entry==1));

	always_ff @(posedge clk) begin
		if(state==0) begin
			addr_x<=0;
			addr_a<=0;
			counter<=0;
			multiplier<=0;
			mac_done<=0;
		end
		else if(state==1) begin
			if(write_done_x==0) begin
				addr_x<=addr_x+1;
			end
			else
				addr_x<=0;
		end
		else if(state ==2) begin
			if(write_done_a==0)
				addr_a<=addr_a+1;
			else begin
				addr_a<=0;
			end
		end
		else if(state==3) begin	
			if(multiplier<=2) begin
				if(counter<3) begin
					addr_x<=counter;
					addr_a<=((3*multiplier)+counter);
					counter<=counter+1;
				end
				else begin
					addr_y<=multiplier;
					multiplier<=multiplier+1;
					counter<=0;
				end
			end
			else begin
				mac_done<=1;
				entry<=0;
			end
		end
		else if((state == 4)) begin
				if(entry==0) begin
						addr_y<=0;
						done<=1;
					end
				if (addr_y<=1) begin
					addr_y<=addr_y+1;
					entry<=1;
					done<=0;
				end

		end

	end

endmodule

//-----------------------------------------DATAPATH MODULE-----------------------------------------------------------
module datapath(clk, clear_acc, data_in, addr_x, wr_en_x, addr_a, wr_en_a, data_out, addr_y, wr_en_y);
	input clk, wr_en_x, wr_en_a, clear_acc, wr_en_y;
	input signed [7:0] data_in;
	input [3:0]  addr_a;
	input [1:0] addr_x, addr_y;
	output logic signed [15:0] data_out;
	logic [15:0] f;
	logic signed [7:0] data_out_x, data_out_a;
	//logic [1:0] addr_x;

	/*always_ff @(posedge clk) begin
	//		always_comb begin
                if (reset ==1 ) 
                    data_out <=0;
    end*/

	memory #(8,3,2) x(clk, data_in, data_out_x, addr_x, wr_en_x);
	memory #(8,9,4) a(clk, data_in, data_out_a, addr_a, wr_en_a);
	mac m(clk, clear_acc, data_out_a, data_out_x, f);
	memory #(16,3,2) y(clk, f, data_out, addr_y, wr_en_y);

endmodule

//---------------MEMORY MODULE---------------------
module memory(clk, data_in, data_out, addr, wr_en);
	parameter WIDTH=8, SIZE=9, LOGSIZE=6; 
	input signed [WIDTH-1:0] data_in;
	output logic signed [WIDTH-1:0] data_out; 
	input [LOGSIZE-1:0] addr;
	input clk, wr_en;
	logic signed [SIZE-1:0][WIDTH-1:0] mem;
	always_ff @(posedge clk) begin 
		data_out <= mem[addr];
		if (wr_en)
			mem[addr] <= data_in; 
	end
endmodule

//---------------MAC---------------------
module mac(clk, clear_acc, a, b, f);
        input clk, clear_acc;
        input signed [7:0] a, b;
        output logic signed [15:0] f;
        logic signed [15:0] out,mul,add;
        
        always_ff @(posedge clk) begin
                if (clear_acc ==1 ) begin
                        f <=0;
                        
                end
                else
                        f<=add;
        end
        always_comb  begin
                mul = b * a;
                add  = mul + f;
        end

endmodule

//---------------COMPREHENSIVE TESTBENCH (BEST)---------------------
module tbench ();
	parameter COUNT=10;
	logic start,reset, clk, done;
	logic signed [7:0] data_in;
	logic signed [15:0] data_out;
	//logic signed[5:0] ad;
	//genvar i,j;
	logic signed [7:0] testData[(COUNT*12)-1:0];
	logic signed [15:0] outputData[(COUNT*3)-1:0];

	//integer filehandle=$fopen("output");
	initial $readmemh("inputData", testData);

	//integer outputfilehandle=$fopen("output");
	initial $readmemh("expectedOutput", outputData);

	mvm3_part1 dut(clk, reset, start, data_in, data_out, done);

	initial clk=0;
	always #5 clk=~clk;

	initial begin
		integer i,j,t;
		bit s,r;
		s=1;
		r=0;
		t=$random%COUNT;
	for (i = 0; i < COUNT; i++) begin
		@(posedge clk);
		start=0;
		reset=1;

		@(posedge clk);
		reset = 0;
		
		if(i==3) begin
			@(posedge clk);
			start=0;
			s=0;
		end
		else begin
			@(posedge clk);
			start=1;
			s=1;
		end

		for(j=(0+(12*i));j<(12+(12*i));j=j+1) begin
			@(posedge clk);
			#1; start=0;
			if(i==1) begin
				reset=1;
				r=1;
			end
			else begin
				r=0;
				reset=0;
			end
			//$display("%d data:%x",j,testData[j]);
			data_in<=testData[j][7:0];
		end

		$display("start was : %d", s);
		$display("reset was : %d", r);
		if(r==0) begin
			if(s==1) begin
				@(posedge done);
     			#1;
    			@(posedge clk);
     			#1; $display("y[0] = %d. Expected value is %d", data_out, outputData[0+(3*i)]);
 	    		@(posedge clk);
      			#1; $display("y[1] = %d. Expected value is %d", data_out, outputData[1+(3*i)]);
      			@(posedge clk);
      			#1; $display("y[2] = %d. Expected value is %d", data_out, outputData[2+(3*i)]);
      		end
      		else if(s==0) begin
      			//$monitor($time,,"start=%b, out=%d, done=%b",start, data_out, done);
      			
      			@(posedge clk);
     			#1; $display("output : %d", data_out);
 	    		@(posedge clk);
      			#1; $display("output : %d", data_out);
      			@(posedge clk);
      			#1; $display("output : %d", data_out);
      		end
		end
		else if(r==1) begin
			//$monitor($time,,"start=%b, out=%d, done=%b",start, data_out, done);
      			
      			@(posedge clk);
     			#1; $display("output : %d", data_out);
 	    		@(posedge clk);
      			#1; $display("output : %d", data_out);
      			@(posedge clk);
      			#1; $display("output : %d", data_out);
		end
		
      	//$finish;
	end
	$finish;
end
endmodule


//---------------BASIC TESTBENCH---------------------
/*module tbench();

logic start,reset, clk, done;
logic signed [7:0] data_in;
logic signed [15:0] data_out;
logic signed[5:0] ad;
integer i,j;


mvm3_part1 dut(clk, reset, start, data_in, data_out, done);

initial clk=0;
always #5 clk = ~clk;

initial begin
	//$monitor($time,,"clk=%b, start=%b, i=%d, out=%d, done=%b",clk, start, ad, data_out, done);
	//$monitor($time,,"i=%d, out=%d, done=%b", ad, data_out, done);
	
	ad=0;
	@(posedge clk);
	start=0;
	reset=1;

	@(posedge clk);
	reset = 0;
	
	@(posedge clk);
	start=1;

	for(i=0;i<13;i=i+1) begin
		@(posedge clk)
		#1; start=0;
		data_in<=ad;
		ad<=ad+1;
		//$monitor($time,,"i=%d",ad);
	//	$monitor($time,"i=%d out=%d",i,data_out);
	end

end

initial begin
      @(posedge done);
      #1;
      @(posedge clk);
      #1; $display("y[0] = %d. Expected value is 14", data_out);
      @(posedge clk);
      #1; $display("y[1] = %d. Expected value is 23", data_out);
      @(posedge clk);
      #1; $display("y[2] = %d. Expected value is 32", data_out);
      $finish;
	$finish;
	
end	

endmodule 
*/

//---------------COMPREHENSIVE TESTBENCH---------------------
/*module tbench ();
	logic start,reset, clk, done;
	logic signed [7:0] data_in;
	logic signed [15:0] data_out;
	//logic signed[5:0] ad;
	integer i,j;
	logic signed [7:0] testData[23:0];
	logic signed [15:0] outputData[5:0];

	//integer filehandle=$fopen("output");
	initial $readmemh("inputData", testData);

	//integer outputfilehandle=$fopen("output");
	initial $readmemh("expectedOutput", outputData);

	mvm3_part1 dut(clk, reset, start, data_in, data_out, done);

	initial clk=0;
	always #5 clk=~clk;

	initial begin
		//$monitor($time,,"clk=%b, start=%b, i=%d, out=%d, done=%b",clk, start, data_in, data_out, done);
		@(posedge clk);
		start=0;
		reset=1;

		@(posedge clk);
		reset = 0;
		
		@(posedge clk);
		start=1;

		for(i=0;i<12;i=i+1) begin
			@(posedge clk);
			#1; start=0;
			$display("%d data:%x",i,testData[i]);
			data_in<=testData[i][7:0];
		end
	end

	initial begin
    	@(posedge done);
     	#1;
    	@(posedge clk);
     	#1; $display("y[0] = %d. Expected value is %d", data_out, outputData[0]);
 	    @(posedge clk);
      	#1; $display("y[1] = %d. Expected value is %d", data_out, outputData[1]);
      	@(posedge clk);
      	#1; $display("y[2] = %d. Expected value is %d", data_out, outputData[2]);
      	//$finish;
		@(posedge clk);
		start=0;
		reset=1;

		@(posedge clk);
		reset = 0;
		
		@(posedge clk);
		start=1;

		for(i=12;i<24;i=i+1) begin
			@(posedge clk);
			#1; start=0;
			$display("%d data:%x",i,testData[i]);
			data_in<=testData[i][7:0];
		end

      	@(posedge done);
     	#1;
    	@(posedge clk);
     	#1; $display("y[0] = %d. Expected value is %d", data_out, outputData[3]);
 	    @(posedge clk);
      	#1; $display("y[1] = %d. Expected value is %d", data_out, outputData[4]);
      	@(posedge clk);
      	#1; $display("y[2] = %d. Expected value is %d", data_out, outputData[5]);
      	$finish;
	end	

/*	initial begin
		//$monitor($time,,"clk=%b, start=%b, i=%d, out=%d, done=%b",clk, start, data_in, data_out, done);
		@(posedge clk);
		start=0;
		reset=1;

		@(posedge clk);
		reset = 0;
		
		@(posedge clk);
		start=1;

		for(i=12;i<22;i=i+1) begin
			@(posedge clk);
			#1; start=0;
			$display("%d data:%x",i,testData[i]);
			data_in<=testData[i][7:0];
		end
	end

	initial begin
    	@(posedge done);
     	#1;
    	@(posedge clk);
     	#1; $display("y[0] = %d. Expected value is %d", data_out, outputData[3]);
 	    @(posedge clk);
      	#1; $display("y[1] = %d. Expected value is %d", data_out, outputData[4]);
      	@(posedge clk);
      	#1; $display("y[2] = %d. Expected value is %d", data_out, outputData[5]);
      	$finish;
	end	*/

//endmodule

