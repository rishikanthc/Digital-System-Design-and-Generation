parameter K=8;
parameter B=16;
parameter logK=4;
parameter ADD=4'b0000;

module mvm_8_8_16_1(clk, reset, loadMatrix, loadVector, start, done, data_in, data_out);
   input    clk, reset, start, loadMatrix, loadVector;
   output   logic  done;
   input signed [(B-1):0]   data_in;
   output logic signed [(2*B-1):0] data_out;   

   logic [logK-1:0] addr_x, addr_y;
   logic wr_en_x, clear_acc, wr_en_y;
   logic [K-1:0][logK-1:0] addr_a;
   logic wr_en_a[K-1:0];

   controlpath c (clk, reset, start, loadMatrix, loadVector, wr_en_x, clear_acc, wr_en_y, done, addr_x, addr_y, addr_a, wr_en_a);
   datapath d(clk, wr_en_x, clear_acc, wr_en_y,addr_x, addr_y, addr_a, data_in, wr_en_a, data_out );

endmodule

module controlpath (
   input clk, reset, start, loadMatrix, loadVector, 
   output logic wr_en_x, clear_acc, wr_en_y, done,
   output logic [logK-1:0] addr_x, addr_y,
   output logic [K-1:0][logK-1:0] addr_a,
   output logic wr_en_a[K-1:0] );

   parameter [2:0] INPUTX_STATE=3'b000, INPUTA_STATE=3'b001,  COMPUTE_STATE=3'b010, OUTPUT_STATE=3'b011, IDLE_STATE=3'b100;

   logic [2:0] state, next_state;
   logic [logK-1:0] counter, counter2;
   logic a_done, x_done, compute_done, output_done;

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
      if(reset) begin
         state <= IDLE_STATE;
         counter <= 0;
         counter2 <= 0;
      end
      else begin
         if(loadMatrix) begin
            state <= INPUTA_STATE;
            counter <= 0;
            counter2 <= 0;
         end
         else if(loadVector) begin
            state <= INPUTX_STATE;
            counter <= 0;
            counter2 <= 0;
         end
         else if(start) begin
            state <= COMPUTE_STATE;
            counter <= 0;
            counter2 <= 0;
         end
         else begin
            if(a_done == 1 || x_done == 1 || compute_done == 1) begin
               state <= next_state;
               counter <= 0;
               counter2 <= 0;
            end
            else begin
               state <= state;
            end
            
            if(counter2 < K-1) begin
               //counter <= counter + 1;
               counter2 <= counter2 + 1;
            end
            else begin
               counter <= counter + 1;
               counter2 <= 0;
            end

         end
      end
   end

   

   always_comb begin
      case (state)
         INPUTA_STATE: begin
          clear_acc = 1;
          output_done = 0;
           wr_en_y=0;
          addr_y = 0;
           addr_x = 0;
           wr_en_x=0;
           x_done = 0;
           done = 0;
                 begin
                     integer i;
                     for (i=0; i<K; i=i+1) wr_en_a[i] = 0;
                  end
           compute_done = 0;
           begin
                     integer i;
                     for (i=0; i<K; i=i+1) addr_a[i] = 0;
                  end

            if(counter<K) begin
              a_done = 0;
              wr_en_a[K-1] = 1 ;
               if(counter2<K) begin
                  addr_a[counter] = counter2;
                  wr_en_a[counter] = 1;
               end
               else begin
                  addr_a[counter] = 0;
                  wr_en_a[counter] = 0 ;
                end
               /*else begin
                  wr_en_a[counter] = 0;
                  wr_en_a[counter+1] = 1;
               end*/
               if(counter2==0) begin
                  wr_en_a[counter-1] = 0;
               end
               else
                wr_en_a[counter-1] = 1'bx;
            end
            else begin
               a_done = 1;
               wr_en_a[K-1] = 0;
            end
         end

         INPUTX_STATE: begin
            clear_acc = 1;
            output_done = 0;
           wr_en_y=0;
            begin
                     integer i;
                     for (i=0; i<K; i=i+1) wr_en_a[i] = 0;
                  end
           addr_a = 0;
           addr_y = 0;
           a_done = 0;
           begin
                     integer i;
                     for (i=0; i<K; i=i+1) addr_a[i] = 0;
                  end
           done = 0;
           compute_done = 0;

            if(counter2<K) begin
               addr_x = counter2;
               wr_en_x = 1;
            end
            else begin
               addr_x = 0;
               wr_en_x = 0;
            end
            if(counter) begin
               wr_en_x = 0;
               x_done = 1;
            end
            else begin
               wr_en_x = 1;
               x_done = 0;
            end

         end

         COMPUTE_STATE: begin
         begin
                     integer i;
                     for (i=0; i<K; i=i+1) wr_en_a[i] = 0;
                  end
           wr_en_x=0;
           output_done = 0;
           addr_y = 0;
           a_done = 0;
           x_done = 0;
            //if(counter<K) begin
               if(counter2<K) begin
                  addr_x = counter2;
                  compute_done = 0;

                  //addr_a[K-1:0] = counter2;
                  begin
                     integer i;
                     for (i=0; i<K; i=i+1) addr_a[i] = counter2;
                  end
                  //clear_acc=0;
                  clear_acc=clear_acc;
               end

               /*else begin
                  wr_en_a[counter] = 0;
                  wr_en_a[counter+1] = 1;
               end*/
               /*if(counter2==0) begin
                  wr_en_a[counter-1] = 0;
               end*/
            //end
            else begin
              addr_x=0;
               compute_done = 1;
               begin
                     integer i;
                     for (i=0; i<K; i=i+1) addr_a[i] = 0;
                  end
               //wr_en_a[K-1] = 0;
            end
            if(counter2==2) begin
                  clear_acc = 0;
               end
               else
                  clear_acc = clear_acc;

            if(counter2 == 2 & counter == 1) begin
               wr_en_y=1;
            end
            else begin
               wr_en_y=0;
               
            end

            if(counter2 == 0 & counter==2) begin
               compute_done = 1;
               done=1;
            end
            else begin
               compute_done =0;
               done=0;
            end

            
         end

         OUTPUT_STATE: begin
          clear_acc = 1;
           wr_en_y=0;
           addr_a = 0;
           addr_x = 0;
           a_done = 0;
           x_done = 0;
           wr_en_x=0;
                 begin
                     integer i;
                     for (i=0; i<K; i=i+1) wr_en_a[i] = 0;
                  end
           begin
                     integer i;
                     for (i=0; i<K; i=i+1) addr_a[i] = 0;
                  end
            done = 0;
            compute_done =0;
            if(counter2==0) begin
               addr_y = K-1;
               output_done = 0;
            end
            else //if(counter2<K)
               addr_y = counter2-1;
               output_done = 1;
         end

         IDLE_STATE: begin
           clear_acc = 1;
           wr_en_y=0;
           output_done = 0;
           addr_a = 0;
           addr_x = 0;
           addr_y = 0;
           a_done = 0;
           x_done = 0;
           done = 0;
           compute_done = 0;
           wr_en_x=0;
                 begin
                     integer i;
                     for (i=0; i<K; i=i+1) wr_en_a[i] = 0;
                  end
           begin
                     integer i;
                     for (i=0; i<K; i=i+1) addr_a[i] = 0;
                  end
         end

         default : begin
          addr_y = 0;
           clear_acc = 1;
           wr_en_y=0;
           output_done = 0;
           addr_a = 0;
           addr_x = 0;
           a_done = 0;
           x_done = 0;
           done = 0;
           compute_done = 0;
           wr_en_x=0;
                 begin
                     integer i;
                     for (i=0; i<K; i=i+1) wr_en_a[i] = 0;
                  end
           begin
                     integer i;
                     for (i=0; i<K; i=i+1) addr_a[i] = 0;
                  end
         end
      endcase
   end

