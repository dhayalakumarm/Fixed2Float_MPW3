//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                  Company              :   SMDP-C2SD                                                      //
//                  Create Date          :   10 AUG 2021                                                    //
//                  Design Name          :   Feature Extraction Engine                                      //
//                  Target Devices       :   ASIC (SCL-180nm)    :   ZedBoard (FPGA-ZC702)                  //
//                  Tool versions        :   Cadence Genus       :   Vivado                                 //
//                                                                                                          //
//                  Design Engineer      :   DHAYALAKUMAR M & SKANDHA DEEPSITA S                            //
//                  Project Co-Ordinator :   Dr NOOR MAHAMMAD SK                                            //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*	
	Exponent	Mantissa	Object
	0 			0 			Zero
	0 			Nonzero 	Denormalized number*
	1-254 		Anything 	+/- FP number
	255 		0 			+ / - infinity
	255 		Nonzero 	NaN
	
	
	
	Type							Sign	Actual Exp		Exp (biased)	Exponent field	Fraction field					Value
	Zero							0		−126			0				0000 0000		000 0000 0000 0000 0000 0000	0.0
	Negative zero					1		−126			0				0000 0000		000 0000 0000 0000 0000 0000	−0.0
	One								0		0				127				0111 1111		000 0000 0000 0000 0000 0000	1.0
	Minus One						1		0				127				0111 1111		000 0000 0000 0000 0000 0000	−1.0
	Smallest denormalized number	*		−126			0				0000 0000		000 0000 0000 0000 0000 0001	±2−23 × 2−126 = ±2−149 ≈ ±1.4×10−45
	"Middle" denormalized number	*		−126			0				0000 0000		100 0000 0000 0000 0000 0000	±2−1 × 2−126 = ±2−127 ≈ ±5.88×10−39
	Largest denormalized number		*		−126			0				0000 0000		111 1111 1111 1111 1111 1111	±(1−2−23) × 2−126 ≈ ±1.18×10−38
	Smallest normalized number		*		−126			1				0000 0001		000 0000 0000 0000 0000 0000	±2−126 ≈ ±1.18×10−38
	Largest normalized number		*		127				254				1111 1110		111 1111 1111 1111 1111 1111	±(2−2−23) × 2127 ≈ ±3.4×1038
	Positive infinity				0		128				255				1111 1111		000 0000 0000 0000 0000 0000	+∞
	Negative infinity				1		128				255				1111 1111		000 0000 0000 0000 0000 0000	−∞
	Not a number					*		128				255				1111 1111		non zero						NaN
*/

module fxd2flot(a, b, zro);

parameter in = 19;			// input resolution
parameter man = 23;			// Mantisa resolution in bits without hidden bit
parameter exp = 8;			// Exponent Resolution

input [in-1:0] a;			// 1 18 (sign Magnitude)
output [exp+man:0] b;		// Floating Point 1 8 23;
output zro;

wire [4:0] o;
wire [7:0] o1;
wire x;

