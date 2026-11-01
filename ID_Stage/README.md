# ID Stage (Instruction Decode)

Design the decode stage by connecting the **Decoder**, **Immediate Generator**, **Register File** and **Main Control**.

### Module Specification

```SystemVerilog
module id_stage(
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic [31:0] instruction,
    input  logic [31:0] wb_data,        // data to write back (from the WB stage)
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,
    output logic [31:0] imm_out,
    output logic [6:0]  opcode_out_d,
    output logic [6:0]  imm11_5,
    output logic [2:0]  fn3_out_d,
    output logic        fn7_5,
    output logic [2:0]  aluop,
    output logic [1:0]  memtoreg,
    output logic        branch,
    output logic        mem_write,
    output logic        mem_read,
    output logic        alu_src,
    output logic        mux_inp
);
 // Internal decoder signals
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;

    logic [11:0] imm;
    logic [19:0] imm_uj;

    // Internal control signal
    logic reg_write;
    logic reg_write_enable;

    // ------------------------------------------------
    // 1. DECODER
    // ------------------------------------------------
    decoder DEC1 (
        .instruction (instruction),
        .rs1         (rs1),
        .rs2         (rs2),
        .rd          (rd),
        .opcode      (opcode_out_d),
        .imm11_5     (imm11_5),
        .fn3         (fn3_out_d),
        .imm         (imm),
        .imm_uj      (imm_uj),
        .fn7_5       (fn7_5)
    );

    // ------------------------------------------------
    // 2. IMMEDIATE GENERATOR
    // ------------------------------------------------
    imm_generator IMM1 (
        .imm_input    (imm),
        .fn3          (fn3_out_d),
        .opcode       (opcode_out_d),
        .imm_input_uj (imm_uj),
        .imm_output   (imm_out)
    );

    // ------------------------------------------------
    // 3. MAIN CONTROL
    // ------------------------------------------------
    main_control CTRL1 (
        .opcode    (opcode_out_d),
        .fn3       (fn3_out_d),
        .memtoreg  (memtoreg),
        .branch    (branch),
        .mux_inp   (mux_inp),
        .memread   (mem_read),
        .memwrite  (mem_write),
        .alusrc    (alu_src),
        .reg_write (reg_write),
        .aluop     (aluop)
    );

    // Stop register writes when stalled
    assign reg_write_enable = reg_write && !stall;

    // ------------------------------------------------
    // 4. REGISTER FILE
    // ------------------------------------------------
    register_file RF1 (
        .rs1_sel   (rs1),
        .rs2_sel   (rs2),
        .reg_write (reg_write_enable),
        .clk       (clk),
        .reset     (reset),
        .wb_data   (wb_data),
        .rd_sel    (rd),
        .rs1_data  (rs1_data),
        .rs2_data  (rs2_data)
    );

endmodule

```

### Working

- `instruction` goes through the **Decoder**; its `imm` / `imm_uj` / `fn3` / `opcode` feed the **Immediate Generator** (`imm_out`).
- The decoder's `rs1`, `rs2` select the Register File read ports; its `rd` is the write address.
- **Main Control** produces `branch`, `memtoreg`, `aluop`, `mem_write`, `alu_src`, `mem_read`, `mux_inp` and the register write enable.
- The register write enable is gated: **`reg_write && !stall`** (no register is written while stalled).
- `opcode_out_d`, `fn3_out_d`, `fn7_5`, `imm11_5` are the decoder's outputs, passed on.

### Interface

> [!IMPORTANT]
> Your module, port and parameter names are up to you. Your design must have the same number of ports, with the same directions and widths, as shown above, and must behave as specified. Map your names to this spec in `rnr-stage.yaml` (see the assignment handout).
