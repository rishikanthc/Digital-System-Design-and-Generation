module mvm3_part3(clk, reset, start, data_in, data_out, done);

	input clk, reset, start;
	input signed [7:0] data_in;
	output logic signed [15:0] data_out;
	output done;
	reg [5:0] addr_x0, addr_x1, addr_x2, addr_x3, addr_a0, addr_a1, addr_a2, addr_a3, addr_y;
	logic wr_en_x, wr_en_a, done, wr_en_y;

	datapath d(clk, start, reset, clear_acc, data_in, addr_x0, addr_x1, addr_x2, addr_x3, wr_en_x, addr_a0, addr_a1, addr_a2, addr_a3, wr_en_a, data_out, addr_y, wr_en_y);
	control c(clk, start, reset, addr_x0, addr_x1, addr_x2, addr_x3, wr_en_x, addr_a0, addr_a1, addr_a2, addr_a3, wr_en_a, done, clear_acc, addr_y, wr_en_y);


endmodule

module control(clk, start, reset, addr_x0, addr_x1, addr_x2, addr_x3, wr_en_x, addr_a0, addr_a1, addr_a2, addr_a3, wr_en_a, done, clear_acc, addr_y, wr_en_y);
	input clk, start, reset;
	output logic [5:0] addr_x0, addr_x1, addr_x2, addr_x3, addr_a0, addr_a1, addr_a2, addr_a3, addr_y;
	output logic done, wr_en_x, wr_en_a, clear_acc, wr_en_y;
	logic write_done_x, write_done_a, mac_done, write_done_y, entry, display_done;
	logic [2:0] state, next_state;
	logic [5:0] multiplier, counter0, counter1, counter2, counter3; //change
	logic signed [7:0] counter;

	always_ff @(posedge clk) begin
		if(reset == 1) begin
			state<=0;
		end
		else 
			state<=next_state;
	end

	assign wr_en_x = (state==1);
	assign wr_en_a = (state==2);
	//assign wr_en_y = (((counter==1)|(mac_done==1))&(state==3));

	assign write_done_x = ((state==1)&(addr_x0==3));
	assign write_done_a = ((state==2)&(addr_a0==15));
	assign write_done_y = ((state==3)&(addr_y==3));
	assign display_done = ((state==4)&(addr_y==3)&(entry==1));

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
			if(write_done_a==1) begin
				next_state=3;
			end
			else
				next_state=2;
		else if(state == 3)
			if(mac_done==1) begin
				next_state=4;
			end
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

	always_ff @(posedge clk) begin
		if(state==0) begin
			addr_x0<=0;
			addr_a0<=0;
			counter<=0;
			multiplier<=0;
			mac_done<=0;
			addr_x0	<= 0;
			addr_x1 <= 1;
			addr_x2 <= 2;
			addr_x3 <= 3;
		end
		else if(state==1) begin
			if(write_done_x==0) begin
				addr_x0<=addr_x0+1;
			end
			else
				addr_x0<=0;
		end
		else if(state ==2) begin
			if(write_done_a==0)
				addr_a0<=addr_a0+1;
			else begin
				addr_a0<=0;
			end
			counter0<=0;
			counter1<=1;
			counter2<=2;
			counter3<=3;
			counter<=-2;
		end
		else if(state==3) begin
			
			if(counter0<13) begin
				
				addr_a0 <= counter0;
				addr_a1 <= counter1;  
				addr_a2 <= counter2;
				addr_a3 <= counter3;
				if(counter>=0) begin
					addr_y<=counter;
					wr_en_y<=1;
				end
				counter0<=counter0+4;
				counter1<=counter1+4;
				counter2<=counter2+4;
				counter3<=counter3+4;
				counter<=counter+1;
				//wr_en_y<=1;
			end
			else begin
				counter<=counter+1;
				//addr_y<=counter;
				addr_y<=counter;
				mac_done<=1;
				entry<=0;
				//wr_en_y<=0;
			end
		end
		else if((state == 4)) begin
			

				if(entry==0) begin
					addr_y<=0;
					done<=1;
				end
				if(addr_y<=2) begin
					wr_en_y<=0;
					addr_y<=addr_y+1;
					entry<=1;
					done<=0;
				end
		
		end

	end
endmodule

module datapath(clk, start, reset, clear_acc, data_in, addr_x0, addr_x1, addr_x2, addr_x3, wr_en_x, addr_a0, addr_a1, addr_a2, addr_a3, wr_en_a, data_out, addr_y, wr_en_y);
	input clk, start, reset, wr_en_x, wr_en_a, clear_acc, wr_en_y;
	input signed [7:0] data_in;
	input [5:0] addr_x0, addr_x1, addr_x2, addr_x3, addr_a0, addr_a1, addr_a2, addr_a3,addr_y;
	output logic signed [15:0] data_out;
	reg [15:0] f;
	logic [7:0] data_out_x0, data_out_x1, data_out_x2, data_out_x3, data_out_a0, data_out_a1, data_out_2a, data_out_a3;
	reg [5:0] addr_x;

	//memory #(8,4,6) x(clk, data_in, data_out_x, addr_x, wr_en_x);
	//memory #(8,16,6) a(clk, data_in, data_out_a, addr_a, wr_en_a);
	memory4_out #(8,4,6) x(clk, data_in, data_out_x0, data_out_x1, data_out_x2, data_out_x3, addr_x0, addr_x1, addr_x2, addr_x3, wr_en_x);
	memory4_out #(8,16,6) a(clk, data_in, data_out_a0, data_out_a1, data_out_2a, data_out_a3, addr_a0, addr_a1, addr_a2, addr_a3, wr_en_a);
	matrix m(clk, reset, data_out_a0, data_out_a1, data_out_2a, data_out_a3, data_out_x0, data_out_x1, data_out_x2, data_out_x3, f);
	memory #(16,4,6) y(clk, f, data_out, addr_y, wr_en_y);