pe24 t({{(man-in+2){1'b0}}, a[in-2:0]}, o, zro);

assign b[exp+man] = a[in-1];
assign o1 = zro ? {3'b0, o} : 8'd255;
adder #(exp) t0(8'd127, o1, 1'b0, {x, b[man+exp-1:man]}); 
assign b[man-1:0] = {{(man-in+2){1'b0}}, a[in-2:0]}<<(5'd23-o);

endmodule

`define DSPoperator

module adder(p, q, mode, sum);

parameter num = 25;

output [num:0] sum;
input [num-1:0] p,q;
input mode;

wire [num:0] temp, temp1;

`ifdef DSPoperator
wire [num:0] temp2, temp3;
    assign temp2[num:0] = p[num-1] ? -{2'b0, p[num-2:0]}:{1'b0,p};
    assign temp3[num:0] = q[num-1] ? -{2'b0, q[num-2:0]}:{1'b0,q};
    assign temp[num:0] = mode ? temp2-temp3 : temp2+temp3;
`else
    wire [2*num+1:0] x [0:$clog2(num+1)];
    wire [num:0] a1, b1, a, b;

    assign a1 = {(num+1){p[num-1]}}^{2'b0, p[num-2:0]};
    assign b1 = {(num+1){mode^q[num-1]}}^{2'b0, q[num-2:0]};
    assign a[0] = a1[0];
    assign b[0] = b1[0];
    assign b[1] = p[num-1]&(q[num-1]^mode);
    assign a[num] = a1[num]^b1[num];

    assign x[0][1:0]={2{p[num-1]^q[num-1]^mode}};  					// Input carry

    genvar i, j;
    generate
    begin:ha_fa			//halfadder
        for(i=1; i<num; i=i+1) begin
        halfadd t0({a1[i],b1[i]}, a[i], b[i+1]);
        end
    end

    begin: kgp_gen		// kgp generation
        for (i=0; i<num; i=i+1) begin
        kgp t(a[i], b[i], x[0][2*i+3:2*i+2]);
        end
    end
    begin:recursiveStg	//recursive
        for (i=0; i<$clog2(num+1); i=i+1)
        begin
        assign x[i+1][(2**(i+1))-1:0]=x[i][(2**(i+1))-1:0];
            for(j=(2**(i+1)); j<2*num+1; j=j+2)
            begin
            recursive_stage1 s(x[i][j+1-(2**(i+1)):j-(2**(i+1))],x[i][j+1:j],x[i+1][j+1:j]);		
            end
        end
    end
    begin:addition		// SUM Calculation
        for(i=0; i<num+1; i=i+1) begin
        assign temp[i] = a[i]^b[i]^x[$clog2(num)][2*i];
        end
    end
    endgenerate
`endif
    assign temp1 = -temp;
    assign sum = temp[num] ? ({temp[num], temp1[num-1:0]}) : (temp);

endmodule

`ifdef DSPoperator

`else

    module kgp(a,b,y);

    input a,b;						output [1:0] y;

    assign y[0]=a | b;
    assign y[1]=a & b;

    endmodule



    module recursive_stage1(a,b,y);

    input [1:0] a,b;				output [1:0] y;

    wire [1:0] y;
    wire b0;
    not n1(b0,b[1]);
    wire f,g0,g1;
    and a1(f,b[0],b[1]);
    and a2(g0,b0,b[0],a[0]);
    and a3(g1,b0,b[0],a[1]);

    or o1(y[0],f,g0);
    or o2(y[1],f,g1);

    endmodule

    module halfadd(x, sum, carry);

output sum,carry;
input [1:0] x;

	assign	 sum = x[1] ^ x[0];
	assign 	 carry = x[1] & x[0];
	
endmodule



module fulladd(x, sum, carry);

output sum,carry;
input [2:0] x;

wire w;	
	assign 	 w = x[2] ^ x[1];
        assign	 sum = w ^ x[0];
	assign 	 carry = (x[2] & x[1])|(w & x[0]);
endmodule
`endif

module pe24(a,b,az);

input [23:0] a;
output [4:0] b;
output az;

wire [17:0] o;
wire [4:0] o1;
wire [7:0] o2;

	pe4 t0(a[3:0],o[1:0],o[12]);
	pe4 t1(a[7:4],o[3:2],o[13]);
	pe4 t2(a[11:8],o[5:4],o[14]);
	pe4 t3(a[15:12],o[7:6],o[15]);
	pe4 t4(a[19:16],o[9:8],o[16]);
	pe4 t5(a[23:20],o[11:10],o[17]);
	
	
	pe4 t6(o[15:12], o1[1:0], o1[3]);
	assign o1[2] = o[17];
	assign o1[4] = |o[17:16];
	
	mux4x1 t7(o1[1:0], o[7:0], o2[3:0]);
	assign o2[5:4] = o1[2] ? o[11:10]:o[9:8];
	assign o2[7:6] = {1'b0, o1[2]};
	assign b[4] = o1[4];
	assign b[3:0] = o1[4] ? o2[7:4] : o2[3:0];
	assign az = o1[4] ? o1[4] : o1[3];

endmodule

module pe4(a,b,o);

input [3:0] a;
output [1:0] b;
output o;

assign o = |a;
assign b[1] = |a[3:2];
assign b[0] = b[1] ? (a[3]) : (a[1]);

endmodule


module mux4x1(sel, a , y);
parameter n=2;

input [4*n-1:0] a;
input [1:0] sel;
output [n+1:0] y;

wire [n-1:0] y1;

assign y1 = sel[1] ? (sel[0] ? (a[4*n-1:3*n]) : (a[3*n-1:2*n])) : (sel[0] ? (a[2*n-1:n]) : (a[n-1:0]));
assign y = {sel, y1};

endmodule
