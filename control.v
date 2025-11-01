// control.v
`timescale 1ns / 1ps

module color_control_dualport #(
    parameter IMG_WIDTH  = 220,
    parameter IMG_HEIGHT = 220
)(
    input  wire       clk,
    input  wire       rstn,
    input  wire       ready,          // B?t ??u x? lý
    output reg        finish,         // Hoàn thành
    output wire [7:0] out_data        // D? li?u grayscale (??c t? BRAM gray)
);

    localparam IMG_SIZE = IMG_WIDTH * IMG_HEIGHT;
    localparam ADDR_WIDTH = 16;

    // Tín hi?u t? IAG
    wire [ADDR_WIDTH-1:0] iag_addr;
    wire                  iag_valid;
    wire                  iag_done;

    // Instance IAG
    IAG #(
        .IMG_WIDTH (IMG_WIDTH),
        .IMG_HEIGHT(IMG_HEIGHT)
    ) iag_inst (
        .clk    (clk),
        .rstn   (rstn),
        .start  (ready),
        .addr   (iag_addr),
        .valid  (iag_valid),
        .done   (iag_done)
    );

    // Dùng ??a ch? t? IAG
    wire [ADDR_WIDTH-1:0] addr = iag_addr;
    wire [23:0] rgb_pixel;
    wire [7:0]  gray_pixel;
    reg  write_en_gray;

    // ========================================
    // BRAM RGB (24-bit) - Ch? ??c
    // ========================================
    bram #(
        .RAM_WIDTH(24),
        .RAM_ADDR_BITS(ADDR_WIDTH),
        .INIT_FILE("C:/Users/Lenovo/OneDrive/Documents/ an/Colorspace/data/bram_rgb_init.hex")
    ) bram_rgb_inst (
        .clock        (clk),
        .ram_enable   (1'b1),
        .write_enable (1'b0),
        .address      (addr),
        .input_data   (24'd0),
        .output_data  (rgb_pixel)
    );

    // ========================================
    // BRAM Grayscale (8-bit) - Ghi
    // ========================================
    bram #(
        .RAM_WIDTH(8),
        .RAM_ADDR_BITS(ADDR_WIDTH),
        .INIT_FILE("")  // Không c?n init
    ) bram_gray_inst (
        .clock        (clk),
        .ram_enable   (1'b1),
        .write_enable (write_en_gray),
        .address      (addr),
        .input_data   (gray_pixel),
        .output_data  (out_data)
    );

    // ========================================
    // Module chuy?n RGB ? Grayscale
    // ========================================
    color_converter converter (
        .clk     (clk),
        .rstn    (rstn),
        .rgb_in  (rgb_pixel),
        .gray_out(gray_pixel)
    );

    // ========================================
    // FSM ?i?u khi?n
    // ========================================
    reg [1:0] state;
    localparam IDLE = 2'b00,
               READ = 2'b01,
               WAIT = 2'b10,
               WRITE = 2'b11;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= IDLE;
            finish <= 0;
            write_en_gray <= 0;
        end else begin
            case (state)
                IDLE: begin
                    finish <= 0;
                    write_en_gray <= 0;
                    if (ready) begin
                        state <= READ;
                    end
                end

                READ: begin
                    if (iag_valid)
                        state <= WAIT;
                end

                WAIT: begin
                    state <= WRITE;
                end

                WRITE: begin
                    write_en_gray <= 1;
                    if (iag_done) begin
                        write_en_gray <= 0;
                        finish <= 1;
                        state <= IDLE;
                    end else begin
                        state <= READ;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule