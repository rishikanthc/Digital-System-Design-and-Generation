module part2_mac(clk, reset, a, b, f);
        input clk, reset;
        input signed [7:0] a, b;
        output logic signed [15:0] f;
        logic signed [7:0] l1, l2;
        logic signed [15:0] out,mul,add;
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
        always_comb  begin
                mul = l1 * l2;
                add  = mul + f;
        end

endmodule

module tbench();
	logic signed [7:0] a,b;
	logic clk, reset;
	logic signed [15:0] f; 
	logic signed [7:0] testData[1999:0]; //  input data array
	integer i;
	integer filehandle=$fopen("output"); // file for writing output
	initial $readmemh("inputData", testData); // read from inputData file
	
	part2_mac t1(clk,reset,a,b,f);
	
	initial clk=0; //set up clock
	always #5 clk=~clk;
	
	always @(posedge clk)
	$fdisplay(filehandle,"%d",f); // automatically log f vlaue at every clock

	initial begin // reset once
	reset=0;
	a=0; b=0;

	@(posedge clk)
	#1 reset=1;

	@(posedge clk)
	#1 reset=0;

	for(i=0;i<1000;i=i+1) begin // test against the test data
		@(posedge clk)
		#1 a=testData[2*i][7:0];
		b=testData[2*i+1][7:0];
	end
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	$fclose(filehandle);
	$finish;
end
endmodule
