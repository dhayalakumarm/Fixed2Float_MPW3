module gls;
parameter in = 19;			// input resolution
parameter man = 23;			// Mantisa resolution in bits without hidden bit
parameter exp = 8;			// Exponent Resolution
reg [in-1:0] a;

wire [exp+man:0] b;
wire zro;

fxd2flot u1 (a, b, zro);

initial
begin
a=19'd 1024;
# 10 a= 19'd 65536;
# 10 a=19'd 123456;
	  
#100 $finish;
end

initial 
begin
	$dumpfile("fxd2float.vcd");
	$dumpvars(0, gls);
	//$monitor("time = %2d, in1 = %d, in2 = %d, out = %d", $time, in1, in2, out);
end
endmodule