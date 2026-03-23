module pe_optimized (
    input clk,
    input reset,
    input [7:0] a_in,
    input [7:0] b_in,
    output reg [7:0] a_out,
    output reg [7:0] b_out,
    output reg [15:0] acc,
    output skip_flag,
    output reuse_flag
);

    // --- 1. PERFORMANCE MONITOR FLAGS ---
    wire skip_mac = (a_in == 8'd0) || (b_in == 8'd0);
    
    reg [7:0] prev_a, prev_b;
    wire same_operands = (a_in == prev_a) && (b_in == prev_b) && !skip_mac;
    
    assign skip_flag = skip_mac;
    assign reuse_flag = same_operands;

    // --- 2. OPERAND ISOLATION ---
    // Clamps inputs to zero to kill combinational toggling
    wire [7:0] a_iso = skip_mac ? 8'd0 : a_in;
    wire [7:0] b_iso = skip_mac ? 8'd0 : b_in;
    
    reg [15:0] prev_mult;
    wire [15:0] mult_new = a_iso * b_iso;
    wire [15:0] mult = same_operands ? prev_mult : mult_new;

    // --- 3. INTEGRATED CLOCK GATING (ICG) ---
    // Glitch-free latch for the heavy accumulator
    wire enable_mac = !skip_mac;
   

    // --- 4. DATAPATH ---
    // Data forwarding (Runs on main continuous clock)
    always @(posedge clk) begin
        if (reset) begin
            a_out <= 0;
            b_out <= 0;
            prev_a <= 0;
            prev_b <= 0;
            prev_mult <= 0;
        end else begin
            a_out <= a_in;
            b_out <= b_in;
            prev_a <= a_in;
            prev_b <= b_in;
            if (!same_operands && !skip_mac) begin
                prev_mult <= mult_new;
            end
        end
    end

    // Accumulator (Runs on gated clock)
    always @(posedge mac_clk or posedge reset) begin
        if (reset) begin
            acc <= 0;
        end else begin
            acc <= acc + mult;
        end
    end

endmodule
