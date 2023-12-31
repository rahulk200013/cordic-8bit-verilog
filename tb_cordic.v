// Test bench for cordic algorithm.
//Simulation time must be atleat 2400ps to see full output
//Latency: 15 cycles

module cordic_tb;
reg signed [7:0] in_angle;
reg clk,rst;
wire [7:0] x_cosine;
wire signed [7:0] y_sine;
wire signed [17:0] error_cos_wire, error_sine_wire, orig_x_wire, orig_y_wire;


real cosine, sine, angle;

//reg [128:0] count;
    
cordic8bit DUT(x_cosine, y_sine, in_angle,clk,rst);

always #5 clk = ~clk;

integer j;

initial begin

//This marks the start of output in console
$display ("                                                                          ");
$display ("##########################################################################");
$display ("##########################################################################");
$display ("                                                                          ");

//Set evrything to 0 initially
angle = 0;
rst = 0;
clk = 0;

#20
//Enable circuit after 20 ps.
rst = 1;

//Sweep input angle from -89.524655 to +89.524655 degrees
for(j=0; j<217; j=j+1) begin
#10
if(j<1)
in_angle = 8'b10_011100;
else
in_angle = in_angle + 8'b00_000001;
end

end


always @ (posedge clk) begin

//Determine fractional decimal value of Cosine
if(x_cosine[7] == 0)
cosine = (x_cosine*(2.0**-7));
else
cosine = -(-{1'b1, x_cosine}*(2.0**-7));

//Determine fractional decimal value of Sine
if(y_sine[7] == 0)
sine = (y_sine*(2.0**-7));
else
sine = -(-{1'b1, y_sine}*(2.0**-7));

//Determin input angle in degrees
if(in_angle[7] == 0)
angle = ((in_angle*(2.0**-6))*180/3.141592654) - (15*0.895246555) ;
else
angle = (-(-in_angle*(2.0**-6)*180/3.141592654)) - (15*0.895246555);


//Display output after 15 clock cycle.
if(j>15 && j < 217)
$display (" %f, %f, %f", angle, cosine, sine); 
//$display ("Input Angle(Deg): %f,   Cosine: %f,    Sine: %f", angle, cosine, sine); 

//If angle sweep is finished
if(j == 216) begin
$display ("                                                                          ");
$display ("##########################################################################");
$display ("##########################################################################");
$display ("                                                                          ");
end

end

endmodule
