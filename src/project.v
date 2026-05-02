/*
 * Copyright (c) 2026 Dat Dinh Trong
 * SPDX-License-Identifier: Apache-2.0
 */


module tt_um_bubble_sort (
    input  wire [7:0] ui_in,    // Dedicated inputs (in_data)
    output wire [7:0] uo_out,   // Dedicated outputs (out_data)
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (1=output, 0=input)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    wire [7:0] core_in_data  = ui_in;
    wire       core_start    = uio_in[0];
    wire       core_in_valid  = uio_in[1];
    wire       core_in_last   = uio_in[2];
    wire       core_out_ready = uio_in[3];

    wire [7:0] core_out_data;
    wire       core_in_ready;
    wire       core_out_valid;
    wire       core_out_last;

    assign uio_oe  = 8'b01110000; 

    assign uio_out[4] = core_in_ready;
    assign uio_out[5] = core_out_valid;
    assign uio_out[6] = core_out_last;
    
    assign uio_out[3:0] = 4'b0000;
    assign uio_out[7]   = 1'b0;

    assign uo_out = core_out_data;
---
    bubble_sort #(
        .DATA_WIDTH(8),
        .MAX_SIZE(8)
    ) user_project (
        .clk       (clk),
        .rst_n     (rst_n),
        .start     (core_start),
        .in_valid  (core_in_valid),
        .in_data   (core_in_data),
        .in_last   (core_in_last),
        .in_ready  (core_in_ready),
        .out_valid (core_out_valid),
        .out_data  (core_out_data),
        .out_last  (core_out_last),
        .out_ready (core_out_ready)
    );

    wire _unused = &{ena, uio_in[7:4], 1'b0};

endmodule
