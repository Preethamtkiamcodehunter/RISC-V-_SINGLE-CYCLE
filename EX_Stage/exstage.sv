`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2026 17:19:58
// Design Name: 
// Module Name: exstage
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



module ex_stage (
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    input  logic [31:0] imm_out,
    input  logic [31:0] address,

    input  logic        branch,
    input  logic        alu_src,
    input  logic        fn7_5,
    input  logic        mux_inp,

    input  logic [2:0]  fn3,
    input  logic [6:0]  imm11_5,
    input  logic [2:0]  aluop,
    input  logic [6:0]  opcode,

    output logic        and_out_ex,
    output logic [31:0] alu_out,
    output logic [31:0] pc_ex_out
);

    // Internal signals
    logic [31:0] alu_operand_b;
    logic [31:0] pc_signed_offset;

    logic [4:0] alu_control_out;
    logic zero;

    // --------------------------------
    // 1. ALU operand selection
    // --------------------------------

    assign alu_operand_b = (alu_src)
                         ? imm_out
                         : rs2_data;

    // --------------------------------
    // 2. ALU Control
    // --------------------------------

    alu_control AC1 (
        .alu_op(aluop),
        .fn3(fn3),
        .imm11_5(imm11_5),
        .fn7_5(fn7_5),
        .control_out(alu_control_out)
    );

    // --------------------------------
    // 3. ALU
    // --------------------------------

    alu #(
        .DATA_WIDTH(32)
    ) ALU1 (
        .alu_control(alu_control_out),
        .rs1_data(rs1_data),
        .rs2_data(alu_operand_b),
        .alu_out(alu_out),
        .zero(zero)
    );

    // --------------------------------
    // 4. Branch / Jump target calculation
    // --------------------------------

    assign pc_signed_offset = address + imm_out;

    // JALR target: clear bit 0
    // Other branch/jump target: PC + immediate
    assign pc_ex_out = mux_inp
                     ? {alu_out[31:1], 1'b0}
                     : pc_signed_offset;

    // --------------------------------
    // 5. Branch / Jump taken logic
    // --------------------------------

    assign and_out_ex = (branch && zero)
                      || (opcode == 7'h6F)
                      || (opcode == 7'h67);

endmodule
