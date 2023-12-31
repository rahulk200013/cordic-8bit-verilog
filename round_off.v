//Round-off circuit used to round-off the 16 fractional bits of the output to 7 bits of fractional part//

//If the in[8] bit is equal to 0 then the number is rounded down.//
//If the in[8] bit is equal to 1 and there is atleast one 1 in the following bits then the number is rounded up.//
//If the in[8] bit is equal to 1 and all the following bits are 0, then it is condition of tie break which is resolved by even-ties 
//In the last case, if in[9] is 0 then the number is rounded down and if it is 1 then the number is rounded up.
//This is realised by the following combinational logic.

module round_off(in, out);
input [17:0] in;                 //11-bit input                   
output [7:0] out;               //8-bit output

//Wire for ouput if no overflow takes place
wire [7:0] out_normal, out_normal_temp;

//Wire for positve overflow, -ve overflow and final output overflow value based on input.
wire [7:0] out_overflow_positive, out_overflow_negative, out_overflow;

//Wire for intermediate connections
wire a, b, c, d, e, f, g, h, i, k, l, m;

//Some Flags
wire following_bits_or, round_down_flag, overflow_flag, overflow_and_nagative;
wire [8:0] rounded_down, rounded_up;

//Determine if we need to round down or not
nor(a,in[7],in[6]);
nor(b,in[5],in[4]);
nor(c,in[3],in[2]);
nor(d,in[1],in[0]);
and(e,a,b);
and(f,c,d);
nand(following_bits_or,e,f); //following_bits_or flag tells us if there is any bit 1 before 8th bit of input
not(g,following_bits_or);
not(h,in[9]);
nand(i,g,h);
nand(round_down_flag, i, in[8]);

//Pre calculate rounded down and rounded up value
assign rounded_down = in[17:9];
assign rounded_up = in[17:9] + 1'b1;

//Output value in case of overflow
assign out_overflow_positive = 8'b01111111;
assign out_overflow_negative = 8'b10000000;

//Determine output based on round down flag. In this step we remove the integer bit,
//and keep only the sign bit so that we can have 7 fractional bits instead of 6 in final
//output for better accuracy
mux2to1 m1(out_normal_temp[7], round_down_flag, rounded_down[8], rounded_up[8]);
mux2to1 m2(out_normal_temp[6], round_down_flag, rounded_down[6], rounded_up[6]);
mux2to1 m3(out_normal_temp[5], round_down_flag, rounded_down[5], rounded_up[5]);
mux2to1 m4(out_normal_temp[4], round_down_flag, rounded_down[4], rounded_up[4]);
mux2to1 m5(out_normal_temp[3], round_down_flag, rounded_down[3], rounded_up[3]);
mux2to1 m6(out_normal_temp[2], round_down_flag, rounded_down[2], rounded_up[2]);
mux2to1 m7(out_normal_temp[1], round_down_flag, rounded_down[1], rounded_up[1]);
mux2to1 m8(out_normal_temp[0], round_down_flag, rounded_down[0], rounded_up[0]);

//Set ouput to 0.992188, in case after rounding off value is 01.0000000. This is done,
//because after removing integer bit in last step 01.0000000 will becom 0.0000000 which
//we do not want. In other case, pass it as it is.
mux2to1 mm1(out_normal[7], (~rounded_up[8]&&rounded_up[7]), out_normal_temp[7], 1'b0);
mux2to1 mm2(out_normal[6], (~rounded_up[8]&&rounded_up[7]), out_normal_temp[6], 1'b1);
mux2to1 mm3(out_normal[5], (~rounded_up[8]&&rounded_up[7]), out_normal_temp[5], 1'b1);
mux2to1 mm4(out_normal[4], (~rounded_up[8]&&rounded_up[7]), out_normal_temp[4], 1'b1);
mux2to1 mm5(out_normal[3], (~rounded_up[8]&&rounded_up[7]), out_normal_temp[3], 1'b1);
mux2to1 mm6(out_normal[2], (~rounded_up[8]&&rounded_up[7]), out_normal_temp[2], 1'b1);
mux2to1 mm7(out_normal[1], (~rounded_up[8]&&rounded_up[7]), out_normal_temp[1], 1'b1);
mux2to1 mm8(out_normal[0], (~rounded_up[8]&&rounded_up[7]), out_normal_temp[0], 1'b1);


//Pre calculate correct overflown output in case after rounding up there is an overflow
//In case input was already positve, pass out_overflow_positive otherwise,
// pass out_overflow_negative. This is determined by sign bit of input.
mux2to1 x1(out_overflow[7], in[17], out_overflow_positive[7], out_overflow_negative[7]);
mux2to1 x2(out_overflow[6], in[17], out_overflow_positive[6], out_overflow_negative[6]);
mux2to1 x3(out_overflow[5], in[17], out_overflow_positive[5], out_overflow_negative[5]);
mux2to1 x4(out_overflow[4], in[17], out_overflow_positive[4], out_overflow_negative[4]);
mux2to1 x5(out_overflow[3], in[17], out_overflow_positive[3], out_overflow_negative[3]);
mux2to1 x6(out_overflow[2], in[17], out_overflow_positive[2], out_overflow_negative[2]);
mux2to1 x7(out_overflow[1], in[17], out_overflow_positive[1], out_overflow_negative[1]);
mux2to1 x8(out_overflow[0], in[17], out_overflow_positive[0], out_overflow_negative[0]);

//Determine if there is an actual overflow or not
xor(overflow_flag,in[17],in[16]);

//Assign final output based on if there is an overflow or not
mux2to1 y1(out[7], overflow_flag, out_normal[7], out_overflow[7]);
mux2to1 y2(out[6], overflow_flag, out_normal[6], out_overflow[6]);
mux2to1 y3(out[5], overflow_flag, out_normal[5], out_overflow[5]);
mux2to1 y4(out[4], overflow_flag, out_normal[4], out_overflow[4]);
mux2to1 y5(out[3], overflow_flag, out_normal[3], out_overflow[3]);
mux2to1 y6(out[2], overflow_flag, out_normal[2], out_overflow[2]);
mux2to1 y7(out[1], overflow_flag, out_normal[1], out_overflow[1]);
mux2to1 y8(out[0], overflow_flag, out_normal[0], out_overflow[0]);

endmodule
