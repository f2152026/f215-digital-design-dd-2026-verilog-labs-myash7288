// dut.v
// Wrapper module for the bonus task.
// The hierarchical CLA is selected by default.

module dut(
    input  [63:0] a,
    input  [63:0] b,
    input         cin,
    output [63:0] sum,
    output        cout
);

    // ---------------------------------------------------------
    // Bonus: hierarchical 64-bit carry-lookahead adder
    // ---------------------------------------------------------

    cla64_hier U_IMPL (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );


    // ---------------------------------------------------------
    // For comparison, uncomment ONLY ONE option at a time.
    // The corresponding .v file must also be included.
    // ---------------------------------------------------------

    // 64-bit Ripple Carry Adder
    // rca64 U_IMPL (
    //     .a(a),
    //     .b(b),
    //     .cin(cin),
    //     .sum(sum),
    //     .cout(cout)
    // );


    // 64-bit Flat Carry Lookahead Adder
    // cla64_flat U_IMPL (
    //     .a(a),
    //     .b(b),
    //     .cin(cin),
    //     .sum(sum),
    //     .cout(cout)
    // );


    // 64-bit Blocked Carry Lookahead Adder
    // cla64_blocked U_IMPL (
    //     .a(a),
    //     .b(b),
    //     .cin(cin),
    //     .sum(sum),
    //     .cout(cout)
    // );

endmodule