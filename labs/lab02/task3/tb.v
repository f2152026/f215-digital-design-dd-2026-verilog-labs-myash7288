// Self-checking testbench for a 2-bit unsigned magnitude comparator.
module tb;

  reg  [1:0] t_a, t_b;
  wire       t_gt, t_lt, t_eq;
  reg        exp_gt, exp_lt, exp_eq;
  integer    a, b, errors;

  comp2 DUT (
    .A (t_a),
    .B (t_b),
    .GT(t_gt),
    .LT(t_lt),
    .EQ(t_eq)
  );

  // Waveform dump configuration
  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

  initial begin
    errors = 0;
    for (a = 0; a < 4; a = a + 1) begin
      for (b = 0; b < 4; b = b + 1) begin
        t_a = a;
        t_b = b;
        #1;
        exp_gt = (t_a >  t_b);
        exp_lt = (t_a <  t_b);
        exp_eq = (t_a == t_b);
        if ({t_gt, t_lt, t_eq} !== {exp_gt, exp_lt, exp_eq}) begin
          $display("FAIL: A=%0d B=%0d | got GT/LT/EQ=%b%b%b, expected %b%b%b",
                   t_a, t_b, t_gt, t_lt, t_eq, exp_gt, exp_lt, exp_eq);
          errors = errors + 1;
        end
      end
    end

    if (errors == 0)
      $display("PASS: all 16 input pairs matched.");
    else
      $fatal(1, "FAIL: %0d input pairs mismatched.", errors);
    $finish;
  end

  initial
    $monitor($time, " A=%b B=%b | GT=%b LT=%b EQ=%b", t_a, t_b, t_gt, t_lt, t_eq);

endmodule
