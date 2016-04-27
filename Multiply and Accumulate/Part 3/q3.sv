module part3_mac(clk, reset, a, b, f);
	input clk, reset;
	input signed [7:0] a, b;
	output logic signed [15:0] f;
	logic signed [7:0] l1, l2;
	logic signed [15:0] pp,out,mul,add;
	//DW02_mult_4_stage #(8,8)  multinstance(l1, l2, 1'b1, clk, mul);
	always_ff @(posedge clk) begin
		if(reset == 1) begin
			l1 <= 0;
			l2 <= 0;
		end
		else begin
			l1 <= a;
			l2 <= b;
		end
	end
	always_ff @(posedge clk) begin
		if (reset ==1 )
			f <=0;
		else
			f<=add;
	end
	always_ff @(posedge clk) begin
		if(reset ==1)
			pp<=0;
		else
			pp<=mul;
	end
	always_comb  begin
		mul = l1 * l2;
		//DW02_mult_2_stage #(8,8)  multinstance(l1, l2, 1'b1, clk, mul);
		add  = pp + f;
	end
		
endmodule

/*module tbench ();
	logic signed [7:0] a,b;
	logic clk, reset;
	logic signed [15:0] f;
	initial clk=0;
	always #5 clk=~clk;

	part3_mac t1(clk, reset, a, b, f);
	initial begin
		$monitor($time,,"r=%b, clk=%b, a=%d, b=%d, f=%d",reset, clk, a, b, f);
		reset =0;
		a=0;
		b=0;
		@(posedge clk);
		#1
		reset = 1;
		@(posedge clk);
		#1
		reset = 0;
		a = 1;
		b = 2;
		@(posedge clk);
		#1
		a = - 3;
		b = 4;
		@(posedge clk);
		#1
		a = 2;
		b = 8;
		#100
	
		$finish;
	end
endmodule
*/

