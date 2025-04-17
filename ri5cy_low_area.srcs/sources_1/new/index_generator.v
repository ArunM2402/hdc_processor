`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2025 15:43:05
// Design Name: 
// Module Name: index_generator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//should add counter
module index_generator
    (input  [31:0] value,
     input  [6:0]  n, //parameterize this
     output [3:0]  level_index //parameterize this
    );
    
    wire [35:0] temp_level_index;
    assign temp_level_index= value * (n-1);
    assign level_index = temp_level_index[35:32];

endmodule
     
