module SimilarityCheck (
    input  clk,
    input  reset,
    input  similarity_check_en,
    input  comp_en,
    input  [99:0] sample_hv,
    input  [99:0] class_hv,
    input  [6:0]  class_vector_pointer,
    output reg  [3:0] capture_cv_pointer
);

    reg [10:0] partial_distance, partial_distance_reg;
    wire [99:0] xor_result;
    wire [9:0] partial_distance_temp;
    reg [9:0] min_distance_reg;
    reg  [1:0] count;

    // Compute XOR for Hamming distance
    assign xor_result = sample_hv ^ class_hv;

    // Compute partial distance (sum of XOR results)    
             
    assign partial_distance_temp = xor_result[0] + xor_result[1] + xor_result[2] + xor_result[3] + xor_result[4] +
                              xor_result[5] + xor_result[6] + xor_result[7] + xor_result[8] + xor_result[9] +
                              xor_result[10] + xor_result[11] + xor_result[12] + xor_result[13] + xor_result[14] +
                              xor_result[15] + xor_result[16] + xor_result[17] + xor_result[18] + xor_result[19] +
                              xor_result[20] + xor_result[21] + xor_result[22] + xor_result[23] + xor_result[24] +
                              xor_result[25] + xor_result[26] + xor_result[27] + xor_result[28] + xor_result[29] +
                              xor_result[30] + xor_result[31] + xor_result[32] + xor_result[33] + xor_result[34] +
                              xor_result[35] + xor_result[36] + xor_result[37] + xor_result[38] + xor_result[39] +
                              xor_result[40] + xor_result[41] + xor_result[42] + xor_result[43] + xor_result[44] +
                              xor_result[45] + xor_result[46] + xor_result[47] + xor_result[48] + xor_result[49] +
                              xor_result[50] + xor_result[51] + xor_result[52] + xor_result[53] + xor_result[54] +
                              xor_result[55] + xor_result[56] + xor_result[57] + xor_result[58] + xor_result[59] +
                              xor_result[60] + xor_result[61] + xor_result[62] + xor_result[63] + xor_result[64] +
                              xor_result[65] + xor_result[66] + xor_result[67] + xor_result[68] + xor_result[69] +
                              xor_result[70] + xor_result[71] + xor_result[72] + xor_result[73] + xor_result[74] +
                              xor_result[75] + xor_result[76] + xor_result[77] + xor_result[78] + xor_result[79] +
                              xor_result[80] + xor_result[81] + xor_result[82] + xor_result[83] + xor_result[84] +
                              xor_result[85] + xor_result[86] + xor_result[87] + xor_result[88] + xor_result[89] +
                              xor_result[90] + xor_result[91] + xor_result[92] + xor_result[93] + xor_result[94] +
                              xor_result[95] + xor_result[96] + xor_result[97] + xor_result[98] + xor_result[99];

    always @(negedge clk or posedge reset)
    begin
        if (reset) 
            begin
                partial_distance    <= 10'b0;
                capture_cv_pointer  <= 0;
//                cycle_count <= 4'b0;
                min_distance_reg    <= 10'b1111111111; // Initialize to maximum value
            end 
        else if (comp_en) 
            begin
                // Compare distances to find minimum
                partial_distance    <= 0;
                    if (partial_distance < min_distance_reg)
                      begin
                        capture_cv_pointer  <= class_vector_pointer/6; 
                        min_distance_reg    <= partial_distance_reg; 
                        
                      end        
            end
        else if (similarity_check_en)
            partial_distance   <= partial_distance_temp + partial_distance;  
        else
            partial_distance    <= (count == 1)? 0 : partial_distance;
    end
 
   
    always @(posedge clk or posedge reset)
    begin
        if (reset) 
               partial_distance_reg    <= partial_distance;
        else
               partial_distance_reg    <= partial_distance;      
    end
endmodule