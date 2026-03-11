module pe (
    input clk,
    input reset,
    input [7:0] a_in,
    input [7:0] b_in,
    output reg [7:0] a_out,
    output reg [7:0] b_out,
    output reg [15:0] acc
);

always @(posedge clk) begin
    if(reset) begin
        acc <= 0;
        a_out <= 0;
        b_out <= 0;
    end
    else begin
        acc <= acc + (a_in * b_in);

        // forward data
        a_out <= a_in;
        b_out <= b_in;
    end
end

endmodule