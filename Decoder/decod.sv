
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2026 16:57:50
// Design Name: 
// Module Name: decod
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module decoder (
    input  logic [31:0] instruction,

    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd,

    output logic [6:0]  opcode,
    output logic [6:0]  imm11_5,

    output logic [2:0]  fn3,

    output logic [11:0] imm,
    output logic [19:0] imm_uj,

    output logic        fn7_5
);

    // Opcode is always taken from instruction[6:0]
    assign opcode = instruction[6:0];

    // Combinational decoder
    always_comb begin

        // Default values: all outputs zero
        rs1      = 5'b0;
        rs2      = 5'b0;
        rd       = 5'b0;
        imm11_5  = 7'b0;
        fn3      = 3'b0;
        imm      = 12'b0;
        imm_uj   = 20'b0;
        fn7_5    = 1'b0;

        case (opcode)

            // R-TYPE
            7'b0110011: begin
                rd      = instruction[11:7];
                fn3     = instruction[14:12];
                rs1     = instruction[19:15];
                rs2     = instruction[24:20];
                fn7_5   = instruction[30];
            end

            // I-TYPE ALU
            7'b0010011: begin
                rd      = instruction[11:7];
                fn3     = instruction[14:12];
                rs1     = instruction[19:15];
                imm     = instruction[31:20];
                imm11_5 = instruction[31:25];
            end

            // LOAD
            7'b0000011: begin
                rd      = instruction[11:7];
                fn3     = instruction[14:12];
                rs1     = instruction[19:15];
                imm     = instruction[31:20];
            end

            // STORE
            7'b0100011: begin
                fn3     = instruction[14:12];
                rs1     = instruction[19:15];
                rs2     = instruction[24:20];
                imm     = {instruction[31:25],
                           instruction[11:7]};
            end

            // BRANCH
            7'b1100011: begin
                fn3     = instruction[14:12];
                rs1     = instruction[19:15];
                rs2     = instruction[24:20];

                imm     = {instruction[31],
                           instruction[7],
                           instruction[30:25],
                           instruction[11:8]};
            end

            // JAL
            7'b1101111: begin
                rd      = instruction[11:7];

                imm_uj  = {instruction[31],
                           instruction[19:12],
                           instruction[20],
                           instruction[30:21]};
            end

            // JALR
            7'b1100111: begin
                rd      = instruction[11:7];
                fn3     = instruction[14:12];
                rs1     = instruction[19:15];
                imm     = instruction[31:20];
            end

            // LUI
            7'b0110111: begin
                rd      = instruction[11:7];
                imm_uj  = instruction[31:12];
            end

            // AUIPC
            7'b0010111: begin
                rd      = instruction[11:7];
                imm_uj  = instruction[31:12];
            end

            // UNSUPPORTED OPCODE
            default: begin
                // All outputs remain zero
            end

        endcase
    end

endmodule

