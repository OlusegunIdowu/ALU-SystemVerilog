module alu_tb;
    localparam N = 8;

    localparam ALU_ADD = 3'b000; 
    localparam ALU_SUB = 3'b001;
    localparam ALU_AND = 3'b010;
    localparam ALU_OR = 3'b011;
    localparam ALU_XOR = 3'b100;
    localparam ALU_SLL = 3'b101;
    localparam ALU_SRL = 3'b110;
    localparam ALU_SRA = 3'b111;

    logic [N-1:0] A, B;
    logic [2:0] op;

    logic [N-1:0] result;
    logic zero, negative, carry, overflow;

    int pass_count = 0;
    int fail_count = 0;

    alu #(.N(N)) test (.A(A), .B(B), .op(op), .result(result), .zero(zero), .negative(negative), .carry(carry), .overflow(overflow) );

    initial begin
        $dumpfile ("alu_signals.vcd");
        $dumpvars(0, alu_tb);
    end

    task check(input string test_name, input logic [N-1:0] exp_result, input logic exp_zero, input logic exp_negative, input logic exp_carry, input logic exp_overflow);
        #10;

        if (result !== exp_result || zero !== exp_zero || negative !== exp_negative || carry !== exp_carry || overflow !== exp_overflow) begin
            $display ("FAILED TEST: %s", test_name);
            $display ("A = %0d B = %0d op = %0b", A, B, op);

            fail_count++;
        end
        else begin
            $display ("PASSED TEST: %s", test_name);
            pass_count++;
        end
    endtask

    initial begin
        $display("=== ALU Testbench ===");
        
        // TESTS USING ADD

        // addition
        A = 8'd15;  B = 8'd10;  op = ALU_ADD;
        check("ALU_ADD basic", 8'd25, 0, 0, 0, 0);

        // zero output
        A = 8'd0;   B = 8'd0;   op = ALU_ADD;
        check("ALU_ADD zero", 8'd0, 1, 0, 0, 0);

        // carry out
        A = 8'd200; B = 8'd100; op = ALU_ADD;
        check("ALU_ADD carry out", 8'd44, 0, 0, 1, 0);

        // signed overflow
        A = 8'd127; B = 8'd1;   op = ALU_ADD;
        check("ALU_ADD signed overflow", 8'd128, 0, 1, 0, 1);

        // negative and negative overflow
        A = 8'h80;  B = 8'hFF;  op = ALU_ADD;
        check("ALU_ADD negative overflow", 8'h7F, 0, 0, 1, 1);

        // TESTS USING SUB

        // subtraction
        A = 8'd20;  B = 8'd10;  op = ALU_SUB;
        check("ALU_SUB basic", 8'd10, 0, 0, 0, 0);

        // zero by minusing A by itself
        A = 8'd42;  B = 8'd42;  op = ALU_SUB;
        check("ALU_SUB equal", 8'd0, 1, 0, 0, 0);

        // negative
        A = 8'd5;   B = 8'd10;  op = ALU_SUB;
        check("ALU_SUB negative result", 8'hFB, 0, 1, 1, 0);

        // signed overflow with subtraction
        A = 8'h80;  B = 8'd1;   op = ALU_SUB;
        check("ALU_SUB signed overflow", 8'h7F, 0, 0, 0, 1);

        // TESTS USING AND

        A = 8'hFF;  B = 8'h0F;  op = ALU_AND;
        check("ALU_AND mask lower nibble", 8'h0F, 0, 0, 0, 0);

        A = 8'hAA;  B = 8'h55;  op = ALU_AND;
        check("ALU_AND alternating bits zero", 8'h00, 1, 0, 0, 0);

        // TESTS USING OR

        A = 8'hAA;  B = 8'h55;  op = ALU_OR;
        check("ALU_OR alternating bits", 8'hFF, 0, 1, 0, 0);

        A = 8'h00;  B = 8'h00;  op = ALU_OR;
        check("ALU_OR zeros", 8'h00, 1, 0, 0, 0);

        //TESTS USING XOR

        A = 8'hAB;  B = 8'hAB;  op = ALU_XOR;
        check("ALU_XOR self", 8'h00, 1, 0, 0, 0);

        A = 8'hAA;  B = 8'h55;  op = ALU_XOR;
        check("ALU_XOR alternating", 8'hFF, 0, 1, 0, 0);

        // TESTS WITH SLL/SRL/SRA

        A = 8'b00000001; B = 8'd4; op = ALU_SLL;
        check("ALU_SLL by 4", 8'b00010000, 0, 0, 0, 0);

        A = 8'b10000000; B = 8'd1; op = ALU_SLL;
        check("ALU_SLL overflow left", 8'b00000000, 1, 0, 0, 0);

        A = 8'h80; B = 8'd4; op = ALU_SRL;
        check("ALU_SRL fills with zero", 8'h08, 0, 0, 0, 0);

        A = 8'h80; B = 8'd4; op = ALU_SRA;
        check("ALU_SRA preserves sign bit", 8'hF8, 0, 1, 0, 0);

        A = 8'h7F; B = 8'd1; op = ALU_SRA;
        check("ALU_SRA positive no sign extend", 8'h3F, 0, 0, 0, 0);


        $display("");
        $display("=== Results: %0d passed, %0d failed ===", pass_count, fail_count);
        
        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED — check output above");
        $finish;
    end
endmodule
