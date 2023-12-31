module mux2to1(out, sel, in1 ,in2);
output out;
input sel,in1,in2;

//Intermediate wires for connection
wire a,b,c;

//Pass in1 if sel=0 otherwise pass in2
not(a,sel);
nand(b,in1,a);
nand(c,sel,in2);
nand(out,b,c);

endmodule
