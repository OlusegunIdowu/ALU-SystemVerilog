module alu #(parameter N = 8)(input logic [N-1:0] A, input logic [N-1:0] B, input logic [2:0] op,
output logic [N-1:0] result, output logic negative, output logic zero, output logic carry, output logic overflow);
    
    // operation codes
    localparam ALU_ADD = 3'b000; 
    localparam ALU_SUB = 3'b001;
    localparam ALU_AND = 3'b010;
    localparam ALU_OR = 3'b011;
    localparam ALU_XOR = 3'b100;
    localparam ALU_SLL = 3'b101;
    localparam ALU_SRL = 3'b110;
    localparam ALU_SRA = 3'b111;

    logic [N:0] full_result; // this makes space for carry out. this is 9bits wide not 8

    always_comb begin
        full_result = '0;

        case(op)
            ALU_ADD: full_result = {1'b0, A} + {1'b0, B};
            ALU_SUB: full_result = {1'b0, A} - {1'b0, B};

            ALU_AND: full_result = {1'b0, A & B};
            ALU_OR: full_result = {1'b0, A | B};
            ALU_XOR: full_result = {1'b0, A ^ B};

            ALU_SLL: full_result = {1'b0, A << B [2:0]};
            ALU_SRL: full_result = {1'b0, A >> B [2:0]};
            ALU_SRA: full_result = {1'b0, $signed(A) >>> B [2:0]};

            default: full_result = '0;
        endcase
    end

    assign result = full_result [N-1:0];
    assign carry = full_result[N];
    assign zero = ~| result;
    assign negative = result[N-1];
    assign overflow = (op == ALU_ADD) ? (A[N-1] == B[N-1]) && (result[N-1] != A[N-1]) :
                      (op == ALU_SUB) ? (A[N-1] != B[N-1]) && (result[N-1] != A[N-1]) :
                      1'b0;

endmodule
