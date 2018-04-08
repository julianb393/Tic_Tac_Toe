/*
Authors: Julian, Ruyin, Radu and Brian.
Inspirations & works cited:
-	http://www.fpga4student.com/2017/06/tic-tac-toe-game-in-verilog-and-logisim.html
- https://github.com/OliviaRuyinZhang/TicTacToe-verilog
*/


`timescale 1ns / 1ns // `timescale time_unit/time_precision
module TicTacToe
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
	LEDG, LEDR,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);


	input			CLOCK_50;				//	50 MHz
	input   [17:0]   SW;
	input   [3:0]   KEY;

	output [7:0] HEX0, HEX1; // Used for the Timer.


	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]

	output  [7:0] LEDG;
	output [17:0] LEDR;
	wire resetn, load, draw, legalCheck;
	assign resetn = SW[17];
	assign load = SW[16];
	assign draw = SW[15];
	assign legalCheck = SW[14];

	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire [3:0] player1;
	wire [3:0] player2;
	wire writeEn;

	wire [1:0] pos0, pos1, pos2, pos3, pos4, pos5, pos6, pos7, pos8;

	assign player1 = SW[3:0];
	assign player2 = SW[7:4];

	wire legal1;
	wire legal2;


  legalMove lmove1(player1, legalCheck,pos0, pos1, pos2, pos3, pos4, pos5, pos6, pos7, pos8 ,legal1);
  legalMove lmove2(player2, legalCheck,pos0, pos1, pos2, pos3, pos4, pos5, pos6, pos7, pos8 ,legal2);
	timer t(SW[9:8], HEX0, HEX1, CLOCK_50);





	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "grid2.mif";

	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.

	  // Instansiate FSM control
	  control c0(CLOCK_50, resetn, load, draw, legal1, legal2, ld_1, ld_2, countEn, writeEn);
    // Instansiate datapath
	  datapath d0(CLOCK_50, resetn, ld_1, ld_2, countEn, legal1, legal2, SW[3:0], SW[7:4], x, y,colour, pos0, pos1, pos2, pos3, pos4, pos5, pos6, pos7, pos8);

		wire [1:0] who;
	  check_winner wd(pos0, pos1,pos2,pos3,pos4,pos5,pos6,pos7,pos8, who[1:0]);

		assign LEDG[7:6] = who[1:0];

		wire lightwire;
		legalLight llight(ld_1, ld_2, legal1, legal2, lightwire);
		assign LEDR[14] = lightwire;


		assign LEDR[13] = legal1;
		assign LEDR[12] = legal2;



endmodule

module legalLight(input ld_1, ld_2, legal1, legal2, output reg light);

 always @(*)
	begin

	if(ld_2)
	begin
		light <= legal1;
	end
	else
		begin
			if(ld_1)
				light <= legal2;
		end

	end
endmodule

