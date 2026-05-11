A parameterized Arithmetic Logic Unit (ALU) designed in synthesizable Verilog HDL. The data width is configurable via the WIDTH parameter (default: 8-bit), making it reusable across different digital systems. The design operates synchronously on the rising edge of CLK with an active-high RST.

Features:
Dual-mode operation — Arithmetic (MODE=1) and Logical (MODE=0)
13 arithmetic operations — ADD, SUB, ADD/SUB with carry, INC/DEC, CMP, signed arithmetic, and 2-cycle multiply
14 logical operations — AND, NAND, OR, NOR, XOR, XNOR, NOT, shifts, and rotates
Parameterized width — Scalable to 4, 8, 16, 32-bit via WIDTH
Pipeline support — 1-cycle latency for most ops; 2-cycle for MUL_INC and MUL_SHI
Clock Enable (CE) — Output latches when CE is de-asserted
Error detection — ERR flag for invalid CMD or INP_VALID combinations

Verification
A self-checking testbench was built in Verilog, instantiating both the DUT and a golden reference model in parallel. The same stimuli are applied to both and all outputs are compared automatically on every test.

Future Improvements:-
Fix INC/DEC to wrap at WIDTH bits
Assert ERR for all out-of-range CMD values
Clear comparison flags (E/G/L) before non-CMP operations
Fix 2-cycle multiply to drive X on cycle 1
Add constrained-random stimulus generation
Add formal verification properties
Extend testing to WIDTH = 4, 16, 32
