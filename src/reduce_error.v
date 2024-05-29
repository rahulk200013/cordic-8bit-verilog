// This module improves the accuracy of cos and sin after rounding off,
// by comparing the rounded off value with actual value and based on this 
// error, cos and sin are increased or decreased by 0.0000001

module improveAccuracy(x_cosine, y_sine, cos_rounded, sin_rounded, error_cos, error_sin);
output reg [7:0] x_cosine, y_sine;
input [7:0] cos_rounded, sin_rounded;
input [17:0] error_cos, error_sin;

// Detrmine -ve of cos and sin error
wire [17:0] error_cos_neg, error_sin_neg;

assign error_cos_neg = 18'b0 - error_cos;
assign error_sin_neg = 18'b0 - error_sin;

//Wires for intermediate connections
wire a,b,c,d,e,f,g,h;
wire i,j,k,l,m,n,o,p;

wire sin_neg_error_big_enough, cos_neg_error_big_enough;

//Determine if error is big enough to make change in cos
//or pass it as it is if error in cos is -ve
nor(a,error_cos_neg[8],error_cos_neg[9]);
nor(b,error_cos_neg[10],error_cos_neg[11]);
nor(c,error_cos_neg[12],error_cos_neg[13]);
nor(d,error_cos_neg[14],error_cos_neg[15]);

and(f,a,b);
and(g,c,d);
nand(cos_neg_error_big_enough, f,g);


//Determine if error is big enough to make change in sin
//or pass it as it is if error in sin is -ve
nor(i,error_sin_neg[8],error_sin_neg[9]);
nor(j,error_sin_neg[10],error_sin_neg[11]);
nor(k,error_sin_neg[12],error_sin_neg[13]);
nor(l,error_sin_neg[14],error_sin_neg[15]);

and(n,i,j);
and(o,k,l);
nand(sin_neg_error_big_enough, n,o);


always @ (*) begin

//////////////////////////////////////////////////////////////////////////////////////////////////
////////////                      Improve accuracy of Cosine                          ////////////
//////////////////////////////////////////////////////////////////////////////////////////////////

//If cos is 0.992188, pass it as it is
if(cos_rounded == 8'b0_1111111)
x_cosine <= cos_rounded;

//If error in cos is +ve
else if(error_cos[17] == 0) begin
//If +ve error is big enough to make changes in cos otherwise pass it as it is.
if(error_cos[8] == 1) begin
//If input cos is +ve, add 0.0000001 otherwise subtract 0.0000001
if(cos_rounded[7] == 0)
x_cosine <= cos_rounded + 8'b0_0000001;
else
x_cosine <= cos_rounded - 8'b0_0000001;
end
else
x_cosine <= cos_rounded;
end

//If error in cos is -ve
else begin
if(cos_neg_error_big_enough) begin
//If input cos is +ve, subtract 0.0000001 otherwise add 0.0000001
if(cos_rounded[7] == 0) 
x_cosine <= cos_rounded - 8'b0_0000001;
else
x_cosine <= cos_rounded + 8'b0_0000001;
end
//If error in cos is not big enough, pass it as it is
else
x_cosine <= cos_rounded;
end

//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////////////////////////
////////////                      Improve accuracy of Sine                          ////////////
//////////////////////////////////////////////////////////////////////////////////////////////////

//If sine is 0.992188, pass it as it is
if(sin_rounded == 8'b0_1111111)
y_sine <= sin_rounded;

//If sine is -1, pass it as it is
else if(sin_rounded == 8'b1_0000000)
y_sine <= sin_rounded;

//If error in sine +ve
else if(error_sin[17] == 0) begin
//If error is big enough, add 0.0000001 otherwise pass it as it is
if(error_sin[8] == 1)
y_sine <= sin_rounded + 8'b0_0000001;
else
y_sine <= sin_rounded;
end

//If error in sin -s -ve
else begin
//If error is big enough, subtract 0.0000001, otherwise pass it as it is
if(sin_neg_error_big_enough)
y_sine <= sin_rounded - 8'b0_0000001;
else
y_sine <= sin_rounded;
end

//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////


end

endmodule 
