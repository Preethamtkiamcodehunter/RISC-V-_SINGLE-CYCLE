`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2026 17:09:06
// Design Name: 
// Module Name: imme
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


module imm_generator (
    input  logic [11:0] imm_input,
    input  logic [2:0]  fn3,
    input  logic [6:0]  opcode,
    input  logic [19:0] imm_input_uj,
    output logic [31:0] imm_output
);

    always_comb begin

        // Default: sign-extend the 12-bit immediate
        imm_output = {{20{imm_input[11]}}, imm_input};

        case (opcode)

            // Branch instructions: BEQ, BNE, BLT, BGE, BLTU, BGEU
            7'b1100011: begin
                imm_output = {{20{imm_input[11]}}, imm_input} << 1;
            end

            // JAL instruction
            7'b1101111: begin
                imm_output = {{12{imm_input_uj[19]}}, imm_input_uj} << 1;
            end

            // LUI instruction
            7'b0110111: begin
                imm_output = {imm_input_uj, 12'b0};
            end

            // AUIPC instruction
            7'b0010111: begin
                imm_output = {imm_input_uj, 12'b0};
            end

            // JALR instruction
            7'b1100111: begin
                imm_output = {{20{imm_input[11]}}, imm_input};
            end

            // I-type ALU instructions
            7'b0010011: begin

                // Shift instructions: SLLI, SRLI, SRAI
                if (fn3 == 3'b001 || fn3 == 3'b101) begin
                    imm_output = {27'b0, imm_input[4:0]};
                end

                // Other I-type instructions
                else begin
                    imm_output = {{20{imm_input[11]}}, imm_input};
                end
            end

            // All other instructions
            default: begin
                imm_output = {{20{imm_input[11]}}, imm_input};
            end

        endcase
    end

endmodule

