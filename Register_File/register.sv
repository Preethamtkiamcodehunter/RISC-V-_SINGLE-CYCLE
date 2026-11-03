`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2026 17:17:33
// Design Name: 
// Module Name: register
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


module register_file (
    input  logic [4:0]  rs1_sel,
    input  logic [4:0]  rs2_sel,

    input  logic        reg_write,
    input  logic        clk,
    input  logic        reset,

    input  logic [31:0] wb_data,
    input  logic [4:0]  rd_sel,

    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
);

    // 32 registers, each 32 bits wide
    logic [31:0] register [0:31];

    integer i;

    // Asynchronous reset and synchronous write
    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin

            // Clear all 32 registers
            for (i = 0; i < 32; i = i + 1) begin
                register[i] <= 32'b0;
            end

        end

        else if (reg_write && (rd_sel != 5'd0)) begin

            // Write data into the selected register
            register[rd_sel] <= wb_data;

        end

    end

    // Combinational read port 1
    always_comb begin

        if (rs1_sel == 5'd0)
            rs1_data = 32'b0;
        else
            rs1_data = register[rs1_sel];

    end

    // Combinational read port 2
    always_comb begin

        if (rs2_sel == 5'd0)
            rs2_data = 32'b0;
        else
            rs2_data = register[rs2_sel];

    end

endmodule

