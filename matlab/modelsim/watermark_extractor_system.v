// Author: Vishwa Narayanan
// Project: FPGA Digital Image Watermarking
// License: MIT


//////////////////////////////////////////////////////////////////////////////////
// Module: watermark_extractor_system
// Description:
// Extracts an embedded watermark from a watermarked image (non-blind scheme).
// FIXED VERSION ? resolves FSM index bug so MATLAB reshape error disappears.
//////////////////////////////////////////////////////////////////////////////////

module watermark_extractor_system (
    clk,
    rst_n,
    start,
    done
);

// ============================================================================
// PARAMETERS
// ============================================================================
parameter HOST_WIDTH        = 256;
parameter HOST_HEIGHT       = 256;
parameter WATERMARK_WIDTH   = 128;
parameter WATERMARK_HEIGHT  = 128;
parameter PIXEL_WIDTH       = 8;
parameter GAIN_FACTOR       = 0.01; // scaling factor 'k'

// ============================================================================
// PORTS
// ============================================================================
input clk;
input rst_n;
input start;
output reg done;

// ============================================================================
// INTERNAL CONSTANTS
// ============================================================================
localparam HOST_SIZE        = HOST_WIDTH * HOST_HEIGHT;
localparam WATERMARK_SIZE   = WATERMARK_WIDTH * WATERMARK_HEIGHT;
localparam ADDR_WIDTH       = clog2(HOST_SIZE);

// FSM STATES
localparam S_IDLE           = 6'd0,  S_READ_INPUTS    = 6'd1,
           S_DWT1_H_W       = 6'd2,  S_DWT1_V_W       = 6'd3,
           S_DWT2_H_W       = 6'd4,  S_DWT2_V_W       = 6'd5,
           S_PREP_HOST_DWT  = 6'd6,
           S_DWT1_H_H       = 6'd7,  S_DWT1_V_H       = 6'd8,
           S_DWT2_H_H       = 6'd9,  S_DWT2_V_H       = 6'd10,
           S_EXTRACT        = 6'd11, S_WRITE_OUTPUT   = 6'd12;

// ============================================================================
// REGISTERS AND MEMORY
// ============================================================================
reg [5:0] current_state, next_state;
reg [ADDR_WIDTH-1:0] row, col, idx;
reg signed [PIXEL_WIDTH+4:0] temp_A, temp_B;
integer addr;

// Memories
reg [PIXEL_WIDTH-1:0] host_image_mem[0:HOST_SIZE-1];
reg [PIXEL_WIDTH-1:0] watermarked_image_mem[0:HOST_SIZE-1];
reg signed [PIXEL_WIDTH+4:0] extracted_watermark_mem[0:WATERMARK_SIZE-1];

// DWT Coefficients
reg signed [PIXEL_WIDTH+4:0] dwt_coeffs_W[0:HOST_SIZE-1];
reg signed [PIXEL_WIDTH+4:0] dwt_coeffs_H[0:HOST_SIZE-1];
reg signed [PIXEL_WIDTH+4:0] temp_mem[0:HOST_SIZE-1];

// ============================================================================
// HELPER FUNCTION
// ============================================================================
function integer clog2;
    input integer value;
    begin
        value = value - 1;
        for (clog2 = 0; value > 0; clog2 = clog2 + 1)
            value = value >> 1;
    end
endfunction

// ============================================================================
// FSM SEQUENTIAL LOGIC
// ============================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        current_state <= S_IDLE;
    else
        current_state <= next_state;
end

// ============================================================================
// DONE SIGNAL LOGIC
// ============================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        done <= 1'b0;
    else if (next_state == S_IDLE && current_state != S_IDLE)
        done <= 1'b1;
    else if (start)
        done <= 1'b0;
end

// ============================================================================
// FIXED COUNTER LOGIC
// ============================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        row <= 0; col <= 0; idx <= 0;
    end 
    else if (next_state != current_state) begin
        // ?? FIX: Reset idx only when changing major states
        if (next_state == S_WRITE_OUTPUT)
            idx <= 0; // reset index before writing output
        else
            idx <= 0;

        row <= 0; 
        col <= 0;
    end 
    else begin
        case (current_state)
            S_READ_INPUTS,
            S_EXTRACT,
            S_WRITE_OUTPUT,
            S_PREP_HOST_DWT:
                idx <= idx + 1;
            default: begin
                col <= col + 1;
                case (current_state)
                    S_DWT1_H_W, S_DWT1_H_H:
                        if (col == (HOST_WIDTH/2)-1)  begin col <= 0; row <= row + 1; end
                    S_DWT1_V_W, S_DWT1_V_H:
                        if (col == HOST_WIDTH-1)      begin col <= 0; row <= row + 1; end
                    S_DWT2_H_W, S_DWT2_H_H:
                        if (col == (HOST_WIDTH/4)-1)  begin col <= 0; row <= row + 1; end
                    S_DWT2_V_W, S_DWT2_V_H:
                        if (col == (HOST_WIDTH/2)-1)  begin col <= 0; row <= row + 1; end
                endcase
            end
        endcase
    end
