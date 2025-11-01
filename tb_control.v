// tb_control.v
// Testbench hoàn ch?nh cho color_control_dualport
// Chuy?n RGB ? Grayscale, ghi ra file .hex
// ?Ã S?A: B?t ?úng th?i ?i?m ghi, không l?ch phase
`timescale 1ns / 1ps

module tb_control;

    // ========================================
    // Tham s? ?nh
    // ========================================
    localparam IMG_WIDTH  = 220;
    localparam IMG_HEIGHT = 220;
    localparam IMG_SIZE   = IMG_WIDTH * IMG_HEIGHT;
    localparam CLK_PERIOD = 10;         // 100 MHz
    localparam ADDR_WIDTH = 16;

    // ========================================
    // Tín hi?u
    // ========================================
    reg  clk, rstn, ready;
    wire finish;
    wire [7:0] out_data;

    integer outfile;
    integer pixel_count;

    // ========================================
    // DUT: color_control_dualport
    // ========================================
    color_control_dualport #(
        .IMG_WIDTH (IMG_WIDTH),
        .IMG_HEIGHT(IMG_HEIGHT)
    ) dut (
        .clk     (clk),
        .rstn    (rstn),
        .ready   (ready),
        .finish  (finish),
        .out_data(out_data)
    );

    // ========================================
    // Clock generation
    // ========================================
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // ========================================
    // Kh?i ??ng & kích ho?t
    // ========================================
    initial begin
        $display("=== B?T ??U MÔ PH?NG RGB ? GRAYSCALE ===");
        $dumpfile("tb_control.vcd");
        $dumpvars(0, tb_control);

        // Kh?i t?o
        rstn = 0; ready = 0; pixel_count = 0;
        #(CLK_PERIOD*20);
        rstn = 1;
        #(CLK_PERIOD*10);

        // M? file ??u ra
        outfile = $fopen("C:/Users/Lenovo/OneDrive/Documents/ an/Colorspace/data/gray_output.hex", "w");
        if (outfile == 0) begin
            $display("L?I: Không m? ???c file gray_output.hex!");
            $finish;
        end

        // Kích ho?t x? lý
        ready = 1; 
        #(CLK_PERIOD); 
        ready = 0;
        $display("[%0t ns] Kích ho?t x? lý (ready pulse)...", $time);

        // Ch? hoàn thành
        @(posedge finish);
        $display("[%0t ns] HOÀN THÀNH! ?ã ghi %0d pixel.", $time, pixel_count);

        // Ki?m tra s? l??ng pixel
        if (pixel_count == IMG_SIZE)
            $display("THÀNH CÔNG: Ghi ?úng %0d pixel (220x220)", IMG_SIZE);
        else
            $display("L?I: Ch? ghi %0d / %0d pixel!", pixel_count, IMG_SIZE);

        $fclose(outfile);
        $display("File l?u t?i: gray_output.hex");
        #(CLK_PERIOD*20);
        $display("=== K?T THÚC MÔ PH?NG ===");
        $finish;
    end

    // ========================================
    // GHI D? LI?U: B?T CHÍNH XÁC TH?I ?I?M GHI
    // ========================================
    reg write_valid;
    reg [7:0] out_data_record;  // D? li?u ???c ghi vào BRAM

    // B?t xung write_en_gray và l?u d? li?u ?úng chu k?
    always @(posedge clk) begin
        if (dut.write_en_gray && rstn) begin
            out_data_record <= out_data;
            write_valid     <= 1;
        end else begin
            write_valid     <= 0;
        end
    end

    // Ghi vào file khi write_valid = 1
    always @(posedge clk) begin
        if (write_valid && rstn) begin
            pixel_count = pixel_count + 1;
            $fwrite(outfile, "%02h\n", out_data_record);

            // In 10 pixel ??u
            if (pixel_count <= 10)
                $display("[%0t ns] Pixel %0d: 0x%02h (%0d)", $time, pixel_count, out_data_record, out_data_record);

            // Báo ti?n ??
            if (pixel_count % 5000 == 0)
                $display("  ? ?ã ghi %0d / %0d pixel (%.2f%%)", 
                         pixel_count, IMG_SIZE, (pixel_count*100.0)/IMG_SIZE);
        end
    end

    // ========================================
    // Timeout b?o v? (1ms)
    // ========================================
    initial begin
        #1_000_000;  // 1ms
        $display("L?I: Timeout sau 1ms! D?ng mô ph?ng.");
        if (outfile) $fclose(outfile);
        $finish;
    end

endmodule