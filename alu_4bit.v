module alu_4bit (
    input wire [3:0] a,
    input wire [3:0] b,
    input wire [2:0] op,
    input wire cin,
    output reg [3:0] result,
    output reg cout,
    output reg zero,
    output reg overflow,
    output reg negative
);

    wire [4:0] add_result = {1'b0, a} + {1'b0, b};
    wire [4:0] sub_result = {1'b0, a} - {1'b0, b};

    always @(*) begin
        result = 4'b0000;
        cout = 1'b0;
        overflow = 1'b0;

        case (op)
            3'b000: begin
                result = add_result[3:0];
                cout = add_result[4];
                overflow = (a[3] == b[3]) && (result[3] != a[3]);
            end
            3'b001: begin
                result = sub_result[3:0];
                cout = ~sub_result[4];
                overflow = (a[3] != b[3]) && (result[3] != a[3]);
            end
            3'b010: result = a & b;
            3'b011: result = a | b;
            3'b100: result = a ^ b;
            3'b101: result = ~a;
            3'b110: begin
                result = {a[2:0], 1'b0};
                cout = a[3];
            end
            3'b111: begin
                result = {1'b0, a[3:1]};
                cout = a[0];
            end
        endcase

        zero = (result == 4'b0000);
        negative = result[3];
    end

endmodule
