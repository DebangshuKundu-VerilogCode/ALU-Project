lu #(parameter WIDTH=8)(OPA,OPB,CIN,CLK,RST,CMD,CE,MODE,INP_VALID,COUT,OFLOW,RES,G,E,L,ERR);


//Input output port declaration
parameter RES_W=2*WIDTH;
  input [WIDTH-1:0] OPA,OPB;
  input CLK,RST,CE,MODE,CIN;
  input [3:0] CMD;
  input [1:0]INP_VALID;
  output reg [RES_W-1:0] RES;
  output reg COUT = 1'b0;
  output reg OFLOW = 1'b0;
  output reg G = 1'b0;
  output reg E = 1'b0;
  output reg L = 1'b0;
  output reg ERR = 1'b0;

//Temporary register declaration
  reg [WIDTH-1:0] OPA_1, OPB_1;
  reg [1:0] count;          

reg [WIDTH-1:0] opa_r;          
reg [WIDTH-1:0] opb_r;          

reg [RES_W-1:0] mult_res;      

reg mult_active;          

reg [3:0] cmd_r;          
reg mode_r;             
reg [WIDTH-1:0] temp_add;
reg [WIDTH-1:0] temp_sub;
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        count <= 2'b00;
    end
    else begin
        if (mult_active) begin
            count <= count + 1'b1;

            if (count == 2'b10)
                count <= 2'b00;
        end
        else
            count <= 2'b00;
    end
end

always @(posedge CLK or posedge RST) begin
    if (RST) begin
        opa_r <= 0;
        opb_r <= 0;
        cmd_r <= 0;
        mode_r <= 0;
    end
    else if (CE) begin
        opa_r <= OPA;
        opb_r <= OPB;
        cmd_r <= CMD;
        mode_r <= MODE;
    end
end

  
    always@(posedge CLK or posedge RST)
      begin
      if(RST)                // If reset is active high all output signals are equal to zero
          begin
           RES <= {RES_W{1'b0}};
    	   COUT <= 0;
           OFLOW <= 0;
           G <= 0;
           E <= 0;
           L <= 0;
           ERR <= 0;
           mult_active<=1'b0;
           mult_res<={RES_W{1'b0}};
     
          end
else begin
   if(CE)  begin                 // If clock enable is active high then check for other control signals
        if(mode_r) begin          // Reset signal is active low. If MODE signal is high, then this is an Arithmetic Operation
            RES<={RES_W{1'b0}};
            COUT<=1'b0;
            OFLOW<=1'b0;
            G<=1'b0;
            E<=1'b0;
            L<=1'b0;
            ERR<=1'b0;
            opa_r<=OPA;
            opb_r<=OPB;
           case(cmd_r)             // CMD is the binary code value of the Arithmetic Operation
           4'b0000:             // CMD = 0000: ADD 
            begin 
		if(INP_VALID==2'b11) 
			begin
			 {COUT, RES[WIDTH-1:0]} <= opa_r + opb_r;
 			end
		else
			begin
			    ERR<=1'b1;
			    RES<={RES_W{1'b0}};
			    COUT<=1'b0;
			end     
            end
	   4'b0001:             // CMD = 0001: SUB
            begin
		if(INP_VALID==2'b11) 
			begin
			    OFLOW<=(opa_r<opb_r)?1:0;
                            RES<=opa_r-opb_r;
			end
		else
			begin
			    ERR<=1'b1;
			    OFLOW<=1'b0;
		 	    RES<={RES_W{1'b0}};
			end
            end
           4'b0010:             // CMD = 0010: ADD_CIN
            begin
		if(INP_VALID==2'b11) begin
             		RES<=opa_r+opb_r+CIN;
             		COUT<=RES[WIDTH]?1:0;
            	end
		else begin
			ERR<=1'b1;
			RES<={RES_W{1'b0}};
			COUT<=1'b0;
		end
	    end
           4'b0011:             // CMD = 0011: SUB_CIN. Here we set the overflow flag
           begin
		if(INP_VALID==2'b11) begin
                   OFLOW<=(opa_r<(opb_r+CIN))?1:0;
                   RES<=opa_r-opb_r-CIN;
		end
		else begin
		   ERR<=1'b1;
		   OFLOW<=1'b0;
		   RES<={RES_W{1'b0}};
		end
           end
           4'b0100:
	   begin
	      if(INP_VALID==2'b01 || INP_VALID==2'b11) begin
		RES<=opa_r+1;    // CMD = 0100: INC_A
		end
	      else begin
		ERR<=1'b1;
		RES<={RES_W{1'b0}};
		end
	   end
           4'b0101:
	      begin
		 if(INP_VALID==2'b01 || INP_VALID==2'b11) begin
		RES<=opa_r-1;    // CMD = 0101: DEC_A
		end
	      else begin
		ERR<=1'b1;
		RES<={RES_W{1'b0}};
		end
	      end
           4'b0110:
	      begin
		 if(INP_VALID==2'b01 || INP_VALID==2'b11) begin
		     RES<=opb_r+1;    // CMD = 0110: INC_B
		end
	      else begin
		ERR<=1'b1;
		RES<={RES_W{1'b0}};
		end
	      end
           4'b0111:
 	     begin
		 if(INP_VALID==2'b01 || INP_VALID==2'b11) begin
		RES<=opb_r-1;    // CMD = 0100: DEC_B
		end
	      else begin
		ERR<=1'b1;
		RES<={RES_W{1'b0}};
		end
	     end
           4'b1000:              // CMD = 1000: CMP
           begin
            RES<={RES_W{1'b0}};
	if(INP_VALID==2'b11) begin
            if(opa_r==opb_r)
             begin
               E<=1'b1;
               G<=1'b0;
               L<=1'b0;
             end
            else if(opa_r>opb_r)
             begin
               E<=1'b0;
               G<=1'b1;
               L<=1'b0;
             end
            else 
             begin
               E<=1'b0;
               G<=1'b0;
               L<=1'b1;
             end
	     end
	else begin
	       E<=1'b0;G<=1'b0;L<=1'b0;ERR<=1'b1;
	     end
           end
	4'b1001: begin
    if (count == 2'b00) begin
        if (INP_VALID == 2'b11) begin
            opa_r <= OPA + 1;
            opb_r <= OPB+1;
            mult_active <= 1'b1;
            
        end
    end

   
    else if (count == 2'b01) begin
        if (mult_active) begin
            mult_res <= opa_r * opb_r;
        end
        RES<={RES_W{1'bx}};
    end

    
    else if (count == 2'b10) begin
        if (mult_active) begin
            RES <= mult_res;
            mult_active <= 1'b0;
        end
    end

end
    4'b1010: begin
    if (count == 2'b00) begin
        if (INP_VALID == 2'b11) begin
            opa_r <= OPA<<1;
            opb_r <= OPB;
            mult_active <= 1'b1;
            
        end
    end

   
    else if (count == 2'b01) begin
        if (mult_active) begin
            mult_res <= opa_r * opb_r;
        end
    end

    
    else if (count == 2'b10) begin
        if (mult_active) begin
            RES <= mult_res;
            mult_active <= 1'b0;
        end
    end

end
	 
	  
	 4'b1011: begin
    if (INP_VALID == 2'b11) begin
        G <= (opa_r > opb_r) ? 1'b1 : 1'b0;
        E <= (opa_r == opb_r) ? 1'b1 : 1'b0;
        L <= (opa_r < opb_r) ? 1'b1 : 1'b0;

        RES <= opa_r + opb_r;
        COUT <= 1'b0;

        if (opa_r[WIDTH-1] == opb_r[WIDTH-1])begin
	    temp_add=opa_r+opb_r;
            OFLOW <= (temp_add[WIDTH-1] != opa_r[WIDTH-1]) ? 1'b1 : 1'b0;end
        else
            OFLOW <= 1'b0;
    end
    else begin
        RES <= {RES_W{1'b0}};
        OFLOW <= 1'b0;
        COUT <= 1'b0;
    end
end	
	 4'b1100: begin
    if (INP_VALID == 2'b11) begin
        G <= (opa_r > opb_r) ? 1'b1 : 1'b0;
        E <= (opa_r == opb_r) ? 1'b1 : 1'b0;
        L <= (opa_r < opb_r) ? 1'b1 : 1'b0;

        RES <= opa_r - opb_r;
        COUT <= 1'b0;

        if (opa_r[WIDTH-1] != opb_r[WIDTH-1]) begin
	    temp_sub=opa_r-opb_r;
            OFLOW <= (temp_sub[WIDTH-1] != opa_r[WIDTH-1]) ? 1'b1 : 1'b0;end
        else
            OFLOW <= 1'b0;
    end
    else begin
        RES <= {RES_W{1'b0}};
        OFLOW <= 1'b0;
        COUT <= 1'b0;
    end
end			
           default:   
            begin
            RES<={RES_W{1'b0}};
            COUT<=1'b0;
            OFLOW<=1'b0;
            G<=1'b0;
            E<=1'b0;
            L<=1'b0;
            ERR<=1'b1;
           end
          endcase
         end

        else          // MODE signal is low, then this is a Logical Operation
        begin 
           RES<={2*WIDTH{1'b0}};
           COUT<=1'b0;
           OFLOW<=1'b0;
           G<=1'b0;
           E<=1'b0;
           L<=1'b0;
           ERR<=1'b0;
           opa_r<=OPA;
           opa_r<=OPB;
           case(cmd_r)    
             4'b0000: begin
		if(INP_VALID==2'b11) begin
			RES <= {{(RES_W-WIDTH){1'b0}}, (OPA & OPB)};   // CMD = 0000: AND
		end
		else begin
			ERR<=1'b1;
			RES<={RES_W{1'b0}};
		end
	     end
             4'b0001: begin
		if(INP_VALID==2'b11) begin
			RES <= {{(RES_W-WIDTH){1'b0}}, ~(OPA & OPB)};     // CMD = 0001: NAND
		end
		else begin
			ERR<=1'b1;
			RES<={RES_W{1'b0}};
		end
 	     end
             4'b0010: begin
		if(INP_VALID==2'b11) begin
			RES <= {{(RES_W-WIDTH){1'b0}}, (OPA | OPB)};     // CMD = 0010: OR
		end
		else begin
			ERR<=1'b1;
			RES<={RES_W{1'b0}};
		end
	      end
             4'b0011: begin 
		if(INP_VALID==2'b11) begin
			RES <= {{(RES_W-WIDTH){1'b0}}, ~(OPA | OPB)};     // CMD = 0011: NOR
		end
		else begin
			ERR<=1'b1;
			RES<={RES_W{1'b0}};
		end
	     end
             4'b0100: begin
		if(INP_VALID==2'b11) begin
			RES <= {{(RES_W-WIDTH){1'b0}}, (OPA ^ OPB)};     // CMD = 0100: XOR
		end
		else begin
			ERR<=1'b1;
			RES<={RES_W{1'b0}};
		end
	     end
             4'b0101:begin 
		if(INP_VALID==2'b11) begin
			RES <= {{(RES_W-WIDTH){1'b0}}, ~(OPA ^ OPB)};     // CMD = 0101: XNOR
		end
		else begin
			ERR<=1'b1;
			RES<={RES_W{1'b0}};
		end
	     end
             4'b0110:begin 
		if(INP_VALID==2'b11 || INP_VALID==2'b01) begin
			RES <= {{(RES_W-WIDTH){1'b0}}, ~(OPA)};     // CMD = 0110:NOT_A
		end
		else begin
			ERR<=1'b1;
			RES<={RES_W{1'b0}};
		end
	     end           
	     4'b0111:begin 
		if(INP_VALID==2'b11 || INP_VALID==2'b10) begin
			RES <= {{(RES_W-WIDTH){1'b0}}, ~(OPB)};      // CMD = 0111:NOT_B
		end
		else begin
			ERR<=1'b1;
			RES<={RES_W{1'b0}};
		end
	     end            
	     4'b1000:begin
		if(INP_VALID==2'b11 || INP_VALID==2'b01) begin
			RES <= {{(RES_W-WIDTH){1'b0}}, (OPA>>1)};      // CMD = 1000:SHR1_A
		end
		else begin
			ERR<=1'b1;
			RES<={RES_W{1'b0}};
		end
	     end
             4'b1001:begin
		   if(INP_VALID==2'b11 || INP_VALID==2'b01) begin
			RES <= {{(RES_W-WIDTH){1'b0}}, (OPA<<1)};      // CMD = 1001:SHL1_A
		end
		else begin
			ERR<=1'b1;
			RES<={RES_W{1'b0}};
		end
	     end
             4'b1010:begin
		if(INP_VALID==2'b11 || INP_VALID==2'b10) begin
			RES <= {{(RES_W-WIDTH){1'b0}}, (OPB>>1)};      // CMD = 1010:SHR1_B
		end
		else begin
			ERR<=1'b1;
			RES<={RES_W{1'b0}};
		end
	     end
             4'b1011:begin
		if(INP_VALID==2'b11 || INP_VALID==2'b10) begin
			RES <= {{(RES_W-WIDTH){1'b0}}, (OPB<<1)};     // CMD = 1010:SHL1_B
		end
		else begin
			ERR<=1'b1;
			RES<={RES_W{1'b0}};
		end
	     end

            4'b1100: begin   // ROL_A_B

    if (INP_VALID == 2'b11) begin

        if (opb_r[$clog2(WIDTH)-1:0] == 0)
            RES <= {{(RES_W-WIDTH){1'b0}}, opa_r};
        else
            RES <= {{(RES_W-WIDTH){1'b0}},
                   ((opa_r << opb_r[$clog2(WIDTH)-1:0]) | 
                    (opa_r >> (WIDTH - opb_r[$clog2(WIDTH)-1:0])))};

        
        if (|opb_r[WIDTH-1:$clog2(WIDTH)])
            ERR <= 1'b1;
        else
            ERR <= 1'b0;

    end 
    else begin
        ERR <= 1'b1;
        RES <= {RES_W{1'b0}};
    end

end
	     
            4'b1101: begin   // ROR_A_B

    if (INP_VALID == 2'b11) begin

        
        if (opb_r[$clog2(WIDTH)-1:0] == 0)
            RES <= {{(RES_W-WIDTH){1'b0}}, opa_r};
        else
            RES <= {{(RES_W-WIDTH){1'b0}},
                   ((opa_r >> opb_r[$clog2(WIDTH)-1:0]) | 
                    (opa_r << (WIDTH - opb_r[$clog2(WIDTH)-1:0])))};

        
        if (|opb_r[WIDTH-1:$clog2(WIDTH)])
            ERR <= 1'b1;
        else
            ERR <= 1'b0;

    end 
    else begin
        ERR <= 1'b1;
        RES <= {RES_W{1'b0}};
    end

end
             default:    
               begin
               RES<={RES_W{1'b0}};
               COUT<=1'b0;
               OFLOW<=1'b0;
               G<=1'b0;
               E<=1'b0;
               L<=1'b0;
               ERR<=1'b0;
               end
          endcase
     end
    end
    else begin //if CE=0
		RES<={RES_W{1'b0}};
		G<=1'b0;
		E<=1'b0;
		L<=1'b0;
		COUT<=1'b0;
		OFLOW<=1'b0;
		ERR<=1'b0;
	end
   end
   
   end
endmodule