end

// ============================================================================
// FSM COMBINATIONAL LOGIC
// ============================================================================
always @(*) begin
    next_state = current_state;
    case (current_state)
        S_IDLE:          if (start) next_state = S_READ_INPUTS;
        S_READ_INPUTS:   if (idx == HOST_SIZE-1) next_state = S_DWT1_H_W;

        S_DWT1_H_W:      if (row == HOST_HEIGHT-1 && col == (HOST_WIDTH/2)-1) next_state = S_DWT1_V_W;
        S_DWT1_V_W:      if (row == (HOST_HEIGHT/2)-1 && col == HOST_WIDTH-1) next_state = S_DWT2_H_W;
        S_DWT2_H_W:      if (row == (HOST_HEIGHT/2)-1 && col == (HOST_WIDTH/4)-1) next_state = S_DWT2_V_W;
        S_DWT2_V_W:      if (row == (HOST_HEIGHT/4)-1 && col == (HOST_WIDTH/2)-1) next_state = S_PREP_HOST_DWT;

        S_PREP_HOST_DWT: if (idx == HOST_SIZE-1) next_state = S_DWT1_H_H;
        S_DWT1_H_H:      if (row == HOST_HEIGHT-1 && col == (HOST_WIDTH/2)-1) next_state = S_DWT1_V_H;
        S_DWT1_V_H:      if (row == (HOST_HEIGHT/2)-1 && col == HOST_WIDTH-1) next_state = S_DWT2_H_H;
        S_DWT2_H_H:      if (row == (HOST_HEIGHT/2)-1 && col == (HOST_WIDTH/4)-1) next_state = S_DWT2_V_H;
        S_DWT2_V_H:      if (row == (HOST_HEIGHT/4)-1 && col == (HOST_WIDTH/2)-1) next_state = S_EXTRACT;

        S_EXTRACT:       if (idx == WATERMARK_SIZE-1) next_state = S_WRITE_OUTPUT;
        S_WRITE_OUTPUT:  if (idx == WATERMARK_SIZE-1) next_state = S_IDLE;
    endcase
end

