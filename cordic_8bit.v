// Cordic algorithm of 10 iterations
// Input angle is taken in form 1 sign + 1 integer + 6 fractional bits
// Output is given in form of 1 sign + 7 fractional bits

module cordic8bit(x_cosine, y_sine, in_angle,clk,rst);
output reg [7:0] x_cosine, y_sine;
input [7:0] in_angle;
input clk,rst;

//Wire output after improving accuracy for all 3 iterations
wire [7:0] x_cosine_wire [3:0], y_sine_wire [3:0];

//Direction(+ve/-ve) after each iteration in cordic
reg [9:0] dir;

//x,y and z after each iteration in cordic
reg signed [17:0] x [12:0];
reg signed [17:0] y [12:0];
reg signed [17:0] z [11:0];

//cos and sin after rounding off to 1 sign + 7 fractional bits
wire [7:0] cos_rounded_wire, sin_rounded_wire;

//cos and sin after improving accuracy for all 3 iterations of improving accuracy
reg [7:0] cos_rounded_reg [3:0], sin_rounded_reg [3:0];

//x(cos) and y(sin) and z if we go in positive direction
wire [10:0] dir_pos;
wire [17:0] x_wire_pos [10:0];
wire [17:0] y_wire_pos [10:0];
wire [17:0] z_wire_pos [10:0];

//x(cos) and y(sin) and z if we go in negative direction
wire [10:0] dir_neg;
wire [17:0] x_wire_neg [10:0];
wire [17:0] y_wire_neg [10:0];
wire [17:0] z_wire_neg [10:0];

//Error in cos and sin for all 3 iteration of improving accuracy
reg [17:0] error_cos [3:0] , error_sin [3:0];

//To store arctan lookup table
wire [17:0] arctan [9:0];

//Arctan lookup table 
assign arctan[0] = 18'b00_1100_1001_0000_1111;   // 0.7853851318359375
assign arctan[1] = 18'b00_0111_0110_1011_0001;   // 0.4636383056640625
assign arctan[2] = 18'b00_0011_1110_1011_0110;   // 0.2449645996093750
assign arctan[3] = 18'b00_0001_1111_1101_0101;   // 0.1243438720703125
assign arctan[4] = 18'b00_0000_1111_1111_1010;   // 0.0624084472656250
assign arctan[5] = 18'b00_0000_0111_1111_1111;   // 0.0312347412109375
assign arctan[6] = 18'b00_0000_0011_1111_1111;   // 0.0156097412109375
assign arctan[7] = 18'b00_0000_0001_1111_1111;   // 0.0077972412109375
assign arctan[8] = 18'b00_0000_0000_1111_1111;   // 0.0038909912109375
assign arctan[9] = 18'b00_0000_0000_0111_1111;   // 0.0019378662109375

genvar i;

//Determine x and y for all directions(+ve or -ve)
//We will use the correct value depending on actual direction in always block
for(i=0; i<10; i=i+1) begin

assign x_wire_pos[i+1] = x[i] - (y[i]>>>i);
assign y_wire_pos[i+1] = y[i] + (x[i]>>>i);
assign z_wire_pos[i+1] = z[i] - (arctan[i]);
assign dir_pos[i+1] = z_wire_pos[i+1][17];

assign x_wire_neg[i+1] = x[i] + (y[i]>>>i);
assign y_wire_neg[i+1] = y[i] - (x[i]>>>i);
assign z_wire_neg[i+1] = z[i] + (arctan[i]);
assign dir_neg[i+1] = z_wire_neg[i+1][17]; 

end

//Round off x(cos) and y(sin) after 10th iteration in cordic
round_off cos( x[10], cos_rounded_wire);
round_off sin( y[10], sin_rounded_wire);

//3 iterations to reduce error in cos and sin after cordic.
improveAccuracy x0(x_cosine_wire[0], y_sine_wire[0], cos_rounded_reg[0], sin_rounded_reg[0], error_cos[0], error_sin[0]);
improveAccuracy x1(x_cosine_wire[1], y_sine_wire[1], cos_rounded_reg[1], sin_rounded_reg[1], error_cos[1], error_sin[1]);
improveAccuracy x2(x_cosine_wire[2], y_sine_wire[2], cos_rounded_reg[2], sin_rounded_reg[2], error_cos[2], error_sin[2]);

//Integer to use in always block
integer j;

always @ (posedge clk) begin

//Reset everything (Active Low Reset)
if(!rst) begin

dir <= 0;

for(j=0; j<4; j=j+1) begin
error_cos[j] <= 'b0;
error_sin[j] <= 'b0;
cos_rounded_reg[j] <= 'b0;
sin_rounded_reg[j] <= 'b0;
end

