`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2025 17:01:22
// Design Name: 
// Module Name: hdc_top
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


module hdc_top 
# (parameter n = 10,
   parameter threshold = 392
  )
  (
    input clk, 
    input reset,
    input from_decoder_start,
    output [3:0] predicted_class,
    output  SC_done
    );
    
    wire [12:0] feature_vector_pointer; //parameterize this to D/100
    //output [4:0] level_vector_pointer,
    wire [9:0] x_data_pointer;
   
    wire encode_enable;
    wire  binarize_enable;
    wire similarity_check_enable; 
    
    wire [31:0] value;
    wire [99:0] feature_vector;
    wire [99:0] level_vector;
    wire [99:0] class_vector;
    
    wire class_predictor_enable;
    wire [6:0] level_index;
    wire [99:0] sample_hv;
    
//    reg [31:0] value;
//    reg [99:0] feature_vector;
//    reg [99:0] level_vector;
//    reg [99:0] class_vector;
    
    wire [3:0]  hv_pointer;
    wire [3:0]  capture_cv_pointer;
    wire [6:0]  class_vector_pointer;
    wire [3:0]  predicted_class;
    
feature_vector_bram feature_hv_mem (
  .clka(clk),    // input wire clka
  .addra(feature_vector_pointer),  // input wire [12 : 0] addra
  .douta(feature_vector)  // output wire [99 : 0] douta
);

level_vector_bram level_hv_mem (
  .clka(clk),    // input wire clka
  .addra(level_index),  // input wire [5 : 0] addra
  .douta(level_vector)  // output wire [99 : 0] douta
);

x_data_bram x_data_bram_instance (
  .clka(clk),    // input wire clka
  .wea(1'b0),      // input wire [0 : 0] wea
  .addra(x_data_pointer),  // input wire [9 : 0] addra
  .dina(dina),    // input wire [31 : 0] dina
  .douta(value)  // output wire [31 : 0] douta
);

class_vector class_vector_instance (
  .clka(clk),    // input wire clka
  .addra(class_vector_pointer),  // input wire [6 : 0] addra
  .douta(class_vector)  // output wire [99 : 0] douta
);

/*reg [4703:0]  feature_hv_mem [99:0];
reg [59:0]    level_hv_mem   [99:0];
reg [4703:0]  x_vector_mem   [31:0];
reg [59:0]    class_hv_mem   [99:0];*/

/*always @ (posedge clk)
    feature_vector  <= feature_hv_mem[feature_vector_pointer];

always @ (posedge clk)
    level_vector    <= level_hv_mem[level_index];
    
always @ (posedge clk)
    value           <= x_vector_mem[x_data_pointer];    

always @ (posedge clk)
    class_vector    <= class_hv_mem[class_vector_pointer];*/

/*initial begin
    $readmemb ("C:\Users\Priyanka\Desktop\IIIT courses\VLSI System Architecture\project\ri5cy-verilator-model\ricy5\coe_files\mnist_text_files\feature_hvs.txt", feature_hv_mem);
    $readmemb ("C:\Users\Priyanka\Desktop\IIIT courses\VLSI System Architecture\project\ri5cy-verilator-model\ricy5\coe_files\mnist_text_files\level_hvs.txt", level_hv_mem);
    $readmemb ("C:\Users\Priyanka\Desktop\IIIT courses\VLSI System Architecture\project\ri5cy-verilator-model\ricy5\coe_files\mnist_text_files\row_1.txt", x_vector_mem);
    $readmemb ("C:\Users\Priyanka\Desktop\IIIT courses\VLSI System Architecture\project\ri5cy-verilator-model\ricy5\coe_files\mnist\mnist_class_hvs.txt", class_hv_mem);
end*/

hdc_controller   hdc_controller_instance( .clk(clk), .reset(reset), .from_decoder_start(from_decoder_start), .value(value), .hv_pointer(hv_pointer),
                                        .capture_cv_pointer(capture_cv_pointer), .level_index(level_index), .feature_vector_pointer(feature_vector_pointer),
                                        .x_data_pointer(x_data_pointer), .class_vector_pointer(class_vector_pointer), .encode_enable(encode_enable),
                                        .binarize_enable(binarize_enable), .accumulate_enable(accumulate_enable), .similarity_check_enable(similarity_check_enable),
                                        .class_predictor_enable(class_predictor_enable), .SC_done(SC_done), .predicted_class(predicted_class));

//index_generator index_generator_instance(.value(value),.n(n),.level_index(level_index));
encoder    encoder_instance (.clk(clk), .reset(reset), .base_vector(feature_vector), .level_vector(level_vector), .binarize_en(binarize_enable),
                             .encode_en(encode_enable), .accumulate_en(accumulate_enable), .hv_pointer(hv_pointer), .threshold(10'd392), .sample_hv(sample_hv));
                                  
                                  
SimilarityCheck  similarity_check_instance( .clk(clk), .reset(reset), .similarity_check_en(similarity_check_enable), .comp_en(class_predictor_enable),
                                            .sample_hv(sample_hv), .class_hv(class_vector), .class_vector_pointer(class_vector_pointer), .capture_cv_pointer(capture_cv_pointer));                                  
endmodule