module legalMove(input[3:0] player, input legalCheck,input [0:1] pos0, pos1, pos2, pos3, pos4, pos5, pos6, pos7, pos8,
	 output reg legal);

	always @(*)
		begin
		if(legalCheck)
			begin
		 case(player[3:0])
			4'b0000: begin
				if(pos0 !== 2'b00) // is not empty
					begin
					legal <= 1'b1; // Not a legal move
					end
				else
					legal <= 1'b0;
				end
	    	4'b0001: begin
			  // pos1 <= 2'b1;
			  legal <= 1'b0;
			    end
			4'b0010: begin
			  // pos2 <= 1'b1;
			  legal <= 1'b0;
				end
			4'b0011: begin
			// pos3 <= 1'b1;
			legal <= 1'b0;
				end
			4'b0100: begin
			   // pos4 <= 1'b1;
				legal <= 1'b0;
			    end
			4'b0101: begin
			  // pos5 <= 1'b1;
			  legal <= 1'b0;
			    end
			4'b0110: begin
			 // pos6 <= 1'b1;
			 legal <= 1'b0;
			    end
			4'b0111: begin
			  // pos7 <= 1'b1;
			  legal <= 1'b0;
			    end
			4'b1000: begin
			  //pos8 <= 1'b1;
			  legal <= 1'b0;
			    end
			default legal <= 1'b0;
		endcase
		end
		end

	endmodule

module control(input clk, input resetn, input load, input render, legal1, legal2,
	             output reg ld_1, ld_2, light, countEn, writeEn);

	 reg[5:0] current_state, next_state;

	 localparam legal_x = 4'd0, load_x = 4'd1, load_x_wait = 4'd2, RENDER_X = 4'd3, legal_y = 4'd4,
					    load_y = 4'd5, load_y_wait = 4'd6, RENDER_Y= 4'd7;

	always @(*)
	    begin
        case (current_state)
				  legal_x: next_state = ~legal1 ? load_x : legal_x;
				  load_x: next_state = load ? load_x_wait : load_x;
				  load_x_wait: next_state = render ? RENDER_X : load_x_wait;
				  RENDER_X: next_state = render ? RENDER_X : legal_y;
				  legal_y: next_state = ~legal2 ? load_y: legal_y;
				  load_y: next_state = load ? load_y_wait : load_y;
				  load_y_wait: next_state = render ? RENDER_Y: load_y_wait;
				  RENDER_Y: next_state = render ? RENDER_Y : load_x;
          default next_state = legal_x;
		  endcase
    end

	 always @(*)
	   begin
	     ld_1 = 1'b0;
		  ld_2 = 1'b0;

		  countEn = 1'b0;
		  writeEn = 1'b0;

		  light = 1'b0;

		   case (current_state)

				legal_x: begin
					light = legal1;
				end

				RENDER_X: begin
				ld_1 = 1'b1;
				countEn = 1'b1;
				writeEn = 1'b1;
				end

				legal_y: begin
					light = legal2;
				end

				 RENDER_Y: begin
				 	ld_2 = 1'b1;
				   countEn = 1'b1;
					 writeEn = 1'b1;
					 end

		  endcase
    end

	  always@(posedge clk)
	  begin
	      if (!resetn)
		      current_state <= load_x;
		    else
		      current_state <= next_state;
	  end
endmodule

module datapath(input clk, input resetn,
	              input ld_1, ld_2, countEn, legal1, legal2,
	              input [3:0] player1,
				  input [3:0] player2,
	              output reg[7:0] x,
	              output reg[6:0] y,
			output reg[2:0] colour,
			output reg[1:0] pos0, pos1,pos2,pos3,pos4,pos5,pos6,pos7,pos8);

	 reg[7:0] temp_x;
	 reg[6:0] temp_y;
	 reg[2:0] temp_c;
	 reg[3:0] count;

	 always@(posedge clk)
	 begin
	     if (!resetn) begin
		      temp_x <= 8'd0;
			  temp_y <= 7'd0;
			  temp_c <= 3'b110;
				  end
		   else begin

		if (ld_1 & ~legal1) begin
		 case(player1[3:0])
			4'b0000: begin
		      	  temp_x <= 8'd17;
			  temp_y <= 7'd13;
			  temp_c <= 3'b100;
			  pos0 <= 2'b01;
				end
	    	4'b0001: begin
			  temp_x <= 8'd74;
			  temp_y <= 7'd13;
			  temp_c <= 3'b100;
			  pos1 <= 2'b01;
			    end
			4'b0010: begin
			  temp_x <= 8'd114;
			  temp_y <= 7'd13;
			  temp_c <= 3'b100;
			  pos2 <= 2'b01;
				end
			4'b0011: begin
              temp_x <= 8'd17;
			  temp_y <=7'd66;
			 temp_c <= 3'b100;
			pos3 <= 2'b01;
				end
			4'b0100: begin
			  temp_x <= 8'd74;
			  temp_y <= 7'd66;
			  temp_c <= 3'b100;
			   pos4 <= 2'b01;
			    end
			4'b0101: begin
			  temp_x <= 8'd114;
			  temp_y <= 7'd66;
			  temp_c <= 3'b100;
			  pos5 <= 2'b01;
			    end
			4'b0110: begin
			     temp_x <= 8'd17;
			  temp_y <= 7'd106;
			  temp_c<= 3'b100;
			 pos6 <= 2'b01;
			    end
			4'b0111: begin
			  temp_x <= 8'd74;
			  temp_y <= 7'd106;
			  temp_c <= 3'b100;
			  pos7 <= 2'b01;
			    end
			4'b1000: begin
			  temp_x <=8'd114;
			  temp_y <= 7'd106;
			  temp_c <= 3'b100;
			  pos8 <= 2'b01;
			    end

		endcase
		end
		if (ld_2 & ~legal2) begin
		 case(player2[3:0])
			4'b0000: begin
		      temp_x <= 8'd17;
			  temp_y <= 7'd13;
			  temp_c <= 3'b010;
			pos0 <= 2'b10;
				end
	    	4'b0001: begin
			  temp_x <= 8'd74;
			  temp_y <= 7'd13;
			  temp_c <= 3'b010;
			  pos1 <= 2'b10;
			    end
			4'b0010: begin
			  temp_x <= 8'd114;
			  temp_y <= 7'd13;
			  temp_c <= 3'b010;
			  pos2 <= 2'b10;
				end
			4'b0011: begin
              temp_x <= 8'd17;
			  temp_y <=7'd66;
			 temp_c <= 3'b010;
			pos3 <= 2'b10;
				end
			4'b0100: begin
			  temp_x <= 8'd74;
			  temp_y <= 7'd66;
			  temp_c <= 3'b010;
			pos4 <= 2'b10;
			    end
			4'b0101: begin
			  temp_x <= 8'd114;
			  temp_y <= 7'd66;
			  temp_c <= 3'b010;
			  pos5 <= 2'b10;
			    end
			4'b0110: begin
			     temp_x <= 8'd17;
			  temp_y <= 7'd106;
			  temp_c <= 3'b010;
			  pos6 <= 2'b10;
			    end
			4'b0111: begin
			  temp_x <= 8'd74;
			  temp_y <= 7'd106;
			  temp_c <= 3'b010;
			  pos7 <= 2'b10;
			    end
			4'b1000: begin
			  temp_x <=8'd114;
			  temp_y <= 7'd106;
			  temp_c <= 3'b010;
			  pos8 <= 2'b10;
			    end

		endcase
		end
	 end
	 end

	 always@(posedge clk)
	 begin
	     if (!resetn) count <= 4'b0;
		   else if (countEn) count <= count + 4'b0010;
	 end

	 always@(posedge clk)
	 begin
	     if (!resetn) begin
		      x <= 8'b0;
				  y <= 7'b0;
				  colour <= 3'b0;
				  end
		  else if (countEn) begin
		      x <= temp_x + {6'b0, count[1:0]};
				  y <= temp_y + {5'b0, count[3:2]};
				  colour <= temp_c[2:0];
				  end
	 end
endmodule

module check_winner(input [1:0] pos0, pos1, pos2, pos3,
	pos4, pos5, pos6, pos6 ,pos8,
	output wire [1:0]who);

	// What the grid resembles.
	//| 0 | 1 | 2 |
	//| 3 | 4 | 5 |
	//| 6 | 7 | 8 |

	wire [1:0] who1, who2, who3, who4, who5, who6, who7, who8;
	check_winner_helper u1(pos0, pos1, pos2, who1);// (0,1,2);
	check_winner_helper u2(pos3, pos4, pos5, who2);// (3,4,5);
	check_winner_helper u3(pos6, pos7, pos8, who3);// (6,7,8);
	check_winner_helper u4(pos0, pos3, pos6, who4);// (0,3,6);
	check_winner_helper u5(pos1, pos4, pos7, who5);// (1,4,7);
	check_winner_helper u6(pos2, pos5, pos8, who6);// (2,5,8);
	check_winner_helper u7(pos0, pos4, pos8, who7);// (0,4,8);
	check_winner_helper u8(pos2, pos4, pos6, who8);// (2,4,6);
	assign who = who1 | who2 | who3 | who4 | who5 | who6 | who7 | who8;
endmodule

module check_winner_helper(input [1:0] pos0,pos1,pos2,
	output wire [1:0]who);

	wire winner;
	wire [1:0] temp0;
	wire temp1;

	assign temp0[0] = (!(pos0[0]^pos1[0])) & (!(pos2[0]^pos1[0]));
	assign temp0[1] = (!(pos0[1]^pos1[1])) & (!(pos2[1]^pos1[1]));
	assign temp1 = pos0[1] | pos0[0];
	// winner if 3 positions are similar and should be 01 or 10
	assign winner = temp1 & temp0[1] & temp0[0];
	// determine who the winner is
	assign who[1] = winner & pos0[1];
	assign who[0] = winner & pos0[0];
endmodule

module timer(SW, HEX0, HEX1, CLOCK_50);

  input CLOCK_50;
  input [9:8] SW;

  output [7:0] HEX0, HEX1;

  wire rate_divider_to_timer;
  wire [7:0] time_remaining;
  wire time_up;

  // assign ports
  rate_divider_50_mhz rd(
    .enable(SW[8]),
    .clock(CLOCK_50),
    .reset(SW[9]),
    .out(rate_divider_to_timer)
    );

  timer_30_seconds t(
    .enable(SW[8]),
    .clock(rate_divider_to_timer),
    .reset(SW[9]),
    .q(time_remaining),
    .out(time_up)
    );


  // display the time remaining on the hex displays
  hex_display(time_remaining[7:4], HEX1);
  hex_display(time_remaining[3:0], HEX0);

endmodule


module rate_divider_50_mhz(enable, clock, reset, out);

  input enable, clock, reset;

  output reg out;

  reg [25:0] q;

  wire [25:0] d;

  assign d = 26'b10111110101111000001111111; // 49999999 in binary

  always@(posedge clock)
  begin
	 // reset counter to 4999999
    if (reset == 1'b1)
		begin
        out <= 1'b0;
        q <= d;
		end
	 else if (enable == 1'b1)
		begin
			// 0, reset to 4999999, send signal that it is 50 millionth clock pulse
			if (q == 26'b0)
				begin
					out <= 1'b1;
					q <= d;
				end
			// decrement 1, disable signal
			else
				begin
					out <= 1'b0;
					q <= q - 1'b1;
				end
		end
  end

endmodule


module timer_30_seconds(enable, clock, reset, q, out);

  input enable, clock, reset;

  output reg out;
  output reg [7:0] q;

  wire [7:0] d;

  assign d = 8'b00110000; // set the timer to 30

  always@(posedge clock)
  begin
	// reset timer to 30 when reset is on
	if (reset == 1'b1)
		begin
		  out <= 1'b0;
        q <= d;
		end
   else if (enable == 1'b1)
		begin
			// ensure that the timer never has unwanted values
			if (q > 8'b00110000)
				begin
					out <= 1'b0;
					q <= 8'b00110000;
				end
			// 30 -> 29
			else if (q == 8'b00111001)
				begin
					out <= 1'b0;
					q <= 8'b00101001;
				end
        else if (q[7:4] == 4'b0010)
				begin
					// 20 -> 19
					if (q[3:0] == 4'b0000)
						begin
							out <= 1'b0;
							q <= 8'b00011001;
						end
					// 29 -> 20
					else
						begin
							out <= 1'b0;
							q <= q - 1'b1;
						end
				end
        else if (q[7:4] == 4'b0001)
				begin
					// 10 -> 9
					if (q[3:0] == 4'b0000)
						begin
							out <= 1'b0;
							q <= 8'b00001001;
						end
					// 19 -> 10
					else
						begin
							out <= 1'b0;
							q <= q- 1'b1;
						end
				end
		  else if (q[7:4] == 4'b0000)
				begin
					// 0, reset to 30
					if (q[3:0] == 4'b0000)
						begin
							out <= 1'b1;
							q <= d;
						end
					// 9 -> 0
					else
						begin
							out <= 1'b0;
							q <=  q - 1'b1;
						end
				end
		end
  end

endmodule


module hex_display(IN, OUT);
    input [3:0] IN;
	 output reg [7:0] OUT;

	 always @(*)
	 begin
		case(IN[3:0])
			4'b0000: OUT = 7'b1000000;
			4'b0001: OUT = 7'b1111001;
			4'b0010: OUT = 7'b0100100;
			4'b0011: OUT = 7'b0110000;
			4'b0100: OUT = 7'b0011001;
			4'b0101: OUT = 7'b0010010;
			4'b0110: OUT = 7'b0000010;
			4'b0111: OUT = 7'b1111000;
			4'b1000: OUT = 7'b0000000;
			4'b1001: OUT = 7'b0011000;
			4'b1010: OUT = 7'b0001000;
			4'b1011: OUT = 7'b0000011;
			4'b1100: OUT = 7'b1000110;
			4'b1101: OUT = 7'b0100001;
			4'b1110: OUT = 7'b0000110;
			4'b1111: OUT = 7'b0001110;

			default: OUT = 7'b0111111;
		endcase

	end
endmodule
