// cla4.v
// Gate-level 4-bit carry-lookahead adder.

module cla4(
    input  [3:0] a,
    input  [3:0] b,
    input        cin,
    output [3:0] sum,
    output       cout
);

    wire p0, p1, p2, p3;
    wire g0, g1, g2, g3;

    wire c1, c2, c3, c4;

    // ---------------------------------------------------------
    // Step 1: Generate / Propagate signals
    // ---------------------------------------------------------

    xor #(2) (p0, a[0], b[0]);
    xor #(2) (p1, a[1], b[1]);
    xor #(2) (p2, a[2], b[2]);
    xor #(2) (p3, a[3], b[3]);

    and #(2) (g0, a[0], b[0]);
    and #(2) (g1, a[1], b[1]);
    and #(2) (g2, a[2], b[2]);
    and #(2) (g3, a[3], b[3]);

    // ---------------------------------------------------------
    // Step 2: Direct carry equations
    // ---------------------------------------------------------

    // c1 = g0 + p0.cin
    wire t10, t20, t21, t30, t31, t32, t40, t41, t42, t43;

    and #(2) (t10, p0, cin);
    or  #(2) (c1, g0, t10);

    // c2 = g1 + p1.g0 + p1.p0.cin
    and #(2) (t20, p1, g0);
    and #(2) (t21, p1, p0, cin);
    or  #(2) (c2, g1, t20, t21);

    // c3 = g2 + p2.g1 + p2.p1.g0 + p2.p1.p0.cin
    and #(2) (t30, p2, g1);
    and #(2) (t31, p2, p1, g0);
    and #(2) (t32, p2, p1, p0, cin);
    or  #(2) (c3, g2, t30, t31, t32);

    // c4 = g3 + p3.g2 + p3.p2.g1
    //      + p3.p2.p1.g0 + p3.p2.p1.p0.cin
    and #(2) (t40, p3, g2);
    and #(2) (t41, p3, p2, g1);
    and #(2) (t42, p3, p2, p1, g0);
    and #(2) (t43, p3, p2, p1, p0, cin);
    or  #(2) (c4, g3, t40, t41, t42, t43);

    // ---------------------------------------------------------
    // Step 3: Sum bits
    // sum[i] = p[i] ^ c[i]
    // ---------------------------------------------------------

    xor #(2) (sum[0], p0, cin);
    xor #(2) (sum[1], p1, c1);
    xor #(2) (sum[2], p2, c2);
    xor #(2) (sum[3], p3, c3);

    // Final carry
    assign cout = c4;

endmodule