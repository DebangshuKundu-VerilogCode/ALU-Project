`timescale 1ns/1ps
module alu_reference_model #(parameter WIDTH=8)(
    input wire  clk,RST,
    input wire [WIDTH-1:0] OPA, OPB,
    input  wire CE,CIN, MODE,
    input wire [3:0] CMD,
    input wire [1:0] INP_VALID,
    output reg [15:0] RES,
    output reg COUT, OFLOW, G, E, L, ERR
);
parameter RES_W=2*WIDTH;

    reg [WIDTH-1:0] OPA_1, OPB_1;

    always @(*) begin
        // Default values
if(RST) begin
	RES = {RES_W{1'b0}};
        COUT = 1'b0;
        OFLOW = 1'b0;
        G = 1'b0;
        E = 1'b0;
        L = 1'b0;
        ERR = 1'b0;
end
else begin
if(CE) begin
        if (MODE) begin  // Arithmetic Mode
            case(CMD)
                4'b0000: begin
			if(INP_VALID==2'b11) begin  // ADD
				@(posedge clk);
				RES = OPA + OPB;
				COUT = RES[WIDTH];
			end
			else begin
				@(posedge clk);
				RES = {RES_W{1'b0}};	
				ERR=1;
			end
                end
                4'b0001: begin
			if(INP_VALID==2'b11) begin // SUB
				@(posedge clk);
				OFLOW = (OPA < OPB);
				RES = OPA - OPB;
			end
			else begin
				@(posedge clk);
				RES = {RES_W{1'b0}};
				ERR=1;
			end
                end
                4'b0010: begin  // ADD_CIN
			if(INP_VALID==2'b11) begin
				@(posedge clk);
				RES = OPA + OPB + CIN;
				COUT = RES[WIDTH];
			end
			else begin
				@(posedge clk);
				RES = {RES_W{1'b0}};
				COUT=0;
				ERR=1;
			end
                end
                4'b0011: begin  // SUB_CIN
			if(INP_VALID==2'b11) begin
				@(posedge clk);
				OFLOW = (OPA < (OPB+CIN));
               			RES = OPA - OPB - CIN;
			end
			else begin
				@(posedge clk);
				RES = {RES_W{1'b0}};
				OFLOW=0;
				ERR=1;
			end	
                end
                4'b0100: begin
			if(INP_VALID==2'b11 || INP_VALID==2'b01) begin
				@(posedge clk);
				RES = OPA + 1;  // INC_A
			end
			else begin
				@(posedge clk);
				RES = {RES_W{1'b0}};
				ERR=1;
			end
		end
                4'b0101: begin
			if(INP_VALID==2'b11 || INP_VALID==2'b01) begin
				@(posedge clk);
				 RES = OPA - 1;  // DEC_A
			end
			else begin
				@(posedge clk);
				RES = {RES_W{1'b0}};
				ERR=1;
			end
		end
                4'b0110: begin
			if(INP_VALID==2'b11 || INP_VALID==2'b10) begin
				@(posedge clk);
				 RES = OPB + 1;  // INC_B
			end
			else begin
				@(posedge clk);
				RES = {RES_W{1'b0}};
				ERR=1;
			end
		end
                4'b0111: begin
			if(INP_VALID==2'b11 || INP_VALID==2'b10) begin
				@(posedge clk);
				 RES = OPB - 1;  // DEC_B
			end
			else begin
				@(posedge clk);
				RES = {RES_W{1'b0}};
				ERR=1;
			end
		end 
                4'b1000: begin  // CMP
			RES = 16'b0;
			if(INP_VALID==2'b11) begin	
				if (OPA == OPB) begin
					@(posedge clk);
					E = 1'b1; G = 1'b0; L = 1'b0;
                    		end 
				else if (OPA > OPB) begin
					@(posedge clk);
                        		E = 1'b0; G = 1'b1; L = 1'b0;
                    		end 
				else begin
					@(posedge clk);
                        		E = 1'b0; G = 1'b0; L = 1'b1;
                    		end
                	end
			else begin
				@(posedge clk);
				RES = {RES_W{1'b0}};E=0;G=0;L=0;ERR=1;
			end
		end
		4'b1001: begin
    			if (INP_VALID == 2'b11) begin
				@(posedge clk);
            	OPA_1 = OPA+1;
            	OPB_1 = OPB+1;
				@(posedge clk);
				RES={RES_W{1'bx}};
				@(posedge clk);
				RES=OPA_1*OPB_1;
			end
            		else begin
				@(posedge clk);
				RES={RES_W{1'b0}};
				ERR=1;
			end
 	     	end
		4'b1010: begin
    			if (INP_VALID == 2'b11) begin
				    @(posedge clk);
            	    OPA_1 = OPA<<1;
            	    OPB_1 = OPB;
				    @(posedge clk);
				    RES={RES_W{1'bx}};
				    @(posedge clk);
				    RES=OPA_1*OPB_1;
			end
            else begin
				@(posedge clk);
				RES={RES_W{1'b0}};
				ERR=1;
			end
 	     	end	
		4'b1011: begin
    		if (INP_VALID == 2'b11) begin
				    @(posedge clk);
       				 G = (OPA > OPB) ? 1'b1 : 1'b0;
       				 E = (OPA == OPB) ? 1'b1 : 1'b0;
       				 L = (OPA < OPB) ? 1'b1 : 1'b0;
        			 COUT = 1'b0;

        			if (OPA[WIDTH-1] == OPB[WIDTH-1])begin
	    				RES = OPA + OPB;
            			OFLOW = (RES[WIDTH-1] != RES[WIDTH-1]) ? 1'b1 : 1'b0;
				    end
        			else begin
           			 	OFLOW = 1'b0;
    				end
			end
    			else begin
				    @(posedge clk);
        			RES = {RES_W{1'b0}};
       				OFLOW = 1'b0;
       				COUT = 1'b0;
				ERR=1;
   			      end
		end
		4'b1100: begin
    		if (INP_VALID == 2'b11) begin
				    @(posedge clk);
       				 G = (OPA > OPB) ? 1'b1 : 1'b0;
       				 E = (OPA == OPB) ? 1'b1 : 1'b0;
       				 L = (OPA < OPB) ? 1'b1 : 1'b0;
        			 COUT = 1'b0;

        			if (OPA[WIDTH-1] != OPB[WIDTH-1])begin
	    				RES = OPA + OPB;
            				OFLOW = (RES[WIDTH-1] != RES[WIDTH-1]) ? 1'b1 : 1'b0;
				    end
        			else begin
           			 	OFLOW = 1'b0;
    				end
			end
			else begin
				    @(posedge clk);
        			RES = {RES_W{1'b0}};
       				OFLOW = 1'b0;
       				COUT = 1'b0;
				ERR=1;
   			 end
    		
		end
		default: begin
            		RES={RES_W{1'b0}};
			COUT=1'b0;
			OFLOW=1'b0;
			G=1'b0;
			E=1'b0;
			L=1'b0;
			ERR=1'b1;
		end

            endcase
        end 
        else begin  // Logical Mode
            case(CMD)
                4'b0000: begin
			if(INP_VALID==2'b11) begin
				@(posedge clk);
				RES = {1'b0, OPA & OPB};       // AND
			end
			else begin
				@(posedge clk);
				RES = {RES_W{1'b0}};
				ERR=1;
			end
		end
                4'b0001: begin
			if(INP_VALID==2'b11) begin
				@(posedge clk);
				 RES = {1'b0, ~(OPA & OPB)};    // NAND
			end
			else begin
				@(posedge clk);
				RES = {RES_W{1'b0}};
				ERR=1;
			end
		end
                4'b0010: begin
			if(INP_VALID==2'b11) begin
				@(posedge clk);
				 RES = {1'b0, OPA | OPB};       // OR
			end
			else begin
				@(posedge clk);
				RES = {RES_W{1'b0}};
				ERR=1;
			end
		end
                4'b0011: begin
			if(INP_VALID==2'b11) begin
				@(posedge clk);
				 RES = {1'b0, ~(OPA | OPB)};    // NOR
			end
			else begin
				@(posedge clk);
				RES = {RES_W{1'b0}};
				ERR=1;
			end
		end
                4'b0100: begin
			if(INP_VALID==2'b11) begin
				@(posedge clk);
				 RES = {1'b0, OPA ^ OPB};       // XOR
			end
			else begin
				@(posedge clk);
				RES = {RES_W{1'b0}};
				ERR=1;
			end
		end
                4'b0101: begin
			if(INP_VALID==2'b11) begin
				@(posedge clk);
				 RES = {1'b0, ~(OPA ^ OPB)};    // XNOR
			end
			else begin
				@(posedge clk);
				RES = {RES_W{1'b0}};
				ERR=1;
			end
		end
                4'b0110: begin
			if(INP_VALID==2'b01 || INP_VALID==2'b11) begin
				@(posedge clk);
				 RES = {1'b0, ~OPA};            // NOT_A
			end
			else begin
				@(posedge clk);
				RES = {RES_W{1'b0}};
				ERR=1;
			end
		end
                4'b0111: begin
			if(INP_VALID==2'b11 || INP_VALID==2'b10) begin
				@(posedge clk);
				 RES = {1'b0, ~OPB};            // NOT_B
			end
			else begin
				@(posedge clk);
				RES = {RES_W{1'b0}};
				ERR=1;
			end
		end
                4'b1000: begin
			if(INP_VALID==2'b11 || INP_VALID==2'b01) begin
				@(posedge clk);
				 RES = {1'b0, OPA >> 1};        // SHR1_A
			end
			else begin
				@(posedge clk);
				RES = {RES_W{1'b0}};
				ERR=1;
			end
		end
                4'b1001: begin
			if(INP_VALID==2'b11 || INP_VALID==2'b01) begin
				@(posedge clk);
				 RES = {1'b0, OPA << 1};        // SHL1_A
			end
			else begin
				@(posedge clk);
				RES = {RES_W{1'b0}};
				ERR=1;
			end
		end
                4'b1010: begin
			if(INP_VALID==2'b11 || INP_VALID==2'b10) begin
				@(posedge clk);
				 RES = {1'b0, OPB >> 1};        // SHR1_B
			end
			else begin
				@(posedge clk);
				RES = {RES_W{1'b0}};
				ERR=1;
			end
		end
                4'b1011: begin
			if(INP_VALID==2'b11 || INP_VALID==2'b10) begin
				@(posedge clk);
				 RES = {1'b0, OPB << 1};        // SHL1_B
			end
			else begin
				@(posedge clk);
				RES = {RES_W{1'b0}};
				ERR=1;
			end
		end
                4'b1100: begin  // ROL_A_B
			if(INP_VALID==2'b11) begin
				if (OPB[$clog2(WIDTH)-1:0] == 0) begin
					@(posedge clk);
            				RES = {{(RES_W-WIDTH){1'b0}}, OPA};
				end

        			else begin
					@(posedge clk);
            				RES = {{(RES_W-WIDTH){1'b0}},((OPA << OPB[$clog2(WIDTH)-1:0]) | (OPA >> (WIDTH - OPB[$clog2(WIDTH)-1:0])))};
				end

        			if (|OPB[WIDTH-1:$clog2(WIDTH)]) begin
					@(posedge clk);
            				ERR = 1'b1;
				end
        			else begin
					@(posedge clk);
            				ERR = 1'b0;
				end
		 	end 
    			else begin
				@(posedge clk);
        			ERR = 1'b1;
        			RES = {RES_W{1'b0}};
   			 end
                end
                4'b1101: begin  // ROR_A_B
                     if (INP_VALID == 2'b11) begin
				if (OPB[$clog2(WIDTH)-1:0] == 0) begin
					@(posedge clk);
            				RES = {{(RES_W-WIDTH){1'b0}}, OPA};
				end
        			else begin
					@(posedge clk);
            				RES = {{(RES_W-WIDTH){1'b0}},((OPA >> OPB[$clog2(WIDTH)-1:0]) | (OPA << (WIDTH - OPB[$clog2(WIDTH)-1:0])))};
				end
				if (|OPB[WIDTH-1:$clog2(WIDTH)]) begin
					@(posedge clk);
            				ERR = 1'b1;
				end
        			else begin
					@(posedge clk);
            				ERR = 1'b0;
				end
	   	  end 
    		  else begin
				@(posedge clk);
        			ERR = 1'b1;
        			RES = {RES_W{1'b0}};
		 end
	     end
		default: begin
			RES={RES_W{1'b0}};
             		COUT=1'b0;
               		OFLOW=1'b0;
               		G=1'b0;
               		E=1'b0;
               		L=1'b0;
               		ERR=1'b1;
                end	
		
    	              
         endcase
    end
  end
else begin
		RES={RES_W{1'b0}};
		G=1'b0;
		E=1'b0;
		L=1'b0;
		COUT=1'b0;
		OFLOW=1'b0;
		ERR=1'b1;
end
end
end
endmodule