//Initialize x,y and z so that we don't need to multiply the result after 10th iteration
//of cordic to get actual cos and sin.
x[0] <= 18'b00_1001101110000000;  //initial (0.607421875)
y[0] <= 18'b00_0000000000000000;
z[0] <= 18'b00_0000000000000000;

for(j=1; j<12; j=j+1) begin
x[j] <= 'b0;
y[j] <= 'b0;
z[j] <= 'b0;
end

end

//When no reset is given, start cordic algorithm
else begin

//Get initial direction based on MSB of input angle
dir[0] <= in_angle[7];

//Pad input angle with 0 after LSB to make it 18 bit in size.
z[0] <= {in_angle, 10'b0};

//Start cordic algorithm
for(j=0; j<10; j=j+1) begin

//If we need to go in +ve direction
if(dir[j] == 0) begin
x[j+1] <= x_wire_pos[j+1];
y[j+1] <= y_wire_pos[j+1];
z[j+1] <= z_wire_pos[j+1];
if(j<9)
dir[j+1] <= dir_pos[j+1];
end

//If we need to go in -ve direction
else begin
x[j+1] <= x_wire_neg[j+1];
y[j+1] <= y_wire_neg[j+1];
z[j+1] <= z_wire_neg[j+1];
if(j<9)
dir[j+1] <= dir_neg[j+1];
end

end

//Store last value of cos and sin after cordic so that they
//can be used to detrmine error in 3 iteration of improving accuracy
x[11] <= x[10];
y[11] <= y[10];

x[12] <= x[11];
y[12] <= y[11];


//////////////////////////////////////////////////////////////////////////////////////////////////
////////////                   1st iteration to improve accuracy                      ////////////
//////////////////////////////////////////////////////////////////////////////////////////////////

//Determine error in cos and sin for 1st iteration of improving accuracy
error_cos[0] <= x[10] - {1'b0, cos_rounded_wire, 9'b0};
//Pad sin with 0 in front of MSB and with 0 after LSB if sine is +ve to make it 18 bit in size
if(sin_rounded_wire[7] == 0)
error_sin[0] <= y[10] - {1'b0, sin_rounded_wire, 9'b0};
else
//Pad sin with 1 in front of MSB and with 0 after LSB if sine is -ve to make it 18 bit in size
error_sin[0] <= y[10] - {1'b1, sin_rounded_wire, 9'b0};
//Send cos and sin value of last stage to 1st iteration of improving accuracy
cos_rounded_reg[0] <= cos_rounded_wire;
sin_rounded_reg[0] <= sin_rounded_wire;

//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////
////////////                   2nd iteration to improve accuracy                      ////////////
//////////////////////////////////////////////////////////////////////////////////////////////////

//Determine error in cos and sin for 2nd iteration of improving accuracy
error_cos[1] <= x[11] - {1'b0, x_cosine_wire[0], 9'b0};
//Pad sin with 0 in front of MSB and with 0 after LSB if sine is +ve to make it 18 bit in size
if(y_sine_wire[0][7] == 0)
error_sin[1] <= y[11] - {1'b0, y_sine_wire[0], 9'b0};
else
//Pad sin with 1 in front of MSB and with 0 after LSB if sine is -ve to make it 18 bit in size
error_sin[1] <= y[11] - {1'b1, y_sine_wire[0], 9'b0};
//Send cos and sin value of last stage to 2nd iteration of improving accuracy
cos_rounded_reg[1] <= x_cosine_wire[0];
sin_rounded_reg[1] <= y_sine_wire[0];

//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////
////////////                   3rd iteration to improve accuracy                      ////////////
//////////////////////////////////////////////////////////////////////////////////////////////////

//Determine error in cos and sin for 3rd iteration of improving accuracy
error_cos[2] <= x[12] - {1'b0, x_cosine_wire[1], 9'b0};
//Pad sin with 0 in front of MSB and with 0 after LSB if sine is +ve to make it 18 bit in size
if(y_sine_wire[1][7] == 0)
error_sin[2] <= y[12] - {1'b0, y_sine_wire[1], 9'b0};
else
//Pad sin with 1 in front of MSB and with 0 after LSB if sine is -ve to make it 18 bit in size
error_sin[2] <= y[12] - {1'b1, y_sine_wire[1], 9'b0};
//Send cos and sin value of last stage to 3rd iteration of improving accuracy
cos_rounded_reg[2] <= x_cosine_wire[1];
sin_rounded_reg[2] <= y_sine_wire[1];

//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////


//Assign final value of cos and sin to output registers
x_cosine <= x_cosine_wire[2];
y_sine <= y_sine_wire[2];

end

end

endmodule


