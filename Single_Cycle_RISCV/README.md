# Single-Cycle RISC-V

Design the complete single-cycle RV32I core by connecting the **IF**, **ID**, **EX** and **WB** stages. The instruction and data memories are **outside** the core.

### Module Specification

```SystemVerilog
module single_cycle_riscv (
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic [31:0] instruction,   // from instruction memory (addressed by `address`)
    input  logic [31:0] mem_out,       // from data memory
    output logic [31:0] rs2_data,      // store data
    output logic [31:0] alu_out,       // data memory address
    output logic        mem_write,
    output logic        mem_read,
    output logic [2:0]  fn3,           // load / store width
    output logic [6:0]  opcode,
    output logic [31:0] address        // PC
);
 // =================================================
    // INTERNAL SIGNALS
    // =================================================

    // IF stage
    logic [31:0] pc_new;
    logic [31:0] pc_ex_out;
    logic        and_out_ex;

    // ID stage
    logic [31:0] rs1_data;
    logic [31:0] imm_out;

    logic [6:0]  opcode_out_d;
    logic [6:0]  imm11_5;
    logic [2:0]  fn3_out_d;
    logic        fn7_5;

    logic [2:0]  aluop;
    logic [1:0]  memtoreg;

    logic        branch;
    logic        mux_inp;
    logic        id_mem_read;
    logic        id_mem_write;
    logic        alu_src;

    // WB stage
    logic [31:0] wb_data;


    // =================================================
    // 1. IF STAGE - INSTRUCTION FETCH
    // =================================================

    if_stage IF1 (
        .clk(clk),
        .reset(reset),
        .stall(stall),

        .and_out(and_out_ex),
        .pc_signed_offset(pc_ex_out),

        .address(address),
        .pc_new(pc_new)
    );


    // =================================================
    // 2. ID STAGE - INSTRUCTION DECODE
    // =================================================

    id_stage ID1 (
        .clk(clk),
        .reset(reset),
        .stall(stall),

        .instruction(instruction),
        .wb_data(wb_data),

        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm_out(imm_out),

        .opcode_out_d(opcode_out_d),
        .imm11_5(imm11_5),
        .fn3_out_d(fn3_out_d),
        .fn7_5(fn7_5),

        .aluop(aluop),
        .memtoreg(memtoreg),

        .branch(branch),
        .mem_write(id_mem_write),
        .mem_read(id_mem_read),
        .alu_src(alu_src),
        .mux_inp(mux_inp)
    );


    // Send decoded instruction fields to external outputs
    assign opcode = opcode_out_d;
    assign fn3    = fn3_out_d;


    // =================================================
    // 3. EX STAGE - EXECUTE
    // =================================================

    ex_stage EX1 (
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm_out(imm_out),
        .address(address),

        .branch(branch),
        .alu_src(alu_src),
        .fn7_5(fn7_5),
        .mux_inp(mux_inp),

        .fn3(fn3_out_d),
        .imm11_5(imm11_5),
        .aluop(aluop),
        .opcode(opcode_out_d),

        .and_out_ex(and_out_ex),
        .alu_out(alu_out),
        .pc_ex_out(pc_ex_out)
    );


    // =================================================
    // 4. WB STAGE - WRITE BACK
    // =================================================

    wb_stage WB1 (
        .mem_out(mem_out),
        .alu_out(alu_out),
        .return_addr(pc_new),
        .imm_out(imm_out),
        .pc_signed_offset(pc_ex_out),

        .memtoreg(memtoreg),
        .opcode_out_d(opcode_out_d),

        .wb_data(wb_data)
    );


    // =================================================
    // 5. EXTERNAL DATA MEMORY CONTROL
    // =================================================

    // Suppress memory operations when stalled
    assign mem_write = id_mem_write && !stall;
    assign mem_read  = id_mem_read  && !stall;


endmodule
```

### Connections

- **IF:** `address` is the PC; `and_out` / `pc_signed_offset` come from EX (`and_out_ex`, `pc_ex_out`); `pc_new` is the link address.
- **ID:** takes `instruction` and `wb_data` from WB; supplies operands, immediate and control signals.
- **EX:** takes the ID outputs and `address`.
- **WB:** `mem_out`, `alu_out`, `return_addr` (= IF's `pc_new`), `imm_out`, and `pc_signed_offset` (= EX's `pc_ex_out`, which equals `address + imm_out` for AUIPC). `wb_data` goes back to ID.
- **Branch / jump target:** EX's `pc_ex_out` is fed to IF's `pc_signed_offset` and to WB's `pc_signed_offset`; EX's `and_out_ex` is IF's `and_out`.

The core supports RV32I except FENCE, ECALL, EBREAK and CSR instructions.

### Interface

> [!IMPORTANT]
> Your module, port and parameter names are up to you. Your design must have the same number of ports, with the same directions and widths, as shown above, and must behave as specified. Map your names to this spec in `rnr-stage.yaml` (see the assignment handout).