endmodule

module  matrix(clk, reset, a, b, c, d, x1, x2, x3, x4, f);
	input clk, reset;
	input signed [7:0] a, b, c, d, x1, x2, x3, x4;
	output logic signed [15:0] f;
	logic signed [7:0] l1, l2, l3, l4;
	logic signed [15:0] out, mul0, mul1, mul2, mul3, add0,add1,add2,t1,t2,t3,t4;
	//always_ff @(posedge clk) begin
	always_comb begin
        mul0 = a * x1;
        mul1 = b * x2;
        mul2 = c * x3;
        mul3 = d * x4;
        //add = mul0 + mul1 + mul2 + mul3;
       
       f = add2;
    end
    always_ff @(posedge clk) begin
    	t1<=mul0;
    	t2<=mul1;
    	t3<=mul2;
    	t4<=mul3;
    end
    //always_ff @(posedge clk)begin 
    always_comb begin	
        add0 = t1+t2;
        add1 = t3+t4;
        add2 = add0 + add1;
    end
   /* always_ff @(posedge clk)begin 
    	add0 = mul0+mul1;
    end
    always_ff @(posedge clk) begin
    	add1 = mul3+mul2;
    end*/
    /*always_ff @(posedge clk) begin
        if (reset ==1 ) begin
            f <=0;
                        
   	    end
        else
            f<=add2;
        end */

endmodule

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

module memory4_out(clk, data_in, data_out0, data_out1, data_out2, data_out3, addr0, addr1, addr2, addr3, wr_en);
	parameter WIDTH=8, SIZE=9, LOGSIZE=6; 
	input signed [WIDTH-1:0] data_in;
	output logic signed [WIDTH-1:0] data_out0, data_out1, data_out2, data_out3; 
	input [LOGSIZE-1:0] addr0, addr1, addr2, addr3;
	input clk, wr_en;
	logic signed [SIZE-1:0][WIDTH-1:0] mem;
	always_ff @(posedge clk) begin 
		data_out0 <= mem[addr0];
		data_out1 <= mem[addr1];
		data_out2 <= mem[addr2];
		data_out3 <= mem[addr3];
		if (wr_en) begin
			mem[addr0] <= data_in; 
		end
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
	logic signed [7:0] testData[(COUNT*20)-1:0];
	logic signed [15:0] outputData[(COUNT*4)-1:0];

	//integer filehandle=$fopen("output");
	initial $readmemh("inputData", testData);

	//integer outputfilehandle=$fopen("output");
	initial $readmemh("expectedOutput", outputData);

	mvm3_part3 dut(clk, reset, start, data_in, data_out, done);

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

		for(j=(0+(20*i));j<(20+(20*i));j=j+1) begin
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
     			#1; $display("y[0] = %d. Expected value is %d", data_out, outputData[0+(4*i)]);
 	    		@(posedge clk);
      			#1; $display("y[1] = %d. Expected value is %d", data_out, outputData[1+(4*i)]);
      			@(posedge clk);
      			#1; $display("y[2] = %d. Expected value is %d", data_out, outputData[2+(4*i)]);
      			@(posedge clk);
      			#1; $display("y[3] = %d. Expected value is %d", data_out, outputData[3+(4*i)]);

      		end
      		else if(s==0) begin
      			//$monitor($time,,"start=%b, out=%d, done=%b",start, data_out, done);
      			
      			@(posedge clk);
     			#1; $display("output : %d", data_out);
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
      			@(posedge clk);
      			#1; $display("output : %d", data_out);
		end
		
      	//$finish;
	end
	$finish;
end
endmodule

/*module tbench();

logic start,reset, clk, done;
logic signed [7:0] data_in;
logic signed [15:0] data_out;
logic signed[5:0] ad;
integer i,j;


mvm3_part3 dut(clk, reset, start, data_in, data_out, done);

initial clk=0;
always #5 clk = ~clk;

initial begin
	$monitor($time,,"clk=%b, i=%d, out=%d, done=%b",clk, ad, data_out, done);
	//$monitor($time,,"i=%d, out=%d, done=%b", ad, data_out, done);
	
	ad=0;
	@(posedge clk);
	start=0;
	reset=1;

	@(posedge clk);
	reset = 0;
	
	@(posedge clk);
	start=1;

	for(i=0;i<20;i=i+1) begin
		@(posedge clk)
		#1; data_in<=ad;
		ad<=ad+1;
		//$monitor($time,,"i=%d",ad);
	//	$monitor($time,"i=%d out=%d",i,data_out);
	end
	
	
end	

	initial begin
      //@(negedge done);
      @(posedge done);
      #1;
      @(posedge clk);
      #1; $display("y[0] = %d. Expected value is 38", data_out);
      @(posedge clk);
      #1; $display("y[1] = %d. Expected value is 62", data_out);
      @(posedge clk);
      #1; $display("y[2] = %d. Expected value is 86", data_out);
      @(posedge clk);
      #1; $display("y[3] = %d. Expected value is 110", data_out);
      @(posedge clk);
      #1; $display("y[3] = %d. Expected value is 110", data_out);
      @(posedge clk);
      #1; $display("y[3] = %d. Expected value is 110", data_out);
      @(posedge clk);
      #1; $display("y[3] = %d. Expected value is 110", data_out);
      $finish;
	//$finish;
	
end	


endmodule


*/

