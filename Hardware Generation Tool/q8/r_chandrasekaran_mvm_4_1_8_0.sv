 parameter K=4;
   parameter logK=3;
   parameter b=8;
module mvm_4_1_8_0(clk, reset, loadMatrix, loadVector, start, done, data_in, data_out);
    parameter K=4;
   parameter logK=3;
   parameter b=8;
   input    clk, reset, start, loadMatrix, loadVector;
   output     done;
   input signed [(b-1):0]   data_in;
   output signed [(2*b-1):0] data_out;   

   logic [logK-1:0] addr_x, addr_y;
   logic wr_en_x, wr_en_a, clear_acc, wr_en_y;
   logic [2*logK-1:0] addr_a;

   // I just parameterized these to make it easier to extend later
   control #(K, logK) ctl(clk, start, reset, loadMatrix, loadVector, addr_x, wr_en_x, addr_a, wr_en_a, clear_acc, addr_y, wr_en_y, done);
   datapath #(K, logK, b) dtpth(clk, addr_x, wr_en_x, data_in, addr_a, wr_en_a, clear_acc, addr_y, wr_en_y, data_out);

endmodule

module control(clk, start, reset, loadMatrix, loadVector, addr_x, wr_en_x, addr_a, wr_en_a, clear_acc, addr_y, wr_en_y, done);
   parameter K=4;
   parameter logK=3;
   
   input clk, start, reset, loadMatrix, loadVector;
   output logic [logK-1:0] addr_x; 
   output logic [2*logK-1:0] addr_a;
   output logic [logK-1:0] addr_y;
   output logic wr_en_x, wr_en_a, wr_en_y, clear_acc, done;

   parameter [2:0] INPUTX_STATE=3'b000, INPUTA_STATE=3'b001,  COMPUTE_STATE=3'b010, OUTPUT_STATE=3'b011, IDLE_STATE=3'b100;

   logic inputa_done, inputx_done, compute_done, output_done;
   logic [2:0] state, next_state;
   logic [2*logK:0] counter;//, multiplier;//, counter2;
   logic [logK:0] counter2; 
   logic [logK:0] multiplier;

   always_comb begin
      case(state)
        INPUTX_STATE: next_state = IDLE_STATE;
        INPUTA_STATE: next_state = IDLE_STATE;
        COMPUTE_STATE: next_state = OUTPUT_STATE;
        OUTPUT_STATE: next_state = IDLE_STATE;
        IDLE_STATE: next_state = IDLE_STATE;
        default: next_state = IDLE_STATE;
      endcase
   end

   always_ff @(posedge clk) begin
      if (reset) begin              //reset state and counter
         state <= IDLE_STATE;
         counter <= 0;
         
      end
      else begin
         if (loadMatrix) begin          //start to set state, counter and wr_en
            state <= INPUTA_STATE;
            counter <= 0;     
         end
         else if(loadVector) begin
            state <= INPUTX_STATE;
            counter <= 0;     
         end
         else if(start) begin
            state <= COMPUTE_STATE;
            counter <= 1;
            counter2 <= 1;
            multiplier <= 0;
         end
         else begin               
            if (inputa_done == 1 || inputx_done == 1 || compute_done == 1 || output_done == 1) begin 
               state <= next_state;
               counter <= 0;
            end
            else begin
               state <= state;
               
            end
            counter <= counter + 1;
            if(counter2 == (K+1)) begin
               counter2 <= 1;
               multiplier <= multiplier + 1;
            end
            else begin
               counter2 <= counter2 + 1;
            end
         end
    
      end 
   end 

   always_comb begin
      case (state)
         INPUTA_STATE: begin
         clear_acc = 1;
           wr_en_y=0;
          addr_y = 0;
           addr_x = 0;
           wr_en_x=0;
             inputx_done = 0;
           done = 0;
           output_done=0;
           compute_done=0;
           wr_en_a=0;
           addr_a=0;
            if (counter < (K*K)) begin
               addr_a = counter;
               wr_en_a = 1;
             
               inputa_done = 0;
            end
            else begin
               addr_a = 0;
               wr_en_a = 0;
               inputa_done = 1;
            end
         end
         INPUTX_STATE: begin
               wr_en_a = 0;
               output_done=0;
               inputa_done = 0;
               addr_a = 0;
               clear_acc = 1;
           wr_en_y=0;
           addr_y = 0;
          done = 0;
           compute_done = 0;
            if(counter < K) begin
               addr_x = counter;
               inputx_done = 0;
               wr_en_x = 1;
          
            end
            else begin
               addr_x = 0;
               wr_en_x = 0;
               inputx_done = 1;
            end
         end

         COMPUTE_STATE: begin
            addr_y = multiplier;
            output_done = 0;
          done=0;
            inputx_done = 0;
            inputa_done = 0;
            wr_en_x=0;
            wr_en_a=0;
            if(counter2==(K)) begin
              addr_x = 0;
              addr_a = addr_a+1;
              compute_done = 0;
            end
            else begin
                if(multiplier<K) begin
                compute_done = 0;
                 if(counter2<K) begin
                    addr_x = counter2;
                    addr_a = ((K*multiplier)+counter2);
                    wr_en_y = 0;
                 end
               else begin
                    addr_x = 0;
                    addr_a = addr_a;
                    wr_en_y = 0;
                end
                addr_x=addr_x+0;
              addr_a = addr_a+0;

              end
              else begin
                 compute_done = 1;
              end
            end
            if(counter2 == (K+1)) begin
               clear_acc = 1;
               wr_en_y = 1;
            end
            else begin
               clear_acc = 0;
               wr_en_y = 0;
            end
         end

         OUTPUT_STATE: begin
           wr_en_a= 0;
           wr_en_x= 0;
           wr_en_y= 0;
           inputx_done = 0;
           inputa_done = 0;
           compute_done = 0;
           clear_acc = 1;
           addr_a = 0;
           addr_x = 0;
           addr_y = counter;
           if (counter==0) done = 1;
           else done = 0;

           if (counter==(K-1)) output_done = 1;
           else output_done = 0;
        end

         IDLE_STATE: begin
           wr_en_a= 0;
           wr_en_x= 0;
           wr_en_y= 0;
           clear_acc = 1;
           addr_a = 0;
           addr_x = 0;
           addr_y = 3;
           done = 0;
           inputx_done = 0;
           inputa_done = 0;
           compute_done = 0;
           output_done = 0;
         end
      
         default : begin
           wr_en_a= 0;
           wr_en_x= 0;
           wr_en_y= 0;
           clear_acc = 1;
           addr_a = 0;
           addr_x = 0;
           addr_y = 3;
           done = 0;
           inputx_done = 0;
           inputa_done = 0;
           compute_done = 0;
           output_done = 0;
         end
      endcase
   end

