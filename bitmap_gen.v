module bitmap_gen
(
	input clk,reset_n,
	input [3:0] key,
	input video_on,
	input [11:0] pixel_x,pixel_y,
	output [2:0] rgb
);

localparam MAX_X = 447,
MIN_X = 192,
MAX_Y = 367,
MIN_Y = 112,
SIZE = 256,
BALL_V = 1;

reg [15:0] rd_addr,wr_addr;
wire [15:0] addr;
reg we;
reg [7:0] ball_x_reg,ball_x_next;
reg [7:0] ball_y_reg,ball_y_next;
reg ball_x_delta_reg,ball_x_delta_next;
reg ball_y_delta_reg,ball_y_delta_next;

always @(posedge clk or negedge reset_n)
begin
	if(!reset_n)
	begin
		ball_x_reg <= 0;
		ball_y_reg <= 0;
		ball_x_delta_reg <=0;
		ball_y_delta_reg <= 0;
	end
	else
	begin
		ball_x_reg <= ball_x_next;
		ball_y_reg <= ball_y_next;
		ball_x_delta_reg <= ball_x_delta_next;
		ball_y_delta_reg <= ball_y_delta_next;
	end
end
//moving ball logic
always @(*)
begin
	ball_x_next = ball_x_reg;
	ball_y_next = ball_y_reg;
	ball_x_delta_next = ball_x_delta_reg;
	ball_y_delta_next = ball_y_delta_reg;
	wr_addr =  0;
	we = 0;
	if(key[3])
	begin
		ball_x_next = pixel_x;
		ball_y_next = pixel_y;
	end
	else if(pixel_y == 500 && pixel_x == 0)
	begin
		if(ball_x_reg <= BALL_V)
			ball_x_delta_next = 1;
		else if(ball_x_reg >= (SIZE - BALL_V - 1))
			ball_x_delta_next = 0;
		
		if(ball_y_reg <= BALL_V)
			ball_y_delta_next = 1;
		else if(ball_y_reg >= (SIZE - BALL_V - 1))
			ball_y_delta_next = 0;

		ball_x_next = (ball_x_delta_next)? ball_x_reg + BALL_V : ball_x_reg - BALL_V;
		ball_y_next = (ball_y_delta_next)? ball_y_reg + BALL_V : ball_y_reg - BALL_V;
		wr_addr = {ball_x_reg,ball_y_reg};
		we = 1;
	end
end
//display logic
always @(*)
begin
	rd_addr = 0;
	if(video_on)
	begin
		if(pixel_x>=MIN_X && pixel_x<=MAX_X &&
		pixel_y >= MIN_Y && pixel_y <= MAX_Y)
		begin
			rd_addr[15:8] = pixel_x - MIN_X;
			rd_addr[7:0] = pixel_y - MIN_Y;
		end
	end
end

assign addr = we? wr_addr: rd_addr;

single_port_ram single_port_ram_inst
(
	.clk(clk),
	.reset_n(reset_n),
	.we(we),
	.addr(addr),
	.din(key[2:0]),
	.dout(rgb)
);

endmodule