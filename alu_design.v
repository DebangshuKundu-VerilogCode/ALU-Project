`timescale 1ns/1ps
`default_nettype none
module alu_design #(parameter n=8, m=4)(
    clk, rst, inp_valid, mode, cmd, ce,
    opa, opb, cin,
    err, res, oflow, cout, g, l, e
);
input  wire        clk, rst, cin, ce, mode;
input  wire [1:0]  inp_valid;
input  wire [n-1:0] opa, opb;
input  wire [m-1:0] cmd;
output reg [2*n:0] res;
output reg  cout, err, oflow, g, l, e;
reg [1:0]    count_1, count_2, count_3, count_4;
reg [2*n:0]  temp_res1, temp_res2;
reg [2*n:0]  r_res;
reg  r_cout, r_err, r_oflow, r_g, r_l, r_e;
always @(posedge clk or posedge rst) begin
    if (rst) begin
        r_res   <= {(2*n){1'b0}};
        r_err   <= 1'b0;
        r_oflow <= 1'b0;
        r_cout  <= 1'b0;
        r_g     <= 1'b0;
        r_l     <= 1'b0;
        r_e     <= 1'b0;
        count_1 <= 2'd0; count_2 <= 2'd0;
        count_3 <= 2'd0; count_4 <= 2'd0;
        temp_res1 <= {(2*n){1'b0}};
        temp_res2 <= {(2*n){1'b0}};
        res<=0;
    end
    else if (ce) begin
     r_res   <= {(2*n){1'b0}};
            r_err   <= 1'b0;
            r_oflow <= 1'b0;
            r_cout  <= 1'b0;
            r_g     <= 1'b0;
            r_l     <= 1'b0;
            r_e     <= 1'b0;
              res<=0;
        if (mode) begin
            r_res   <= {(2*n){1'b0}};
            r_err   <= 1'b0;
            r_oflow <= 1'b0;
            r_cout  <= 1'b0;
            r_g     <= 1'b0;
            r_l     <= 1'b0;
            r_e     <= 1'b0;
            res<=0;
            count_1 <= 2'd0; count_2 <= 2'd0;
            count_3 <= 2'd0; count_4 <= 2'd0;
            case (cmd)
                0: begin
                    if (inp_valid == 2'b11) begin
                        r_res  <= opa + opb;
                        r_cout <= ({1'b0,opa} + {1'b0,opb}) > {n{1'b1}};
                    end else begin
                        r_res <= {(2*n){1'b0}};
                        r_err <= 1'b1;
                    end
                end
                1: begin
                    if (inp_valid == 2'b11) begin
                        r_res   <= opa - opb;
                        r_oflow <= (opb > opa);
                    end else begin
                        r_res <= {(2*n){1'b0}};
                        r_err <= 1'b1;
                    end
                end
                2: begin
                    if (inp_valid == 2'b11) begin
                        r_res  <= opa + opb;
                        r_cout <= ({1'b0,opa} + {1'b0,opb}) > {n{1'b1}};
                    end else begin
                        r_res <= {(2*n){1'b0}};
                        r_err <= 1'b1;
                    end
                end
                3: begin
                    if (inp_valid == 2'b11) begin
                        r_res   <= opa - opb - cin;
                        r_oflow <= ({1'b0,opb} + cin) > opa;
                    end else begin
                        r_res <= {(2*n){1'b0}};
                        r_err <= 1'b1;
                    end
                end
                4: begin
                    if (inp_valid == 2'b01)
                        r_res <= opa + 1;
                    else begin
                        r_res <= {(2*n){1'b0}};
                        r_err <= 1'b1;
                    end
                end
                5: begin
                    if (inp_valid == 2'b01)
                        r_res <= opa - 1;
                    else begin
                        r_res <= {(2*n){1'b0}};
                        r_err <= 1'b1;
                    end
                end
                6: begin
                    if (inp_valid == 2'b10)
                        r_res <= opb + 1;
                    else begin
                        r_res <= {(2*n){1'b0}};
                        r_err <= 1'b1;
                    end
                end
                7: begin
                    if (inp_valid == 2'b10)
                        r_res <= opb - 1;
                    else begin
                        r_res <= {(2*n){1'b0}};
                        r_err <= 1'b1;
                    end
                end
                8: begin
                    if (inp_valid == 2'b11) begin
                        r_g <= (opa > opb);
                        r_l <= (opa < opb);
                        r_e <= (opa == opb);
                    end else begin
                        r_err <= 1'b1;
                    end
                end
                9: begin
                    count_1 <= count_1;
                    count_2 <= count_2;
                    if (inp_valid == 2'b11) begin
                        if (count_1 == 0) begin
                            temp_res1 <= ((opa+1) * (opb+1));
                            count_1   <= count_1 + 1;
                        end else if (count_1 == 2'd2) begin
                            res       <= temp_res1;          
                            temp_res1 <= ((opa+1) * (opb+1));
                            count_1   <= 1;
                        end else begin
                            count_1 <= count_1 + 1;
                        end
                    end else begin
                        if (count_2 == 2'd2) begin
                            r_err   <= 1'b1;
                            count_2 <= 1;
                        end else begin
                            count_2 <= count_2 + 1;
                        end
                    end
                end
                10: begin
                    count_3 <= count_3;
                    count_4 <= count_4;
                    if (inp_valid == 2'b11) begin
                        if (count_3 == 0) begin
                            temp_res2 <= (opa << 1) * opb;
                            count_3   <= count_3 + 1;
                        end else if (count_3 == 2'd2) begin
                            res       <= temp_res2;           
                            count_3   <= 1;
                            temp_res2 <= (opa << 1) * opb;
                        end else begin
                            count_3 <= count_3 + 1;
                        end
                    end else begin
                        if (count_4 == 2'd2) begin
                            r_err   <= 1'b1;
                            count_4 <= 1;
                        end else begin
                            count_4 <= count_4 + 1;
                        end
                    end
                end
                11: begin
                    if (inp_valid == 2'b11) begin
                        r_res   <= $signed(opa) + $signed(opb);
                        r_oflow <= (opa[n-1] == opb[n-1]) &&
                                   (($signed(opa) + $signed(opb)) >> (n-1) != opa[n-1]);
                        r_g     <= ($signed(opa) > $signed(opb));
                        r_l     <= ($signed(opa) < $signed(opb));
                        r_e     <= ($signed(opa) == $signed(opb));
                    end else begin
                        r_res <= {(2*n){1'b0}};
                        r_err <= 1'b1;
                    end
                end
                12: begin
                    if (inp_valid == 2'b11) begin
                        r_res   <= $signed(opa) - $signed(opb);
                        r_oflow <= (opa[n-1] != opb[n-1]) &&
                                   (($signed(opa) - $signed(opb)) >> (n-1) != opa[n-1]);
                        r_g     <= ($signed(opa) > $signed(opb));
                        r_l     <= ($signed(opa) < $signed(opb));
                        r_e     <= ($signed(opa) == $signed(opb));
                    end else begin
                        r_res <= {(2*n){1'b0}};
                        r_err <= 1'b1;
                    end
                end
                default: r_err <= 1'b1;
            endcase
        end else begin
            r_res   <= {(2*n+1){1'b0}};
            r_err   <= 1'b0;
            r_oflow <= 1'b0;
            r_cout  <= 1'b0;
            r_g     <= 1'b0;
            r_l     <= 1'b0;
            r_e     <= 1'b0;
            count_1 <= 2'd0; count_2 <= 2'd0;
            count_3 <= 2'd0; count_4 <= 2'd0;
            case (cmd)
                0: begin
                    if (inp_valid == 2'b11) r_res <= opa & opb;
                    else begin r_res <= {(2*n){1'b0}}; r_err <= 1'b1; end
                end
                1: begin
                    if (inp_valid == 2'b11) r_res <= ~(opa & opb);
                    else begin r_res <= {(2*n){1'b0}}; r_err <= 1'b1; end
                end
                2: begin
                    if (inp_valid == 2'b11) r_res <= opa | opb;
                    else begin r_res <= {(2*n){1'b0}}; r_err <= 1'b1; end
                end
                3: begin
                    if (inp_valid == 2'b11) r_res <= ~(opa | opb);
                    else begin r_res <= {(2*n){1'b0}}; r_err <= 1'b1; end
                end
                4: begin
                    if (inp_valid == 2'b11) r_res <= opa ^ opb;
                    else begin r_res <= {(2*n){1'b0}}; r_err <= 1'b1; end
                end
                5: begin
                    if (inp_valid == 2'b11) r_res <= ~(opa ^ opb);
                    else begin r_res <= {(2*n){1'b0}}; r_err <= 1'b1; end
                end
                6: begin
                    if (inp_valid == 2'b11) r_res <= ~opa;
                    else begin r_res <= {(2*n){1'b0}}; r_err <= 1'b1; end
                end
                7: begin
                    if (inp_valid == 2'b11) r_res <= ~opb;
                    else begin r_res <= {(2*n){1'b0}}; r_err <= 1'b1; end
                end
                8: begin
                    if (inp_valid == 2'b01) r_res <= opa >> 1;
                    else begin r_res <= {(2*n){1'b0}}; r_err <= 1'b1; end
                end
                9: begin
                    if (inp_valid == 2'b01) r_res <= opa << 1;
                    else begin r_res <= {(2*n){1'b0}}; r_err <= 1'b1; end
                end
                10: begin
                    if (inp_valid == 2'b10) r_res <= opb >> 1;
                    else begin r_res <= {(2*n){1'b0}}; r_err <= 1'b1; end
                end
                11: begin
                    if (inp_valid == 2'b10) r_res <= opb << 1;
                    else begin r_res <= {(2*n){1'b0}}; r_err <= 1'b1; end
                end
                12: begin
                    if (inp_valid == 2'b11) begin
                        if (opb > 4'b1111) r_err <= 1'b1;
                        else r_res <= (opa << opb[2:0]) | (opa >> (n - opb[2:0]));
                    end else begin
                        r_res <= {(2*n){1'b0}}; r_err <= 1'b1;
                    end
                end
                13: begin
                    if (inp_valid == 2'b11) begin
                        if (opb > 4'b1111) r_err <= 1'b1;
                        else r_res <= (opa >> opb[2:0]) | (opa << (n - opb[2:0]));
                    end else begin
                        r_res <= {(2*n){1'b0}}; r_err <= 1'b1;
                    end
                end
                default: r_err <= 1'b1;
            endcase
        end
    end
end
always @(posedge clk or posedge rst) begin
    if (rst) begin
        res   <= {(2*n){1'b0}};
        err   <= 1'b0;
        oflow <= 1'b0;
        cout  <= 1'b0;
        g     <= 1'b0;
        l     <= 1'b0;
        e     <= 1'b0;
    end else if (ce) begin
        if (mode && (cmd == 4'd9 || cmd == 4'd10)) begin
            err   <= r_err;
            oflow <= r_oflow;
            cout  <= r_cout;
            g     <= r_g;
            l     <= r_l;
            e     <= r_e;
        end else begin
            res   <= r_res;
            err   <= r_err;
            oflow <= r_oflow;
            cout  <= r_cout;
            g     <= r_g;
            l     <= r_l;
            e     <= r_e;
        end
    end
end
endmodule

