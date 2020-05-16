module cmi_code(CP, Z, CMI, CMO);
	parameter n = 4;
	input CP;			//1920KHz = 240K * 8
	output Z;			//240KHZ; sequence 000-0000-0101-0111
	output CMI;			//cmi coding
	output CMO;			//cmi decoding
	
	reg Z;
	reg [3-1:0] S;		//mod 8 pulse counter
	reg [n-1:0] Q;		//mod 15 counter
	reg CMI;
	reg CMO;
	reg is_odd;			//record '1'
	
	reg [1:0] cm_temp;//record cmi code
	
	always @(posedge CP)	
		begin
			S <= S + 3'd1;		

			if(3'd7 == S)			//divided by 8
				if(Q < 4'd14)		//period = 15
					Q <= Q + 4'd1;
				else
					Q <= 4'd0;
		end
	
	always @(Q)
		case(Q)						//sequence 000-0000-0101-0111
			8,10,12,13,14: 
				Z <= 1'b1;
			default: 
				Z <= 1'b0;
		endcase
		
		
	always @(posedge CP)
		if(1'b0 == Z)				//coding '0'
		begin
			CMI <= S[2];			//change '0' to '01'
			
			if(1'b0 == S[2])
				cm_temp[1] = 1'b0;
			else
				cm_temp[0] = 1'b1;
		end
		else						
		begin
			if(1'b1 == is_odd)	//coding '1', begin with '11'
			begin
				CMI <= 1'b0;
				cm_temp <= 2'b00;
			end
			else
			begin
				CMI <= 1'b1;
				cm_temp <= 2'b11;
			end
		end
	
	always @(negedge S[2])
	begin	
		if(1'b1 == Z)
			is_odd <= ~is_odd;		//the parity of '1' 
		
		if(2'b01 == cm_temp)
			CMO <= 1'b0;
		else if(2'b00 == cm_temp || 2'b11 == cm_temp)
			CMO <= 1'b1;
		else
			CMO <= 1'bx;
	end
		
endmodule
