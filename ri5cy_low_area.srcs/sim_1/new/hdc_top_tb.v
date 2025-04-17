`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2025 22:58:20
// Design Name: 
// Module Name: hdc_top_tb
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


module hdc_top_tb;
reg clk;
reg reset;
reg from_decoder_start;
reg [3:0] n;
reg [9:0] threshold;
wire [3:0] predicted_class;

hdc_top hdc_top_instance(.clk(clk), .reset(reset), .from_decoder_start(from_decoder_start), .predicted_class(predicted_class) );

initial
 begin
    clk     = 0;
    reset   = 1;
    n       = 10;
    from_decoder_start = 0;
    threshold = 1;
    #100;
    reset   = 0;
    from_decoder_start = 1;
    #1000000
    $finish;
end

always #5 clk = ~clk;

endmodule
