
//////////////////////////////////////////////////////////////////////////////////
//
// Module: testbench
// Description:
// Final version. Uses simpler "connect-by-order" instantiation for the DUT
// to ensure maximum compatibility with older Verilog compilers.
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module testbench;

    // Parameters for the testbench
    parameter CLK_PERIOD  = 10; // 10ns clock period

    // Signals to connect to the DUT, using classic Verilog types
    reg  clk;
    reg  rst_n;
    reg  start;
    wire done; // 'done' is an output from the DUT, so it's a wire

    // Instantiate the Design Under Test (DUT)
    // This uses a simpler syntax (connection by order) that is more robust.
    image_watermarking_system dut (
        clk,
        rst_n,
        start,
        done
    );

    // Clock generator
    always begin
        clk = 1'b0;
        #(CLK_PERIOD / 2);
        clk = 1'b1;
        #(CLK_PERIOD / 2);
    end

    // Main simulation sequence
    initial begin
        $display("Starting simulation...");
        rst_n = 1'b0; // Assert reset
        start = 1'b0;
        repeat (2) @(posedge clk);
        
        rst_n = 1'b1; // De-assert reset
        @(posedge clk);
        
        $display("Applying start signal.");
        start = 1'b1; // Start the process
        @(posedge clk);
        start = 1'b0; // De-assert start
        
        $display("Waiting for done signal...");
        wait (done); // Wait for the DUT to finish
        
        @(posedge clk);
        $display("Watermarking process finished.");

        // The main module automatically writes the file.
        $display("Output image saved to watermarked_image.mem by the DUT.");
        
        $finish;
    end

endmodule
