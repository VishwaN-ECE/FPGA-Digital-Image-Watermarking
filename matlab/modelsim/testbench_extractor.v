//////////////////////////////////////////////////////////////////////////////////
//
// Module: testbench_extractor
// Description:
// Testbench for the watermark_extractor_system module. It provides clock,
// reset, and a start signal, then waits for the 'done' signal to finish.
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module testbench_extractor;

    // Parameters for the testbench
    parameter CLK_PERIOD  = 10; // 10ns clock period

    // Signals to connect to the DUT
    reg  clk;
    reg  rst_n;
    reg  start;
    wire done;

    // Instantiate the Design Under Test (DUT)
    watermark_extractor_system dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .done(done)
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
        $display("Starting watermark EXTRACTION simulation...");
        rst_n = 1'b0; // Assert reset
        start = 1'b0;
        repeat (2) @(posedge clk);
        rst_n = 1'b1; // De-assert reset
        @(posedge clk);
        
        $display("Applying start signal to extractor.");
        start = 1'b1; // Start the process
        @(posedge clk);
        start = 1'b0; // De-assert start
        
        $display("Waiting for extraction 'done' signal...");
        wait (done); // Wait for the DUT to finish
        
        @(posedge clk);
        $display("Watermark extraction process finished.");

        $display("Output watermark saved to extracted_watermark.mem by the DUT.");
        
        $finish;
    end

endmodule