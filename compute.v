// compute.v
`timescale 1ns / 1ps

module color_converter (
    input  wire        clk,
    input  wire        rstn,
    input  wire [23:0] rgb_in,      // [23:16]=R, [15:8]=G, [7:0]=B
    output reg  [7:0]  gray_out
);

    wire [7:0] R = rgb_in[23:16];
    wire [7:0] G = rgb_in[15:8];
    wire [7:0] B = rgb_in[7:0];

    // Tính: Gray = (30*R + 59*G + 11*B + 50) / 100 ? làm tròn g?n ?úng
    wire [15:0] temp = R*30 + G*59 + B*11 + 50;

    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            gray_out <= 8'd0;
        else
            gray_out <= temp / 100;
    end

endmodule