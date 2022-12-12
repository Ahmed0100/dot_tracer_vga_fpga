module bitmap_gen_top
(
	input clk,reset_n,
	input [3:0] key,
	input rx,
	output vga_hsync,vga_vsync,
	output [2:0] vga_rgb
);

//signal declarations
wire [11:0] pixel_x,pixel_y;
wire video_on;
reg [2:0] rgb_reg;
wire [2:0] rgb_next;
wire [3:0] key_db;

//body

db_fsm db_fsm_inst_0
(.clk(clk), .reset_n(reset_n), .sw(!key[0]), 
	 .db_level(key_db[0]));

db_fsm db_fsm_inst_1
(.clk(clk), .reset_n(reset_n), .sw(!key[1]), 
	 .db_level(key_db[1]));


db_fsm db_fsm_inst_2
(.clk(clk), .reset_n(reset_n), .sw(!key[2]), 
	 .db_level(key_db[2]));

db_fsm db_fsm_inst_3
(.clk(clk), .reset_n(reset_n), .sw(!key[3]), 
	 .db_level(key_db[3]));

vga_sync vga_sync_inst
(.clk(clk), .rst_n(reset_n), .hsync(vga_hsync), .vsync(vga_vsync), .pixel_x(pixel_x), .pixel_y(pixel_y),
	.video_on(video_on));

bitmap_gen bitmap_gen_inst
(	.clk(clk),.reset_n(reset_n),
	.video_on(video_on),
	.key(key_db),
	.pixel_x(pixel_x),.pixel_y(pixel_y),
	.rgb(rgb_next)
);

always @(posedge clk or negedge reset_n)
begin
	if(~reset_n)
		rgb_reg <= 0;
	else
		rgb_reg <= rgb_next;
end
assign vga_rgb = rgb_reg;
endmodule