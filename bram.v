// bram.v
`timescale 1ns / 1ps

module bram #(
    parameter RAM_WIDTH       = 24,                    // 24-bit RGB ho?c 8-bit Gray
    parameter RAM_ADDR_BITS   = 16,                    // 2^16 = 65536 > 220*220 = 48400
    parameter INIT_FILE       = "",                    // File .hex ?? kh?i t?o
    parameter INIT_START_ADDR = 0,
    parameter INIT_END_ADDR   = (1 << RAM_ADDR_BITS) - 1
)(
    input  wire                     clock,
    input  wire                     ram_enable,
    input  wire                     write_enable,
    input  wire [RAM_ADDR_BITS-1:0] address,
    input  wire [RAM_WIDTH-1:0]     input_data,
    output reg  [RAM_WIDTH-1:0]     output_data
);

    (* ram_style = "block" *)
    reg [RAM_WIDTH-1:0] memory_array [(1 << RAM_ADDR_BITS)-1:0];

    // Kh?i t?o t? file .hex (n?u có)
    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, memory_array, INIT_START_ADDR, INIT_END_ADDR);
        end
    end

    always @(posedge clock) begin
        if (ram_enable) begin
            if (write_enable)
                memory_array[address] <= input_data;
            output_data <= memory_array[address];  // ??c luôn trong cùng chu k?
        end
    end

endmodule