endmodule

module datapath(clk, addr_x, wr_en_x, data_in, addr_a, wr_en_a, clear_acc, addr_y, wr_en_y, data_out);
  parameter K=4;
   parameter logK=3;
   parameter b=8;
   input clk, wr_en_x, wr_en_a, clear_acc, wr_en_y;
   input [logK-1:0] addr_x, addr_y;
   input [(b-1):0] data_in;
   input [2*logK-1:0] addr_a;
   output [(2*b-1):0] data_out;

   logic signed [(b-1):0] xout, aout;

   memory #(b, K, logK) x(.clk(clk), .data_in(data_in), .addr(addr_x), .wr_en(wr_en_x), .data_out(xout));
   memory #(b, K*K, 2*logK) a(.clk(clk), .data_in(data_in), .addr(addr_a), .wr_en(wr_en_a), .data_out(aout));
   

   logic signed [(2*b-1):0] mul, sum, mac;
   always_comb begin
      mul = xout * aout;
      sum = mul + mac;
   end

   always_ff @(posedge clk) begin
      if(clear_acc) 
         mac <= 0;
      else 
         mac <= sum;
   end

   memory #((2*b), K, logK) y(.clk(clk), .data_in(mac), .addr(addr_y), .wr_en(wr_en_y), .data_out(data_out));