// ============================================================================
// MAIN COMPUTATION
// ============================================================================
always @(posedge clk) begin
    case (current_state)
        S_READ_INPUTS: begin
            dwt_coeffs_W[idx] <= watermarked_image_mem[idx];
        end

        // DWT ? watermarked image
        S_DWT1_H_W: begin
            temp_A = dwt_coeffs_W[row*HOST_WIDTH + col*2] + dwt_coeffs_W[row*HOST_WIDTH + col*2 + 1];
            temp_B = dwt_coeffs_W[row*HOST_WIDTH + col*2] - dwt_coeffs_W[row*HOST_WIDTH + col*2 + 1];
            temp_mem[row*HOST_WIDTH + col] <= temp_A / 2;
            temp_mem[row*HOST_WIDTH + col + (HOST_WIDTH/2)] <= temp_B / 2;
        end
        S_DWT1_V_W: begin
            temp_A = temp_mem[col + (row*2)*HOST_WIDTH] + temp_mem[col + (row*2+1)*HOST_WIDTH];
            temp_B = temp_mem[col + (row*2)*HOST_WIDTH] - temp_mem[col + (row*2+1)*HOST_WIDTH];
            dwt_coeffs_W[col + row*HOST_WIDTH] <= temp_A / 2;
            dwt_coeffs_W[col + (row+(HOST_HEIGHT/2))*HOST_WIDTH] <= temp_B / 2;
        end
        S_DWT2_H_W: begin
            temp_A = dwt_coeffs_W[row*HOST_WIDTH + col*2] + dwt_coeffs_W[row*HOST_WIDTH + col*2 + 1];
            temp_B = dwt_coeffs_W[row*HOST_WIDTH + col*2] - dwt_coeffs_W[row*HOST_WIDTH + col*2 + 1];
            temp_mem[row*HOST_WIDTH + col] <= temp_A / 2;
            temp_mem[row*HOST_WIDTH + col + (HOST_WIDTH/4)] <= temp_B / 2;
        end
        S_DWT2_V_W: begin
            temp_A = temp_mem[col + (row*2)*HOST_WIDTH] + temp_mem[col + (row*2+1)*HOST_WIDTH];
            temp_B = temp_mem[col + (row*2)*HOST_WIDTH] - temp_mem[col + (row*2+1)*HOST_WIDTH];
            dwt_coeffs_W[col + row*HOST_WIDTH] <= temp_A / 2;
            dwt_coeffs_W[col + (row+(HOST_HEIGHT/4))*HOST_WIDTH] <= temp_B / 2;
        end

        // DWT ? host image
        S_PREP_HOST_DWT: begin
            dwt_coeffs_H[idx] <= host_image_mem[idx];
        end
        S_DWT1_H_H: begin
            temp_A = dwt_coeffs_H[row*HOST_WIDTH + col*2] + dwt_coeffs_H[row*HOST_WIDTH + col*2 + 1];
            temp_B = dwt_coeffs_H[row*HOST_WIDTH + col*2] - dwt_coeffs_H[row*HOST_WIDTH + col*2 + 1];
            temp_mem[row*HOST_WIDTH + col] <= temp_A / 2;
            temp_mem[row*HOST_WIDTH + col + (HOST_WIDTH/2)] <= temp_B / 2;
        end
        S_DWT1_V_H: begin
            temp_A = temp_mem[col + (row*2)*HOST_WIDTH] + temp_mem[col + (row*2+1)*HOST_WIDTH];
            temp_B = temp_mem[col + (row*2)*HOST_WIDTH] - temp_mem[col + (row*2+1)*HOST_WIDTH];
            dwt_coeffs_H[col + row*HOST_WIDTH] <= temp_A / 2;
            dwt_coeffs_H[col + (row+(HOST_HEIGHT/2))*HOST_WIDTH] <= temp_B / 2;
        end
        S_DWT2_H_H: begin
            temp_A = dwt_coeffs_H[row*HOST_WIDTH + col*2] + dwt_coeffs_H[row*HOST_WIDTH + col*2 + 1];
            temp_B = dwt_coeffs_H[row*HOST_WIDTH + col*2] - dwt_coeffs_H[row*HOST_WIDTH + col*2 + 1];
            temp_mem[row*HOST_WIDTH + col] <= temp_A / 2;
            temp_mem[row*HOST_WIDTH + col + (HOST_WIDTH/4)] <= temp_B / 2;
        end
        S_DWT2_V_H: begin
            temp_A = temp_mem[col + (row*2)*HOST_WIDTH] + temp_mem[col + (row*2+1)*HOST_WIDTH];
            temp_B = temp_mem[col + (row*2)*HOST_WIDTH] - temp_mem[col + (row*2+1)*HOST_WIDTH];
            dwt_coeffs_H[col + row*HOST_WIDTH] <= temp_A / 2;
            dwt_coeffs_H[col + (row+(HOST_HEIGHT/4))*HOST_WIDTH] <= temp_B / 2;
        end

        // Extraction
        S_EXTRACT: begin
            addr = ((idx / WATERMARK_WIDTH) + (HOST_HEIGHT/4)) * HOST_WIDTH +
                   ((idx % WATERMARK_WIDTH) + (HOST_WIDTH/4));

            extracted_watermark_mem[idx] <= 
                (dwt_coeffs_W[addr] - dwt_coeffs_H[addr]) / GAIN_FACTOR;
        end
    endcase
end

// ============================================================================
// MEMORY INITIALIZATION
// ============================================================================
initial begin
    $readmemh("watermarked_image.mem", watermarked_image_mem);
    $readmemh("host_image.mem", host_image_mem);
end

// ============================================================================
// OUTPUT WRITING
// ============================================================================
integer file;
reg [PIXEL_WIDTH-1:0] data_to_write;
always @(posedge clk) begin
    if (current_state == S_WRITE_OUTPUT) begin
        if (idx == 0)
            file = $fopen("extracted_watermark.mem", "w");

        if (extracted_watermark_mem[idx] > 255)
            data_to_write = 255;
        else if (extracted_watermark_mem[idx] < 0)
            data_to_write = 0;
        else
            data_to_write = extracted_watermark_mem[idx][PIXEL_WIDTH-1:0];

        $fdisplayh(file, data_to_write);

        if (idx == WATERMARK_SIZE - 1)
            $fclose(file);
    end
end

endmodule
