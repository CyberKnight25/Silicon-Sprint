module pe (
    input clk,
    input reset,
    input [7:0] a_in,
    input [7:0] b_in,
    output reg [7:0] a_out,
    output reg [7:0] b_out,
    output reg [15:0] acc,
    output wire skip_flag,
    output wire reuse_flag
);

reg [7:0] prev_a;
reg [7:0] prev_b;
reg [15:0] prev_mult;

// -----------------------------
// 1. Operand Isolation
// -----------------------------
wire skip_mac = (a_in == 0 || b_in == 0);
wire same_operands = (a_in == prev_a) && (b_in == prev_b);

assign skip_flag = skip_mac;
assign reuse_flag = same_operands;

// CRITICAL: Clamp inputs to 0 so the multiplier gates stop toggling!
wire [7:0] a_iso = skip_mac ? 8'd0 : a_in;
wire [7:0] b_iso = skip_mac ? 8'd0 : b_in;
wire [15:0] mult_new = a_iso * b_iso;
wire [15:0] mult = same_operands ? prev_mult : mult_new;

// -----------------------------
// 2. Integrated Clock Gating (ICG)
// -----------------------------
// THE FIX: Force enable_mac HIGH if reset is active! 
// This allows the clock edge to reach the registers so they can clear to 0.
wire enable_mac = (!skip_mac) || reset; 
reg cg_latch;

always @(clk or enable_mac) begin
    if (!clk) cg_latch <= enable_mac;
end
wire mac_clk = clk & cg_latch;


// -----------------------------
// 3. Sequential Logic
// -----------------------------

// Domain 1: Continuous Clock (Data forwarding)
always @(posedge clk) begin
    if(reset) begin
        a_out <= 0;
        b_out <= 0;
    end
    else begin
        a_out <= a_in;
        b_out <= b_in;
    end
end

// Domain 2: Gated Clock (Zero sequential power when idle!)
always @(posedge mac_clk) begin // Now uses the gated clock safely
    if(reset) begin
        acc <= 0;
        prev_a <= 0;
        prev_b <= 0;
        prev_mult <= 0;
    end
    else begin
        acc <= acc + mult;
        prev_a <= a_in;
        prev_b <= b_in;
        prev_mult <= mult;
    end
end

endmodule