endmodule

module memory(clk, data_in, data_out, addr, wr_en);
   
   parameter WIDTH=16, SIZE=64, LOGSIZE=6;
   input [WIDTH-1:0] data_in;
   output logic [WIDTH-1:0] data_out;
   input [LOGSIZE-1:0]      addr;
   input  clk, wr_en;
   
   logic [SIZE-1:0][WIDTH-1:0] mem;
   
   always_ff @(posedge clk) begin
      data_out <= mem[addr];
      if (wr_en)
   mem[addr] <= data_in;
   end
endmodule

module tbench1 ();
  parameter COUNT=4;
  
   logic signed [b-1:0] data_in;
     logic signed [2*b-1:0] data_out;
  
    logic clk, reset, start, loadMatrix, loadVector;
   
    mvm_4_1_8_0 dut (clk, reset, loadMatrix, loadVector, start, done, data_in, data_out);
  logic signed [b-1:0] xData[(COUNT*K)-1:0];
   logic signed [b-1:0] aData[(COUNT*K*K)-1:0];
  logic signed [2*b-1:0] outputData[(COUNT*K)-1:0];

  //integer filehandle=("output");
  initial $readmemh("aData", aData);
   initial $readmemh("xData", xData);

  //integer outputfilehandle=("output");
  initial $readmemh("expectedOutput", outputData);

  initial clk=0;
  always #5 clk=~clk;

  initial begin
    integer i,j,t;
      

    for (j = 0; j < COUNT; j++) begin
         @(posedge clk);
         start=0;
         reset=1;

         @(posedge clk);
         reset = 0;
   
         @(posedge clk);
         loadMatrix=1;

         for (i = (j*K*K)  ; i <(j*K*K)+(K*K) ; i++) begin //K+(COUNT*K*K)
            @(posedge clk)
            #1; data_in<=aData[i];
            loadMatrix=0;
         end

         /*for(i=0;i<K;i=i+1) begin
           @(posedge clk)
            #1;
         end*/
   
         @(posedge clk);
         loadVector=0;
         @(posedge clk);
         loadVector=1;

         for (i = (j*K); i < (j*K)+K; i++) begin
            @(posedge clk)
            #1; data_in<=xData[i];
            loadVector=0;
         end
         
           @(posedge clk)
            #1;
         
        @(posedge clk);
         start = 1;
         @(posedge clk);
         start = 0; 
        
        $display("for random set:%d",j+1);
        @(posedge done);
         #1;
         for (i = 0; i < K; i++) begin
            @(posedge clk);
            #1; $display("y[%d] = %d. Expected value is %d",i, data_out, outputData[i+(K*j)]);   
         end
         
            
    end
  $finish;
   end
  

endmodule

