module bound_flasher(clock, reset, led_out, flick);
        input wire clock;
        input wire reset;
        input wire flick;
        output reg [15:0] led_out;
        reg [15:0] tmpLed; // dung de luu trang thai cua den doi xung clock roi moi gan vo led_out

        reg [2:0] state_curr;
        reg [2:0] state_next;
		  
		  // Ta khai bao cac state co the xay ra
		  parameter INIT_MAP = 16'b0;
        parameter STATE_INIT = 3'b000;
        parameter L0_L5_up = 3'b001;
        parameter L5_L0_down = 3'b010;
        parameter L0_L10_up = 3'b011;
        parameter L10_L5_down = 3'b100;
        parameter L5_L15_up = 3'b101;
        parameter L15_L0_down = 3'b110;
		  parameter L5_OFF = 3'b111;
		  
			initial begin
				led_out = INIT_MAP;
				tmpLed = INIT_MAP;
				state_curr = STATE_INIT;
			end
        
//        always @(reset or state_next)
//		  begin
//				if(reset) state_curr = STATE_INIT;
//				else state_curr = state_next;
//		  end
//	
        always @(reset or state_next)
		  begin
				if(reset) state_curr = STATE_INIT;
				else state_curr = state_next;
		  end
        always@(posedge clock)
				case(state_curr)
					STATE_INIT: tmpLed =  INIT_MAP;
					L0_L5_up, L5_L15_up, L0_L10_up: tmpLed = (led_out << 1)|16'b1;
					L10_L5_down, L15_L0_down, L5_L0_down,L5_OFF: tmpLed = led_out >> 1;
					default: tmpLed = INIT_MAP;
				endcase
				
	
			
		  always @(posedge reset or posedge clock)
				begin
					if(reset) led_out <= INIT_MAP;
					else led_out <= tmpLed;
				end
        //State Machine
        always @(led_out or reset or state_curr or flick)
                if (reset == 1) state_next = STATE_INIT;
                else
                        case (state_curr)
                              STATE_INIT:
												begin
													 if(flick) state_next = L0_L5_up;
													 else state_next = STATE_INIT;
												end
                              L5_L0_down:
												begin
													 if(!led_out[0]) state_next = L0_L10_up;
													 else state_next = L5_L0_down;
												end
                              L15_L0_down:
												begin
													 if(!led_out[0]) state_next = STATE_INIT;
													 else state_next = L15_L0_down;
                                
												end
                              L10_L5_down:
										      begin
													if(!led_out[5]) state_next = L5_L15_up;
													else state_next = L10_L5_down;
												end

                              L0_L5_up: 
												begin
													if(led_out[5]) state_next = L5_L0_down;
													else state_next = L0_L5_up;
												end
                              L5_L15_up: begin
										  
                                        if (flick == 1 && led_out[10] == 1'b1 && led_out[11] != 1'b1)
                                                state_next = L10_L5_down;
													 else if(flick == 1 && led_out[5] == 1'b1 && led_out[6] != 1'b1)
																state_next = L5_OFF;
                                        else 
													 if (flick == 0 && led_out[15] == 1'b1)
                                                state_next = L15_L0_down;
                                        else
                                                state_next = L5_L15_up;
												end

                              L0_L10_up: begin
                                        if (flick == 1) begin
															   if(led_out[10] == 1'b1 && led_out[11] != 1'b1)
																	state_next = L5_L0_down;
																else if(led_out[5] == 1'b1 && led_out[6] != 1'b1)
																	state_next = L5_L0_down;
																else state_next = L0_L10_up;
													 end
													 else if(led_out[10] == 1'b1 && led_out[11] != 1'b1)
                                                state_next = L10_L5_down;
                                        else
                                                state_next = L0_L10_up;
											end
										L5_OFF:
												if(led_out[4] == 1'b1 && led_out[5] != 1'b1) state_next = L5_L15_up;
                              default: state_next = STATE_INIT; 
                        endcase
		
endmodule
