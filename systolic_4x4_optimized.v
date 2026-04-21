module systolic_4x4_optimized (
    input clk,
    input reset,
    input global_en, // Macro power saver switch to kill the whole array

    input [7:0] a0,a1,a2,a3,
    input [7:0] b0,b1,b2,b3,

    output [15:0] c00,c01,c02,c03,
    output [15:0] c10,c11,c12,c13,
    output [15:0] c20,c21,c22,c23,
    output [15:0] c30,c31,c32,c33,
    
    output reg [31:0] global_skip_count,
    output reg [31:0] global_reuse_count
);

    // --- 1. GLOBAL SLEEP MODE (MASTER CLOCK GATE) ---
    // Safely gates the clock for the entire 16-PE array when the workload is done
    reg global_cg_latch;
    always @(clk or global_en) begin
        if (!clk) global_cg_latch = global_en;
    end
    wire array_clk = clk & global_cg_latch;

    // --- 2. ARRAY WIRING ---
    wire [7:0] a00_01,a01_02,a02_03; wire [7:0] a10_11,a11_12,a12_13;
    wire [7:0] a20_21,a21_22,a22_23; wire [7:0] a30_31,a31_32,a32_33;
    wire [7:0] b00_10,b10_20,b20_30; wire [7:0] b01_11,b11_21,b21_31;
    wire [7:0] b02_12,b12_22,b22_32; wire [7:0] b03_13,b13_23,b23_33;
    
    // Performance Monitor Buses pulling from every PE
    wire [15:0] skips;
    wire [15:0] reuses;

    // --- 3. PE INSTANTIATIONS (Running on array_clk) ---
    // Row 0
    pe_optimized PE00(array_clk,reset,a0,b0,a00_01,b00_10,c00,skips[0],reuses[0]);
    pe_optimized PE01(array_clk,reset,a00_01,b1,a01_02,b01_11,c01,skips[1],reuses[1]);
    pe_optimized PE02(array_clk,reset,a01_02,b2,a02_03,b02_12,c02,skips[2],reuses[2]);
    pe_optimized PE03(array_clk,reset,a02_03,b3,,b03_13,c03,skips[3],reuses[3]);
    
    // Row 1
    pe_optimized PE10(array_clk,reset,a1,b00_10,a10_11,b10_20,c10,skips[4],reuses[4]);
    pe_optimized PE11(array_clk,reset,a10_11,b01_11,a11_12,b11_21,c11,skips[5],reuses[5]);
    pe_optimized PE12(array_clk,reset,a11_12,b02_12,a12_13,b12_22,c12,skips[6],reuses[6]);
    pe_optimized PE13(array_clk,reset,a12_13,b03_13,,b13_23,c13,skips[7],reuses[7]);
    
    // Row 2
    pe_optimized PE20(array_clk,reset,a2,b10_20,a20_21,b20_30,c20,skips[8],reuses[8]);
    pe_optimized PE21(array_clk,reset,a20_21,b11_21,a21_22,b21_31,c21,skips[9],reuses[9]);
    pe_optimized PE22(array_clk,reset,a21_22,b12_22,a22_23,b22_32,c22,skips[10],reuses[10]);
    pe_optimized PE23(array_clk,reset,a22_23,b13_23,,b23_33,c23,skips[11],reuses[11]);
    
    // Row 3
    pe_optimized PE30(array_clk,reset,a3,b20_30,a30_31,,c30,skips[12],reuses[12]);
    pe_optimized PE31(array_clk,reset,a30_31,b21_31,a31_32,,c31,skips[13],reuses[13]);
    pe_optimized PE32(array_clk,reset,a31_32,b22_32,a32_33,,c32,skips[14],reuses[14]);
    pe_optimized PE33(array_clk,reset,a32_33,b23_33,,,c33,skips[15],reuses[15]);

    // --- 4. GLOBAL PERFORMANCE MONITOR LOGIC ---
    integer i;
    reg [4:0] current_skips;
    reg [4:0] current_reuses;
    
    // Combinational Sum of all active flags in the current cycle
    always @(*) begin
        current_skips = 0;
        current_reuses = 0;
        for(i=0; i<16; i=i+1) begin
            current_skips = current_skips + skips[i];
            current_reuses = current_reuses + reuses[i];
        end
    end

    // Sequential Accumulation of total saved operations
    always @(posedge clk) begin
        if (reset) begin
            global_skip_count <= 0;
            global_reuse_count <= 0;
        end else if (global_en) begin
            global_skip_count <= global_skip_count + current_skips;
            global_reuse_count <= global_reuse_count + current_reuses;
        end
    end

endmodule