module tbench2 ();
   parameter COUNT=4;
   
    logic signed [b-1:0] data_in;
    logic signed [2*b-1:0] data_out;
  
      logic clk, reset, start, loadMatrix, loadVector;
   
   mvm_4_1_8_0 dut (clk, reset, loadMatrix, loadVector, start, done, data_in, data_out);
   logic signed [b-1:0] xData[(COUNT*K)-1:0];
   logic signed [b-1:0] aData[(COUNT*K*K)-1:0];
   logic signed [2*b-1:0] outputData[(COUNT*K)-1:0];

   //integer filehandle=("output");
   initial $readmemh("aData", aData);
   initial $readmemh("xData", xData);

   //integer outputfilehandle=("output");
   initial $readmemh("expectedOutput", outputData);

   initial clk=0;
   always #5 clk=~clk;

   initial begin
      integer i,j,t;
      

     for (j = 0; j < COUNT; j++) begin
         @(posedge clk);
         start=0;
         reset=1;

         @(posedge clk);
         reset = 0;
   
         @(posedge clk);
         loadVector=0;
         @(posedge clk);
         loadVector=1;

         for (i = (j*K); i < (j*K)+K; i++) begin
            @(posedge clk)
            #1; data_in<=xData[i];
            loadVector=0;
         end
         
          @(posedge clk)
            #1;
         @(posedge clk);
         loadMatrix=1;

         for (i = (j*K*K)  ; i <(j*K*K)+(K*K) ; i++) begin //K+(COUNT*K*K)
            @(posedge clk)
            #1; data_in<=aData[i];
            loadMatrix=0;
         end
          @(posedge clk)
            #1;

        @(posedge clk);
         start = 1;
         @(posedge clk);
         start = 0; 
         @(posedge clk); 
      @(posedge clk); 
        
        $display("for random set:%d",j+1);
        @(posedge done);
         #1;
         for (i = 0; i < K; i++) begin
            @(posedge clk);
            #1; $display("y[%d] = %d. Expected value is %d",i, data_out, outputData[i+(K*j)]);   
         end
         
            
      end
   $finish;
   end
   

endmodule

module tbench3 ();
   parameter COUNT=4;
   
    logic signed [b-1:0] data_in;
    logic signed [2*b-1:0] data_out;
  
      logic clk, reset, start, loadMatrix, loadVector;
   
   mvm_4_1_8_0 dut (clk, reset, loadMatrix, loadVector, start, done, data_in, data_out);
   logic signed [b-1:0] xData[(COUNT*K)-1:0];
   logic signed [b-1:0] aData[(COUNT*K*K)-1:0];
   logic signed [2*b-1:0] outputData[(COUNT*K)-1:0];

   //integer filehandle=("output");
   initial $readmemh("aData", aData);
   initial $readmemh("xData", xData);

   //integer outputfilehandle=("output");
   initial $readmemh("expectedOutput", outputData);

   initial clk=0;
   always #5 clk=~clk;

   initial begin
      integer i,j,t;
      

     for (j = 0; j < COUNT; j++) begin
         @(posedge clk);
         start=0;
         reset=1;

         @(posedge clk);
         reset = 0;
   
         @(posedge clk);
         loadVector=0;
         @(posedge clk);
         loadVector=1;

         for (i = (j*K); i < (j*K)+K; i++) begin
            @(posedge clk)
            #1; data_in<=xData[i];
            loadVector=0;
         end
         
          @(posedge clk)
            #1;
         @(posedge clk);
         loadMatrix=1;

         for (i = (j*K*K)  ; i <(j*K*K)+(K*K) ; i++) begin //K+(COUNT*K*K)
            @(posedge clk)
            #1; data_in<=aData[i];
            loadMatrix=0;
         end
          @(posedge clk)
            #1;

        @(posedge clk);
         start = 1;
         @(posedge clk);
         start = 0; 

         @(posedge clk)
         @(posedge clk)
         @(posedge clk)

         if(j==1) begin
            @(posedge clk);
            reset = 1;
            @(posedge clk);
            reset = 0; 
            $display("for random set:%d Reset was triggered",j+1);
            for (i = 0; i < K; i++) begin
               @(posedge clk);
               #1; $display("y[%d] = %d. Expected value is %d",i, data_out, outputData[i+(K*j)]);   
            end
         end
         else begin
        
        $display("for random set:%d",j+1);
        @(posedge done);
         #1;
         for (i = 0; i < K; i++) begin
            @(posedge clk);
            #1; $display("y[%d] = %d. Expected value is %d",i, data_out, outputData[i+(K*j)]);   
         end

      end
         
            
      end
   $finish;
   end
   

endmodule


