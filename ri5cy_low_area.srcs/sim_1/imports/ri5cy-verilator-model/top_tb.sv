`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.03.2025 22:45:45
// Design Name: 
// Module Name: top_tb
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


`timescale 1ns/1ps

module top_tb;

    // Declare the signals
    reg clk_i;
    reg rstn_i;
    reg debug_req_i;
    reg [31:0] debug_addr_i;
    reg debug_we_i;
    reg [31:0] debug_wdata_i;
    wire [31:0] debug_rdata_o;
    wire debug_gnt_o;
    wire debug_rvalid_o;
    reg irq_i;
    reg fetch_enable_i;
    wire  SC_done;
    wire [3:0] hdc_predicted_class;
    // Instantiate the DUT (Device Under Test)
    top uut (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .debug_req_i(debug_req_i),
        .debug_addr_i(debug_addr_i),
        .debug_we_i(debug_we_i),
        .debug_wdata_i(debug_wdata_i),
        .debug_rdata_o(debug_rdata_o),
        .debug_gnt_o(debug_gnt_o),
        .debug_rvalid_o(debug_rvalid_o),
        .irq_i({31'b0, SC_done}),
        .fetch_enable_i(fetch_enable_i),
        .core_busy_o(core_busy_o),
        .hdc_predicted_class(hdc_predicted_class),
        .SC_done(SC_done)
    );

    integer i;

    // Clock generation
    always #5 clk_i = ~clk_i; // Generate a 10ns clock (100MHz)

    // Debug Registers
    localparam DBG_CTRL  = 16'h0000;
    localparam DBG_HIT   = 16'h0004;
    localparam DBG_CAUSE = 16'h000C;
    localparam DBG_NPC   = 16'h2000;
    localparam DBG_PPC   = 16'h2004;
    
    localparam DBG_CTRL_HALT = 32'h00010000;
    localparam DBG_CTRL_SSTE = 32'h00000001;

    // Task to perform debug reads and writes
    task debugAccess;
        input [31:0] addr;
        input [31:0] val;
        input  write_enable;
        begin
            debug_req_i = 1;
            debug_addr_i = addr;
            debug_we_i = write_enable;
            
            if (write_enable) debug_wdata_i = val;

            wait (debug_gnt_o);
            debug_req_i = 0;

            if (!write_enable) begin
                wait (debug_rvalid_o);
                $display("Read from Debug Addr: %h, Data: %h", addr, debug_rdata_o);
            end
        end
    endtask

    // Task to perform single stepping
    task stepSingle;
        begin
            $display("DBG_CTRL  : %h", debug_rdata_o);
            debugAccess(DBG_HIT, 0, 1);   // Clear DBG_HIT
            debugAccess(DBG_CTRL, DBG_CTRL_SSTE, 1); // Set SSTE
        end
    endtask

    // Program Loader

    task loadProgram;
    integer addr;
    begin
        addr = 32'h80; // Program memory start address
        
        /////////////////////////////// Load arithmetic test///////////////////////////
        uut.ram_i.dp_ram_i.mem[addr + 0]  = 8'h2b;  // li a0, 10
        uut.ram_i.dp_ram_i.mem[addr + 1]  = 8'h00;
        uut.ram_i.dp_ram_i.mem[addr + 2]  = 8'h00;
        uut.ram_i.dp_ram_i.mem[addr + 3]  = 8'h00;

//        uut.ram_i.dp_ram_i.mem[addr + 4]  = 8'h93;  // li a1, 5
//        uut.ram_i.dp_ram_i.mem[addr + 5]  = 8'h05;
//        uut.ram_i.dp_ram_i.mem[addr + 6]  = 8'h00;
//        uut.ram_i.dp_ram_i.mem[addr + 7]  = 8'h00;

//        uut.ram_i.dp_ram_i.mem[addr + 8]  = 8'h33;  // add a2, a0, a1
//        uut.ram_i.dp_ram_i.mem[addr + 9]  = 8'h05;
//        uut.ram_i.dp_ram_i.mem[addr + 10] = 8'hb5;
//        uut.ram_i.dp_ram_i.mem[addr + 11] = 8'h00;

//        uut.ram_i.dp_ram_i.mem[addr + 12] = 8'hb3;  // sub a3, a0, a1
//        uut.ram_i.dp_ram_i.mem[addr + 13] = 8'h05;
//        uut.ram_i.dp_ram_i.mem[addr + 14] = 8'hb5;
//        uut.ram_i.dp_ram_i.mem[addr + 15] = 8'h40;

//        uut.ram_i.dp_ram_i.mem[addr + 16] = 8'hb3;  // mul a4, a0, a1
//        uut.ram_i.dp_ram_i.mem[addr + 17] = 8'h06;
//        uut.ram_i.dp_ram_i.mem[addr + 18] = 8'hb5;
//        uut.ram_i.dp_ram_i.mem[addr + 19] = 8'h02;

//        uut.ram_i.dp_ram_i.mem[addr + 20] = 8'hb3;  // div a5, a0, a1
//        uut.ram_i.dp_ram_i.mem[addr + 21] = 8'h06;
//        uut.ram_i.dp_ram_i.mem[addr + 22] = 8'hb5;
//        uut.ram_i.dp_ram_i.mem[addr + 23] = 8'h02;

//        uut.ram_i.dp_ram_i.mem[addr + 24] = 8'h93;  // li a7, 93
//        uut.ram_i.dp_ram_i.mem[addr + 25] = 8'h08;
//        uut.ram_i.dp_ram_i.mem[addr + 26] = 8'hd0;
//        uut.ram_i.dp_ram_i.mem[addr + 27] = 8'h05;

//        uut.ram_i.dp_ram_i.mem[addr + 28] = 8'h73;  // ecall
//        uut.ram_i.dp_ram_i.mem[addr + 29] = 8'h00;
//        uut.ram_i.dp_ram_i.mem[addr + 30] = 8'h00;
//        uut.ram_i.dp_ram_i.mem[addr + 31] = 8'h00;
    end
endtask

/////////Task for memory load and store//////////////////////
/* 
  task loadProgram;
    integer addr;
    begin
        addr = 32'h80; // Program memory start address
        
        // Load immediate values
        uut.ram_i.dp_ram_i.mem[addr + 0]  = 8'h13;  // li a0, 100
        uut.ram_i.dp_ram_i.mem[addr + 1]  = 8'h05;
        uut.ram_i.dp_ram_i.mem[addr + 2]  = 8'h40;
        uut.ram_i.dp_ram_i.mem[addr + 3]  = 8'h06;

        uut.ram_i.dp_ram_i.mem[addr + 4]  = 8'h93;  // li a1, 200
        uut.ram_i.dp_ram_i.mem[addr + 5]  = 8'h05;
        uut.ram_i.dp_ram_i.mem[addr + 6]  = 8'h80;
        uut.ram_i.dp_ram_i.mem[addr + 7]  = 8'h0c;

        uut.ram_i.dp_ram_i.mem[addr + 8]  = 8'h13;  // li a2, 0x80000000
        uut.ram_i.dp_ram_i.mem[addr + 9]  = 8'h05;
        uut.ram_i.dp_ram_i.mem[addr + 10] = 8'h00;
        uut.ram_i.dp_ram_i.mem[addr + 11] = 8'h80;

        // Store values in memory
        uut.ram_i.dp_ram_i.mem[addr + 12] = 8'h23;  // sw a0, 0(a2)
        uut.ram_i.dp_ram_i.mem[addr + 13] = 8'h20;
        uut.ram_i.dp_ram_i.mem[addr + 14] = 8'ha5;
        uut.ram_i.dp_ram_i.mem[addr + 15] = 8'h00;

        uut.ram_i.dp_ram_i.mem[addr + 16] = 8'h23;  // sw a1, 4(a2)
        uut.ram_i.dp_ram_i.mem[addr + 17] = 8'h22;
        uut.ram_i.dp_ram_i.mem[addr + 18] = 8'ha5;
        uut.ram_i.dp_ram_i.mem[addr + 19] = 8'h00;

        // Load values from memory
        uut.ram_i.dp_ram_i.mem[addr + 20] = 8'h03;  // lw a3, 0(a2)
        uut.ram_i.dp_ram_i.mem[addr + 21] = 8'h25;
        uut.ram_i.dp_ram_i.mem[addr + 22] = 8'h05;
        uut.ram_i.dp_ram_i.mem[addr + 23] = 8'h00;

        uut.ram_i.dp_ram_i.mem[addr + 24] = 8'h03;  // lw a4, 4(a2)
        uut.ram_i.dp_ram_i.mem[addr + 25] = 8'h25;
        uut.ram_i.dp_ram_i.mem[addr + 26] = 8'h85;
        uut.ram_i.dp_ram_i.mem[addr + 27] = 8'h04;

        // Exit syscall
        uut.ram_i.dp_ram_i.mem[addr + 28] = 8'h93;  // li a7, 93
        uut.ram_i.dp_ram_i.mem[addr + 29] = 8'h08;
        uut.ram_i.dp_ram_i.mem[addr + 30] = 8'hd0;
        uut.ram_i.dp_ram_i.mem[addr + 31] = 8'h05;

        uut.ram_i.dp_ram_i.mem[addr + 32] = 8'h73;  // ecall
        uut.ram_i.dp_ram_i.mem[addr + 33] = 8'h00;
        uut.ram_i.dp_ram_i.mem[addr + 34] = 8'h00;
        uut.ram_i.dp_ram_i.mem[addr + 35] = 8'h00;
    end
endtask
*/

  
  ///////////////////task for load and store repetitively 20 times------already done////////////////
  
    /*task loadProgram;
        integer addr, repeat_factor;
        begin
            addr = 32'h80;
            repeat_factor = 20;

            for (i = 0; i < repeat_factor; i = i + 1) begin
                uut.ram_i.dp_ram_i.mem[addr + 0] = 8'h93;
                uut.ram_i.dp_ram_i.mem[addr + 1] = 8'h07;
                uut.ram_i.dp_ram_i.mem[addr + 2] = 8'h00;
                uut.ram_i.dp_ram_i.mem[addr + 3] = 8'h04;

                uut.ram_i.dp_ram_i.mem[addr + 4] = 8'h13;
                uut.ram_i.dp_ram_i.mem[addr + 5] = 8'h07;
                uut.ram_i.dp_ram_i.mem[addr + 6] = 8'h60;
                uut.ram_i.dp_ram_i.mem[addr + 7] = 8'h06;

                uut.ram_i.dp_ram_i.mem[addr + 8] = 8'h23;
                uut.ram_i.dp_ram_i.mem[addr + 9] = 8'ha0;
                uut.ram_i.dp_ram_i.mem[addr + 10] = 8'he7;
                uut.ram_i.dp_ram_i.mem[addr + 11] = 8'h00;

                addr = addr + 12;
            end

            uut.ram_i.dp_ram_i.mem[addr + 0] = 8'h93;
            uut.ram_i.dp_ram_i.mem[addr + 1] = 8'h05;
            uut.ram_i.dp_ram_i.mem[addr + 2] = 8'h00;
            uut.ram_i.dp_ram_i.mem[addr + 3] = 8'h00;

            uut.ram_i.dp_ram_i.mem[addr + 4] = 8'h13;
            uut.ram_i.dp_ram_i.mem[addr + 5] = 8'h06;
            uut.ram_i.dp_ram_i.mem[addr + 6] = 8'h00;
            uut.ram_i.dp_ram_i.mem[addr + 7] = 8'h00;

            uut.ram_i.dp_ram_i.mem[addr + 8] = 8'h93;
            uut.ram_i.dp_ram_i.mem[addr + 9] = 8'h06;
            uut.ram_i.dp_ram_i.mem[addr + 10] = 8'h00;
            uut.ram_i.dp_ram_i.mem[addr + 11] = 8'h00;

            uut.ram_i.dp_ram_i.mem[addr + 12] = 8'h93;
            uut.ram_i.dp_ram_i.mem[addr + 13] = 8'h08;
            uut.ram_i.dp_ram_i.mem[addr + 14] = 8'hd0;
            uut.ram_i.dp_ram_i.mem[addr + 15] = 8'h05;

            uut.ram_i.dp_ram_i.mem[addr + 16] = 8'h73;
            uut.ram_i.dp_ram_i.mem[addr + 17] = 8'h00;
            uut.ram_i.dp_ram_i.mem[addr + 18] = 8'h00;
            uut.ram_i.dp_ram_i.mem[addr + 19] = 8'h00;
        end
    endtask*/
    
    integer f1, f2, f3, f4;  // File handle for logging

// Open file at the start of simulation
initial begin
    f1          = $fopen("encoded_hv_log.txt", "w");
    f2          = $fopen("accumulated_hv_log.txt", "w");
    f3          = $fopen("binarized_signal_log.txt", "w");
    f4          = $fopen("hamming_distance_log.txt", "w");
    count1      = 0; 
    count2      = 0;
end

// Log signal changes to file whenever they occur
always @(uut.hdc_unit.encoder_instance.batch_encoded_data) begin
    $fwrite(f1, "address: %d, base_hv_100bits: %h\n, level_hv_100bits: %h\n,encoded_hv_100bits: %h\n",
                 uut.hdc_unit.hdc_controller_instance.feature_vector_pointer,  uut.hdc_unit.encoder_instance.base_vector,
                 uut.hdc_unit.encoder_instance.level_vector, uut.hdc_unit.encoder_instance.batch_encoded_data );
   end

reg  [9:0]   count1, count2;
// Log signal changes to file whenever they occur
//always @(uut.hdc_unit.encoder_instance.accumulate_en) begin
//    count1  = count1+1;
//    $fwrite(f2, "address: %d, encode_hv: %h\n, accumulated_hv: %h\n ",
//                 count1, uut.hdc_unit.encoder_instance.encode_reg, uut.hdc_unit.encoder_instance.accumulate_reg);
//   end

integer i;
always @  (negedge uut.hdc_unit.encoder_instance.accumulate_en) begin
    count1 = count1 + 1;

    // Log the address or count
    $fwrite(f2, "Snapshot: %0d\n", count1);

    // Log encode_reg if needed (assuming single-dimensional)
    $fwrite(f2, "encode_hv, accumulate_reg: \n ");
    for(i = 0; i < 600; i = i + 1) begin
        $fwrite(f2, "%h,%d:\t ", uut.hdc_unit.encoder_instance.encode_reg[i], uut.hdc_unit.encoder_instance.accumulate_reg[i]);
    end
//    $fwrite(f2, "\n");

//    // Log accumulate_reg (2D array)
//    $fwrite(f2, "accumulate_reg: ");
//    for(i = 0; i < 600; i = i + 1) begin
//        $fwrite(f2, "%d ", uut.hdc_unit.encoder_instance.accumulate_reg[i]);
//    end
    $fwrite(f2, "\n\n"); // Blank line for clarity between snapshots
end
   
always @(uut.hdc_unit.encoder_instance.HV_mem) begin
    $fwrite(f3, "address: %d, binarized_hv: %h\n ",
                 count2, uut.hdc_unit.encoder_instance.HV_mem); 
   end

/*always @(uut.hdc_unit.similarity_check_instance.comp_en) begin
    $fwrite(f4, "class_vector: %d, paritial_distance: %h, minimum_distance:%h, predicted_class: %d\n ",
                  uut.hdc_unit.hdc_controller_instance.class_vector_pointer, uut.hdc_unit.similarity_check_instance.partial_distance_reg,
                  uut.hdc_unit.similarity_check_instance.min_distance_reg, uut.hdc_unit.similarity_check_instance.capture_cv_pointer); 
   end*/
   
   
        
    // Main Test Sequence
    initial begin
        // Initialize signals
        clk_i = 0;
        rstn_i = 0;
        debug_req_i = 0;
        debug_we_i = 0;
        debug_wdata_i = 0;
        irq_i = 0;
        fetch_enable_i = 0;

        // Reset sequence
        #100;
        rstn_i = 1;

        // Load program into memory
        loadProgram();

        // Enable fetch
        fetch_enable_i = 1;
        #50;

        // Halt CPU
        debugAccess(DBG_CTRL, debug_rdata_o | DBG_CTRL_HALT, 1);
        #100;

        // Set traps
        debugAccess(16'h0008, 32'hF, 1); // DBG_IE

        // Step execution
        for (i = 0; i < 5; i = i + 1) begin
            stepSingle();
            #20;
        end
         #600000;
         
         $fclose(f1);
         $fclose(f2);
         $fclose(f3);
         $fclose(f4);
        // End simulation
        $finish;
    end

endmodule