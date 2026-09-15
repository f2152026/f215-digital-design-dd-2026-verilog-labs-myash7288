// Self-checking testbench for the 4-bit ALU.
module tb;

  reg  [3:0] t_a, t_b;
  reg        t_op;
  wire [3:0] t_result;
  integer    a, b, op, errors;

  alu DUT (
    .a     (t_a),
    .b     (t_b),
    .op    (t_op),
    .result(t_result)
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
    // Change only op: this catches a missing op sensitivity.
    t_a = 4'd5; t_b = 4'd3; t_op = 1'b0;
    #1;
    if (t_result !== 4'd8) errors = errors + 1;
    t_op = 1'b1;
    #1;
    if (t_result !== 4'd2) begin
      $display("FAIL: op-only change: got %0d, expected 2", t_result);
      errors = errors + 1;
    end

    for (op = 0; op < 2; op = op + 1) begin
      for (a = 0; a < 16; a = a + 1) begin
        for (b = 0; b < 16; b = b + 1) begin
          t_a = a;
          t_b = b;
          t_op = op;
          #1;
          if (t_result !== (t_op ? (t_a - t_b) : (t_a + t_b))) begin
            $display("FAIL: a=%0d b=%0d op=%b | got %0d, expected %0d",
                     t_a, t_b, t_op, t_result,
                     t_op ? (t_a - t_b) : (t_a + t_b));
            errors = errors + 1;
          end
        end
      end
    end

    if (errors == 0)
      $display("PASS: op-only check and all 512 ALU cases matched.");
    else
      $fatal(1, "FAIL: %0d input pairs mismatched.", errors);
    $finish;
  end

  initial
    $monitor($time, " a=%h b=%h op=%b | result=%h", t_a, t_b, t_op, t_result);

endmodule
