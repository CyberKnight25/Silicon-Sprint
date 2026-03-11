module systolic_4x4 (
    input clk,
    input reset,

    input [7:0] a0,a1,a2,a3,
    input [7:0] b0,b1,b2,b3,

    output [15:0] c00,c01,c02,c03,
    output [15:0] c10,c11,c12,c13,
    output [15:0] c20,c21,c22,c23,
    output [15:0] c30,c31,c32,c33
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


// -------- Row 0 --------
pe PE00(clk,reset,a0,b0,a00_01,b00_10,c00);
pe PE01(clk,reset,a00_01,b1,a01_02,b01_11,c01);
pe PE02(clk,reset,a01_02,b2,a02_03,b02_12,c02);
pe PE03(clk,reset,a02_03,b3,,b03_13,c03);

// -------- Row 1 --------
pe PE10(clk,reset,a1,b00_10,a10_11,b10_20,c10);
pe PE11(clk,reset,a10_11,b01_11,a11_12,b11_21,c11);
pe PE12(clk,reset,a11_12,b02_12,a12_13,b12_22,c12);
pe PE13(clk,reset,a12_13,b03_13,,b13_23,c13);

// -------- Row 2 --------
pe PE20(clk,reset,a2,b10_20,a20_21,b20_30,c20);
pe PE21(clk,reset,a20_21,b11_21,a21_22,b21_31,c21);
pe PE22(clk,reset,a21_22,b12_22,a22_23,b22_32,c22);
pe PE23(clk,reset,a22_23,b13_23,,b23_33,c23);

// -------- Row 3 --------
pe PE30(clk,reset,a3,b20_30,a30_31,,c30);
pe PE31(clk,reset,a30_31,b21_31,a31_32,,c31);
pe PE32(clk,reset,a31_32,b22_32,a32_33,,c32);
pe PE33(clk,reset,a32_33,b23_33,,,c33);

endmodule