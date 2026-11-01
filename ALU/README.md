# ALU

Design a 32-bit Arithmetic Logic Unit (ALU) with 16 operations, including the branch comparisons.

### Module Specification

```SystemVerilog
module alu #(parameter int DATA_WIDTH = 32)(
    input  logic [4:0]            alu_control,
    input  logic [DATA_WIDTH-1:0] rs1_data,
    input  logic [DATA_WIDTH-1:0] rs2_data,
    output logic [DATA_WIDTH-1:0] alu_out,
    output logic                  zero          // branch condition true
);
 always_comb begin

        // Default outputs
        alu_out = '0;
        zero    = 1'b0;

        case (alu_control)

            // ADD
            5'b00000:
                alu_out = rs1_data + rs2_data;

            // SUB
            5'b00001:
                alu_out = rs1_data - rs2_data;

            // XOR
            5'b00010:
                alu_out = rs1_data ^ rs2_data;

            // OR
            5'b00011:
                alu_out = rs1_data | rs2_data;

            // AND
            5'b00100:
                alu_out = rs1_data & rs2_data;

            // SLL - Shift Left Logical
            5'b00101:
                alu_out = rs1_data << rs2_data[4:0];

            // SRL - Shift Right Logical
            5'b00110:
                alu_out = rs1_data >> rs2_data[4:0];

            // SRA - Shift Right Arithmetic
            5'b00111:
                alu_out = $signed(rs1_data) >>> rs2_data[4:0];

            // SLT - Set Less Than (Signed)
            5'b01000:
                alu_out = ($signed(rs1_data) <
                           $signed(rs2_data)) ? 1 : 0;

            // SLTU - Set Less Than (Unsigned)
            5'b01001:
                alu_out = (rs1_data < rs2_data) ? 1 : 0;

            // BEQ - Branch if Equal
            5'b01010: begin
                alu_out = '0;
                zero = (rs1_data == rs2_data);
            end

            // BNE - Branch if Not Equal
            5'b01011: begin
                alu_out = '0;
                zero = (rs1_data != rs2_data);
            end

            // BLT - Branch if Less Than (Signed)
            5'b01100: begin
                alu_out = '0;
                zero = ($signed(rs1_data) <
                        $signed(rs2_data));
            end

            // BGE - Branch if Greater Than or Equal (Signed)
            5'b01101: begin
                alu_out = '0;
                zero = ($signed(rs1_data) >=
                        $signed(rs2_data));
            end

            // BLTU - Branch if Less Than (Unsigned)
            5'b01110: begin
                alu_out = '0;
                zero = (rs1_data < rs2_data);
            end

            // BGEU - Branch if Greater Than or Equal (Unsigned)
            5'b01111: begin
                alu_out = '0;
                zero = (rs1_data >= rs2_data);
            end

            // UNUSED CODES
            default: begin
                alu_out = '0;
                zero    = 1'b0;
            end

        endcase

    end

endmodule


 
```

### ALU Control Table

| alu_control | Operation | Result |
|---|---|---|
| `00000` | ADD | `alu_out = rs1 + rs2` |
| `00001` | SUB | `rs1 - rs2` |
| `00010` | XOR | `rs1 ^ rs2` |
| `00011` | OR | `rs1 \| rs2` |
| `00100` | AND | `rs1 & rs2` |
| `00101` | SLL | `rs1 << rs2[4:0]` |
| `00110` | SRL | `rs1 >> rs2[4:0]` (logical) |
| `00111` | SRA | `rs1 >>> rs2[4:0]` (arithmetic) |
| `01000` | SLT | `1` if `rs1 < rs2` signed, else `0` |
| `01001` | SLTU | `1` if `rs1 < rs2` unsigned, else `0` |
| `01010` | BEQ | `zero = (rs1 == rs2)` |
| `01011` | BNE | `zero = (rs1 != rs2)` |
| `01100` | BLT | `zero = (rs1 < rs2)` signed |
| `01101` | BGE | `zero = (rs1 >= rs2)` signed |
| `01110` | BLTU | `zero = (rs1 < rs2)` unsigned |
| `01111` | BGEU | `zero = (rs1 >= rs2)` unsigned |
| `1xxxx` | unused | `alu_out = 0`, `zero = 0` |

For the six branch codes (`01010`-`01111`) `alu_out` is 0 and only `zero` is set. For every other code `zero` is 0.

### Interface

> [!IMPORTANT]
> Your module, port and parameter names are up to you. Your design must have the same number of ports, with the same directions and widths, as shown above, and must behave as specified. Map your names to this spec in `rnr-stage.yaml` (see the assignment handout).
