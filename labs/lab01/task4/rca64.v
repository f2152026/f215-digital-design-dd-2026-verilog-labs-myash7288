// rca64.v
// 64-bit ripple-carry adder using 64 FA_Gate instances.

module rca64(
    input  [63:0] a,
    input  [63:0] b,
    input         cin,
    output [63:0] sum,
    output        cout
);

    // Carry signals between the 64 full adders.
    // c[0] = external carry-in
    // c[64] = final carry-out
    wire [64:0] c;

    assign c[0] = cin;

    // Instantiate 64 full adders.
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : gen_fa
            FA_Gate FA (
                .a(a[i]),
                .b(b[i]),
                .cin(c[i]),
                .sum(sum[i]),
                .cout(c[i+1])
            );
        end
    endgenerate

    // Final carry-out
    assign cout = c[64];

endmodule