endmodule

module datapath(input clk, wr_en_x, clear_acc, wr_en_y,
   input [logK-1:0] addr_x, addr_y,
   input [K-1:0][logK-1:0] addr_a, 
   input signed [B-1:0] data_in, 
   input wr_en_a[K-1:0],
   output logic signed[2*B-1:0]data_out );

   logic [B-1:0] vector_out;
   logic [K-1:0][B-1:0] matrix_out;
   logic [K-1:0][2*B-1:0] mac_out;
   logic [K-1:0][2*B-1:0] mux;

   
   memory #(B, K, logK) matrix [K-1:0] (.clk(clk), .data_in(data_in), .data_out(matrix_out), .addr(addr_a), .wr_en(wr_en_a));
   memory #(B, K, logK) vector (.clk(clk), .data_in(data_in), .data_out(vector_out), .addr(addr_x), .wr_en(wr_en_x));


   mac mac_mod [K-1:0](.clk(clk), .clear_acc(clear_acc), .a(matrix_out), .b(vector_out), .mac_out(mac_out));

   memory #(2*B, 1, logK) y [K-1:0] (.clk(clk), .data_in(mac_out), .data_out(mux), .wr_en(wr_en_y), .addr(ADD) );

   //always_ff @(posedge clk) begin
   always_comb begin
      data_out = mux[addr_y];
   end

endmodule

module mac(input clk, clear_acc, 
   input signed [B-1:0] a, b, 
   output logic signed[2*B-1:0]mac_out );

   logic signed [2*B-1:0] sum, mul, pipeline;

   always_comb begin
      mul = a * b;
      sum = pipeline + mac_out;
   end

   always_ff @(posedge clk) begin
      pipeline <= mul;
   end

   always_ff @(posedge clk) begin
      if(clear_acc)
         mac_out <= 0;
      else
         mac_out <= sum;
   end

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
  
   logic signed [B-1:0] data_in;
     logic signed [2*B-1:0] data_out;
  
    logic clk, reset, start, loadMatrix, loadVector;
   
    mvm_8_8_16_1 dut (clk, reset, loadMatrix, loadVector, start, done, data_in, data_out);
  logic signed [B-1:0] xData[(COUNT*K)-1:0];
   logic signed [B-1:0] aData[(COUNT*K*K)-1:0];
  logic signed [2*B-1:0] outputData[(COUNT*K)-1:0];

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
   
    logic signed [B-1:0] data_in;
    logic signed [2*B-1:0] data_out;
  
      logic clk, reset, start, loadMatrix, loadVector;
   
   mvm_8_8_16_1 dut (clk, reset, loadMatrix, loadVector, start, done, data_in, data_out);
   logic signed [B-1:0] xData[(COUNT*K)-1:0];
   logic signed [B-1:0] aData[(COUNT*K*K)-1:0];
   logic signed [2*B-1:0] outputData[(COUNT*K)-1:0];

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
   
    logic signed [B-1:0] data_in;
    logic signed [2*B-1:0] data_out;
  
      logic clk, reset, start, loadMatrix, loadVector;
   
   mvm_8_8_16_1 dut (clk, reset, loadMatrix, loadVector, start, done, data_in, data_out);
   logic signed [B-1:0] xData[(COUNT*K)-1:0];
   logic signed [B-1:0] aData[(COUNT*K*K)-1:0];
   logic signed [2*B-1:0] outputData[(COUNT*K)-1:0];

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

