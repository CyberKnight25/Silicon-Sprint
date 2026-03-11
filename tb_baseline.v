`timescale 1ns/1ps

module tb_baseline;

    // --- Signals ---
    reg clk;
    reg reset;

    reg [7:0] a0,a1,a2,a3;
    reg [7:0] b0,b1,b2,b3;

    wire [15:0] c00,c01,c02,c03;
    wire [15:0] c10,c11,c12,c13;
    wire [15:0] c20,c21,c22,c23;
    wire [15:0] c30,c31,c32,c33;

    // --- Instantiation ---
    systolic_4x4 dut(
        clk, reset,
        a0,a1,a2,a3,
        b0,b1,b2,b3,
        c00,c01,c02,c03,
        c10,c11,c12,c13,
        c20,c21,c22,c23,
        c30,c31,c32,c33
    );

    // --- Clock Generation ---
    always #5 clk = ~clk; // 10ns period -> 100MHz (scale in Genus for 500MHz)

    // --- Test Vector & VCD Generation ---
    initial begin
        // 1. Generate the VCD for Cadence Genus / Joules
        $dumpfile("baseline_activity.vcd");
        $dumpvars(0, tb_baseline);

        // 2. Initialize
        clk = 0;
        reset = 1;
        a0=0; a1=0; a2=0; a3=0;
        b0=0; b1=0; b2=0; b3=0;

        #20 reset = 0;

        // 3. Feed staggered inputs (Wavefront)
        // Matrix A: 
        // [1 0 0 0]
        // [2 5 0 0]
        // [3 6 2 0]
        // [4 7 1 4]
        
        // Matrix B:
        // [1 3 2 0]
        // [0 2 1 1]
        // [0 0 0 2]
        // [0 0 0 1]

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

        // Pad with zeros to flush the pipeline
        @(posedge clk)
        a0<=0; a1<=0; a2<=0; a3<=0;
        b0<=0; b1<=0; b2<=0; b3<=0;

        // Wait for the systolic array to finish propagating
        repeat(15) @(posedge clk);

        // 4. Print the Matrices to Terminal
        $display("\n========================================");
        $display("   SYSTOLIC ARRAY BASELINE TESTBENCH    ");
        $display("========================================");
        
        $display("\n[INPUT MATRIX A]");
        $display("  1   0   0   0");
        $display("  2   5   0   0");
        $display("  3   6   2   0");
        $display("  4   7   1   4");

        $display("\n[INPUT MATRIX B]");
        $display("  1   3   2   0");
        $display("  0   2   1   1");
        $display("  0   0   0   2");
        $display("  0   0   0   1");

        $display("\n[OUTPUT MATRIX C (RESULT)]");
        $display(" %3d %3d %3d %3d", c00, c01, c02, c03);
        $display(" %3d %3d %3d %3d", c10, c11, c12, c13);
        $display(" %3d %3d %3d %3d", c20, c21, c22, c23);
        $display(" %3d %3d %3d %3d", c30, c31, c32, c33);
        
        $display("\n========================================");
        $display("✅ Simulation Complete.");
        $display("📂 VCD File 'baseline_activity.vcd' generated.");
        $display("⚡ Run 'read_vcd baseline_activity.vcd' in Genus to extract Power Consumption.");
        $display("========================================\n");

        $finish;
    end

endmodule