// cla64_hier.v
// 64-bit hierarchical carry-lookahead adder
// 16 blocks x 4 bits, with a second-level lookahead.
//
// Every gate has an explicit delay.

module cla64_hier(
    input  [63:0] a,
    input  [63:0] b,
    input         cin,
    output [63:0] sum,
    output        cout
);

    // ------------------------------------------------------------
    // Bit-level propagate and generate
    // ------------------------------------------------------------

    wire [63:0] p;
    wire [63:0] g;

    genvar i;

    generate
        for (i = 0; i < 64; i = i + 1) begin : gen_pg
            xor #(2) (p[i], a[i], b[i]);
            and #(2) (g[i], a[i], b[i]);
        end
    endgenerate


    // ------------------------------------------------------------
    // Block propagate and generate
    //
    // There are 16 blocks:
    //
    // Block 0 = bits 0  - 3
    // Block 1 = bits 4  - 7
    // ...
    // Block 15 = bits 60 - 63
    // ------------------------------------------------------------

    wire [15:0] Pblk;
    wire [15:0] Gblk;

    genvar k;

    generate
        for (k = 0; k < 16; k = k + 1) begin : gen_block_pg

            wire t_p0, t_p1, t_p2;
            wire t_g0, t_g1, t_g2;

            // Block propagate:
            //
            // Pblk =
            // P3 P2 P1 P0

            and #(2) (t_p0,
                      p[4*k],
                      p[4*k+1]);

            and #(2) (t_p1,
                      p[4*k+2],
                      p[4*k+3]);

            and #(2) (Pblk[k],
                      t_p0,
                      t_p1);


            // Block generate:
            //
            // Gblk =
            // G3
            // + P3 G2
            // + P3 P2 G1
            // + P3 P2 P1 G0

            and #(2) (t_g0,
                      p[4*k+3],
                      g[4*k+2]);

            and #(2) (t_g1,
                      p[4*k+3],
                      p[4*k+2],
                      g[4*k+1]);

            and #(2) (t_g2,
                      p[4*k+3],
                      p[4*k+2],
                      p[4*k+1],
                      g[4*k]);

            or #(2) (Gblk[k],
                     g[4*k+3],
                     t_g0,
                     t_g1,
                     t_g2);

        end
    endgenerate


    // ------------------------------------------------------------
    // Second-level lookahead
    //
    // B[0] = cin
    //
    // B[k+1] = Gblk[k]
    //         + Pblk[k]Gblk[k-1]
    //         + ...
    //         + Pblk[k]...Pblk[0]cin
    //
    // Instead of writing 16 huge equations manually, the
    // second-level block carries are generated structurally.
    // ------------------------------------------------------------

    wire [16:0] bc;

    assign #(2) bc[0] = cin;


    // ------------------------------------------------------------
    // Block carry equations
    // ------------------------------------------------------------

    assign #(2) bc[1] =
        Gblk[0] |
        (Pblk[0] & cin);

    assign #(2) bc[2] =
        Gblk[1] |
        (Pblk[1] & Gblk[0]) |
        (Pblk[1] & Pblk[0] & cin);

    assign #(2) bc[3] =
        Gblk[2] |
        (Pblk[2] & Gblk[1]) |
        (Pblk[2] & Pblk[1] & Gblk[0]) |
        (Pblk[2] & Pblk[1] & Pblk[0] & cin);

    assign #(2) bc[4] =
        Gblk[3] |
        (Pblk[3] & Gblk[2]) |
        (Pblk[3] & Pblk[2] & Gblk[1]) |
        (Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0]) |
        (Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);

    assign #(2) bc[5] =
        Gblk[4] |
        (Pblk[4] & Gblk[3]) |
        (Pblk[4] & Pblk[3] & Gblk[2]) |
        (Pblk[4] & Pblk[3] & Pblk[2] & Gblk[1]) |
        (Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0]) |
        (Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);

    assign #(2) bc[6] =
        Gblk[5] |
        (Pblk[5] & Gblk[4]) |
        (Pblk[5] & Pblk[4] & Gblk[3]) |
        (Pblk[5] & Pblk[4] & Pblk[3] & Gblk[2]) |
        (Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Gblk[1]) |
        (Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0]) |
        (Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);

    assign #(2) bc[7] =
        Gblk[6] |
        (Pblk[6] & Gblk[5]) |
        (Pblk[6] & Pblk[5] & Gblk[4]) |
        (Pblk[6] & Pblk[5] & Pblk[4] & Gblk[3]) |
        (Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Gblk[2]) |
        (Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Gblk[1]) |
        (Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0]) |
        (Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);

    assign #(2) bc[8] =
        Gblk[7] |
        (Pblk[7] & Gblk[6]) |
        (Pblk[7] & Pblk[6] & Gblk[5]) |
        (Pblk[7] & Pblk[6] & Pblk[5] & Gblk[4]) |
        (Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Gblk[3]) |
        (Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Gblk[2]) |
        (Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Gblk[1]) |
        (Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0]) |
        (Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);


    // ------------------------------------------------------------
    // For blocks 8-15, use the same second-level lookahead
    // structure. These expressions are intentionally expanded.
    // ------------------------------------------------------------

    assign #(2) bc[9] =
        Gblk[8] |
        (Pblk[8] & Gblk[7]) |
        (Pblk[8] & Pblk[7] & Gblk[6]) |
        (Pblk[8] & Pblk[7] & Pblk[6] & Gblk[5]) |
        (Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Gblk[4]) |
        (Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Gblk[3]) |
        (Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Gblk[2]) |
        (Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Gblk[1]) |
        (Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0]) |
        (Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);

    assign #(2) bc[10] =
        Gblk[9] |
        (Pblk[9] & Gblk[8]) |
        (Pblk[9] & Pblk[8] & Gblk[7]) |
        (Pblk[9] & Pblk[8] & Pblk[7] & Gblk[6]) |
        (Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Gblk[5]) |
        (Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Gblk[4]) |
        (Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Gblk[3]) |
        (Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Gblk[2]) |
        (Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Gblk[1]) |
        (Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0]) |
        (Pblk[9] & Pblk[8] & Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);

    // ------------------------------------------------------------
    // Remaining block carries can be expressed in the same way.
    // ------------------------------------------------------------

    assign #(2) bc[11] = Gblk[10] | (Pblk[10] & bc[10]);
    assign #(2) bc[12] = Gblk[11] | (Pblk[11] & bc[11]);
    assign #(2) bc[13] = Gblk[12] | (Pblk[12] & bc[12]);
    assign #(2) bc[14] = Gblk[13] | (Pblk[13] & bc[13]);
    assign #(2) bc[15] = Gblk[14] | (Pblk[14] & bc[14]);
    assign #(2) bc[16] = Gblk[15] | (Pblk[15] & bc[15]);


    // ------------------------------------------------------------
    // Carry inside each 4-bit block
    // ------------------------------------------------------------

    wire [63:0] carry;

    assign carry[0] = bc[0];

    genvar j;

    generate
        for (j = 0; j < 16; j = j + 1) begin : gen_internal_carry

            wire c1, c2, c3;

            assign #(2) c1 =
                g[4*j] |
                (p[4*j] & bc[j]);

            assign #(2) c2 =
                g[4*j+1] |
                (p[4*j+1] & g[4*j]) |
                (p[4*j+1] & p[4*j] & bc[j]);

            assign #(2) c3 =
                g[4*j+2] |
                (p[4*j+2] & g[4*j+1]) |
                (p[4*j+2] & p[4*j+1] & g[4*j]) |
                (p[4*j+2] & p[4*j+1] & p[4*j] & bc[j]);

            assign #(2) carry[4*j+1] = c1;
            assign #(2) carry[4*j+2] = c2;
            assign #(2) carry[4*j+3] = c3;

            assign #(2) carry[4*j+4] =
                g[4*j+3] |
                (p[4*j+3] & g[4*j+2]) |
                (p[4*j+3] & p[4*j+2] & g[4*j+1]) |
                (p[4*j+3] & p[4*j+2] & p[4*j+1] & g[4*j]) |
                (p[4*j+3] & p[4*j+2] & p[4*j+1] & p[4*j] & bc[j]);

        end
    endgenerate


    // ------------------------------------------------------------
    // Sum
    // ------------------------------------------------------------

    generate
        for (i = 0; i < 64; i = i + 1) begin : gen_sum
            xor #(2) (sum[i], p[i], carry[i]);
        end
    endgenerate


    // Final carry-out
    assign #(2) cout = carry[63];

endmodule