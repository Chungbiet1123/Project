// IAG.v
`timescale 1ns / 1ps

module IAG #(
    parameter IMG_WIDTH  = 220,
    parameter IMG_HEIGHT = 220,
    parameter ADDR_WIDTH = 16
)(
    input  wire                     clk,
    input  wire                     rstn,
    input  wire                     start,    // Kích ho?t sinh ??a ch?
    output reg  [ADDR_WIDTH-1:0]    addr,     // ??a ch? pixel hi?n t?i
    output reg                      valid,    // ??a ch? h?p l?
    output reg                      done      // Hoàn thành toàn b? ?nh
);

    localparam IMG_SIZE = IMG_WIDTH * IMG_HEIGHT;
    localparam ADDR_MAX = IMG_SIZE - 1;

    localparam [1:0] IDLE = 2'b00,
                     RUN  = 2'b01,
                     FIN  = 2'b10;

    reg [1:0] state;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= IDLE;
            addr  <= 0;
            valid <= 0;
            done  <= 0;
        end else begin
            case (state)
                IDLE: begin
                    valid <= 0;
                    done  <= 0;
                    if (start) begin
                        addr  <= 0;
                        valid <= 1;
                        state <= RUN;
                    end
                end

                RUN: begin
                    if (addr == ADDR_MAX) begin
                        valid <= 0;
                        done  <= 1;
                        state <= FIN;
                    end else begin
                        addr  <= addr + 1;
                        valid <= 1;
                    end
                end

                FIN: begin
                    done  <= 1;
                    valid <= 0;
                    state <= IDLE;  // T? ??ng v? IDLE
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule