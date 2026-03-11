module systolic_4x4 (
    input clk,
    input reset,
    input global_en, // FIX 1: Added the master sleep switch to the ports

    input [7:0] a0,a1,a2,a3,
    input [7:0] b0,b1,b2,b3,

    output [15:0] c00,c01,c02,c03,
    output [15:0] c10,c11,c12,c13,
    output [15:0] c20,c21,c22,c23,
    output [15:0] c30,c31,c32,c33,
    
    // Global Performance Counters
    output reg [31:0] global_skip_count,
    output reg [31:0] global_reuse_count
);

// A propagation wires
wire [7:0] a00_01,a01_02,a02_03;
wire [7:0] a10_11,a11_12,a12_13;
wire [7:0] a20_21,a21_22,a22_23;
wire [7:0] a30_31,a31_32,a32_33;

// B propagation wires
wire [7:0] b00_10,b10_20,b20_30;
wire [7:0] b01_11,b11_21,b21_31;
wire [7:0] b02_12,b12_22,b22_32;
wire [7:0] b03_13,b13_23,b23_33;

// Flag wires to catch the signals from all 16 PEs
wire [15:0] skips;
wire [15:0] reuses;

// -----------------------------
// Global Clock Gating (Sleep Mode)
// -----------------------------
reg global_cg_latch;

// Glitch-free master clock gate
always @(clk or global_en) begin
    if (!clk) global_cg_latch <= global_en;
end
wire array_clk = clk & global_cg_latch;


// FIX 2: Swapped 'clk' for 'array_clk' on all 16 PEs

// -------- Row 0 --------
pe PE00(array_clk,reset,a0,b0,a00_01,b00_10,c00, skips[0], reuses[0]);
pe PE01(array_clk,reset,a00_01,b1,a01_02,b01_11,c01, skips[1], reuses[1]);
pe PE02(array_clk,reset,a01_02,b2,a02_03,b02_12,c02, skips[2], reuses[2]);
pe PE03(array_clk,reset,a02_03,b3,,b03_13,c03, skips[3], reuses[3]);

// -------- Row 1 --------
pe PE10(array_clk,reset,a1,b00_10,a10_11,b10_20,c10, skips[4], reuses[4]);
pe PE11(array_clk,reset,a10_11,b01_11,a11_12,b11_21,c11, skips[5], reuses[5]);
pe PE12(array_clk,reset,a11_12,b02_12,a12_13,b12_22,c12, skips[6], reuses[6]);
pe PE13(array_clk,reset,a12_13,b03_13,,b13_23,c13, skips[7], reuses[7]);

// -------- Row 2 --------
pe PE20(array_clk,reset,a2,b10_20,a20_21,b20_30,c20, skips[8], reuses[8]);
pe PE21(array_clk,reset,a20_21,b11_21,a21_22,b21_31,c21, skips[9], reuses[9]);
pe PE22(array_clk,reset,a21_22,b12_22,a22_23,b22_32,c22, skips[10], reuses[10]);
pe PE23(array_clk,reset,a22_23,b13_23,,b23_33,c23, skips[11], reuses[11]);

// -------- Row 3 --------
pe PE30(array_clk,reset,a3,b20_30,a30_31,,c30, skips[12], reuses[12]);
pe PE31(array_clk,reset,a30_31,b21_31,a31_32,,c31, skips[13], reuses[13]);
pe PE32(array_clk,reset,a31_32,b22_32,a32_33,,c32, skips[14], reuses[14]);
pe PE33(array_clk,reset,a32_33,b23_33,,,c33, skips[15], reuses[15]);


// -----------------------------
// Global Performance Monitor
// -----------------------------
integer i;
reg [4:0] current_skips;
reg [4:0] current_reuses;

always @(*) begin
    current_skips = 0;
    current_reuses = 0;
    for (i = 0; i < 16; i = i + 1) begin
        current_skips = current_skips + skips[i];
        current_reuses = current_reuses + reuses[i];
    end
end

always @(posedge clk) begin
    if (reset) begin
        global_skip_count <= 0;
        global_reuse_count <= 0;
    end else begin
        global_skip_count <= global_skip_count + current_skips;
        global_reuse_count <= global_reuse_count + current_reuses;
    end
end

endmodule