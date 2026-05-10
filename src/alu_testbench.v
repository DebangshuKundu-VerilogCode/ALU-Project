
`timescale 1ns/1ps
`include "alu_design.v"
`include "alu_reference_model.v"

module alu_testbench;
parameter WIDTH=8,RES_W=2*WIDTH;	
    // DUT signals
    reg [WIDTH-1:0] OPA, OPB;
    reg [1:0] INP_VALID;
    reg CLK, RST, CE, MODE, CIN;
    reg [3:0] CMD;
    wire [RES_W-1:0] RES_dut;
    wire COUT_dut, OFLOW_dut, G_dut, E_dut, L_dut, ERR_dut;

    // Reference model signals
    wire [RES_W-1:0] RES_ref;
    wire COUT_ref, OFLOW_ref, G_ref, E_ref, L_ref, ERR_ref;

    // Test counters
    integer pass_count = 0;
    integer fail_count = 0;
    integer test_count = 0;

    // DUT instantiation
    alu_design dut (
        .opa(OPA), .opb(OPB), .cin(CIN),
        .clk(CLK), .rst(RST), .cmd(CMD),
        .ce(CE), .mode(MODE), .inp_valid(INP_VALID),
        .cout(COUT_dut), .oflow(OFLOW_dut),
        .res(RES_dut),
        .g(G_dut), .e(E_dut), .l(L_dut),
        .err(ERR_dut)
    );

    // Reference model instantiation
    alu_reference_model ref (
        .OPA(OPA), .OPB(OPB), .CIN(CIN),.clk(CLK),.RST(RST),
        .MODE(MODE), .CMD(CMD),
        .RES(RES_ref),
        .COUT(COUT_ref), .OFLOW(OFLOW_ref),
        .G(G_ref), .E(E_ref), .L(L_ref),
        .ERR(ERR_ref)
    );

    // Clock generation
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end

