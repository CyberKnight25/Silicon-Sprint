`timescale 1ns/1ps

module tb_systolic_4x4;

reg clk;
reg reset;

reg [7:0] a0,a1,a2,a3;
reg [7:0] b0,b1,b2,b3;

wire [15:0] c00,c01,c02,c03;
wire [15:0] c10,c11,c12,c13;
wire [15:0] c20,c21,c22,c23;
wire [15:0] c30,c31,c32,c33;


systolic_4x4 dut(
    clk,
    reset,
    a0,a1,a2,a3,
    b0,b1,b2,b3,
    c00,c01,c02,c03,
    c10,c11,c12,c13,
    c20,c21,c22,c23,
    c30,c31,c32,c33
);

always #5 clk = ~clk;

initial begin

    $dumpfile("systolic_baseline.vcd");
    $dumpvars(0, tb_systolic_4x4);

    clk=0;
    reset=1;

    a0=0;a1=0;a2=0;a3=0;
    b0=0;b1=0;b2=0;b3=0;

    #20
    reset=0;

    @(posedge clk)
    a0<=1; a1<=0; a2<=0; a3<=0;
    b0<=1; b1<=0; b2<=0; b3<=0;

    @(posedge clk)
    a0<=2; a1<=5; a2<=0; a3<=0;
    b0<=3; b1<=2; b2<=0; b3<=0;

    @(posedge clk)
    a0<=3; a1<=6; a2<=2; a3<=0;
    b0<=2; b1<=1; b2<=0; b3<=0;

    @(posedge clk)
    a0<=4; a1<=7; a2<=1; a3<=4;
    b0<=0; b1<=1; b2<=2; b3<=1;

    repeat(30) @(posedge clk);

    $finish;
end

endmodule