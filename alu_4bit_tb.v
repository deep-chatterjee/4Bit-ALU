`timescale 1ns/1ps

module alu_4bit_tb;

    reg [3:0] a, b;
    reg [2:0] op;
    reg cin;
    wire [3:0] result;
    wire cout, zero, overflow, negative;

    integer passed = 0;
    integer failed = 0;
    integer i, j;

    alu_4bit uut (
        .a(a), .b(b), .op(op), .cin(cin),
        .result(result), .cout(cout),
        .zero(zero), .overflow(overflow), .negative(negative)
    );

    task check;
        input [8*40:1] name;
        input [3:0]    exp_result;
        input          exp_cout;
        input          exp_zero;
        input          exp_overflow;
        input          exp_negative;
        begin
            if (result === exp_result && cout === exp_cout &&
                zero === exp_zero && overflow === exp_overflow &&
                negative === exp_negative) begin
                $display("  PASS: %s", name);
                passed = passed + 1;
            end else begin
                $display("  FAIL: %s", name);
                $display("        Expected: r=%b c=%b z=%b v=%b n=%b",
                         exp_result, exp_cout, exp_zero, exp_overflow, exp_negative);
                $display("        Got:      r=%b c=%b z=%b v=%b n=%b",
                         result, cout, zero, overflow, negative);
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        $display("========================================");
        $display("    4-BIT ALU VERIFICATION SUITE");
        $display("========================================");

        $display("\n--- ADD ---");
        op = 3'b000; cin = 0;
        a = 4'd5;  b = 4'd3;  #10; check("5 + 3 = 8 (signed overflow)", 4'd8,  0, 0, 1, 1);
        a = 4'd15; b = 4'd1;  #10; check("15 + 1 = 0, carry",           4'd0,  1, 1, 0, 0);
        a = 4'd0;  b = 4'd0;  #10; check("0 + 0 = 0",                   4'd0,  0, 1, 0, 0);
        a = 4'b0111; b = 4'b0001; #10; check("7 + 1 overflow",          4'b1000, 0, 0, 1, 1);
        a = 4'b1000; b = 4'b1111; #10; check("-8 + -1 overflow",      4'b0111, 1, 0, 1, 0);

        $display("\n--- SUB ---");
        op = 3'b001;
        a = 4'd8;  b = 4'd3;  #10; check("8 - 3 = 5 (signed overflow)", 4'd5,  1, 0, 1, 0);
        a = 4'd5;  b = 4'd5;  #10; check("5 - 5 = 0",                   4'd0,  1, 1, 0, 0);
        a = 4'd0;  b = 4'd1;  #10; check("0 - 1 = 15, borrow",          4'd15, 0, 0, 0, 1);

        $display("\n--- LOGICAL ---");
        a = 4'b1010; b = 4'b1100;
        op = 3'b010; #10; check("AND", 4'b1000, 0, 0, 0, 1);
        op = 3'b011; #10; check("OR",  4'b1110, 0, 0, 0, 1);
        op = 3'b100; #10; check("XOR", 4'b0110, 0, 0, 0, 0);
        op = 3'b101; #10; check("NOT", 4'b0101, 0, 0, 0, 0);

        $display("\n--- SHIFTS ---");
        op = 3'b110;
        a = 4'b1010; #10; check("LSL 1010", 4'b0100, 1, 0, 0, 0);
        op = 3'b111;
        a = 4'b1010; #10; check("LSR 1010", 4'b0101, 0, 0, 0, 0);

        $display("\n--- EXHAUSTIVE ADD ---");
        op = 3'b000;
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                a = i[3:0]; b = j[3:0]; #1;
                if (result !== ((i+j)&4'hF)) failed = failed + 1;
                else passed = passed + 1;
            end
        end

        $display("\n--- EXHAUSTIVE SUB ---");
        op = 3'b001;
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                a = i[3:0]; b = j[3:0]; #1;
                if (result !== ((i-j)&4'hF)) failed = failed + 1;
                else passed = passed + 1;
            end
        end

        $display("\n========================================");
        $display("  Passed: %0d", passed);
        $display("  Failed: %0d", failed);
        if (failed == 0) $display("  ALL TESTS PASSED");
        else $display("  FAILURES DETECTED");
        $display("========================================");

        $finish;
    end

    initial begin
        $dumpfile("alu_4bit.vcd");
        $dumpvars(0, alu_4bit_tb);
    end

endmodule
