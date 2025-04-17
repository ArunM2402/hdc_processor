module encoder #(D = 600, chunk_size = D/100)
(
    input clk,
    input reset,
    input [99:0] base_vector,
    input [99:0] level_vector,
    input        binarize_en,
    input        encode_en,
    input        accumulate_en,
    input [3:0]  hv_pointer,
    input [9:0]  threshold,
    output[99:0] sample_hv
);
    wire [3:0]      index;
    reg  [9:0]     accumulate_reg[99:0];
    reg  [99:0]     encode_reg;
    wire [99:0]     batch_encoded_data;
    reg  [9:0]      i, j, k, l;
    reg  [99:0]     HV_mem [chunk_size-1:0];
    reg             done;
     
assign batch_encoded_data = (base_vector ^ level_vector);

/*always @ (negedge clk or posedge reset)
    if (reset)
       begin
            for (i = 0; i < 100; i = i + 1)
              accumulate_reg[i] <= 0;
       end
    else if (encode_en)
          for (i = 0; i < 100; i = i + 1)
            accumulate_reg[i] <= batch_encoded_data[i] + accumulate_reg[i]; */
 //           encode_reg <= {batch_encoded_data[99:0]};
//    else
//            encode_reg <= encode_reg;
            
always @ (negedge clk or posedge reset)
      begin
        if (reset)
          begin
            done        <= 0;
            j           <= 0;
            l           <= 0;
            for (i = 0; i < 100; i = i + 1)
              accumulate_reg[i] <= 0;
          end 
        else if (encode_en)
            for (i = 0; i < 100; i = i + 1)
              accumulate_reg[i] <= batch_encoded_data[i] + accumulate_reg[i];  
        else if (binarize_en)
          begin
            if (j < 6) begin
                j   <= (j==5)? 0 : j+1;
                for (k = 0; k < 100; k = k + 1)
                    HV_mem[j][k] <= (accumulate_reg[k] > 512) ? 1'b0 : 1'b1;
              end
           end
          else if (accumulate_en) begin
               for (l = 0; l < 100; l = l + 1)
                    accumulate_reg[l] <= 0;
                j   <= (j>5)? 0 : j;
               end//done    <= 1;
          
      end
      
//always @ (posedge clk)
//  begin
//   if (done)
//    for (j = 0; j < 10; j = j+1)
//       HV_mem[j]  <= hv_reg[(j*100)+99 : (j*100)];
//  end
         
assign sample_hv = HV_mem[hv_pointer];

endmodule  