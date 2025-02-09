`timescale 1ns / 1ps

module fp_mul#(
    parameter i1 = 2,
    parameter f1 = 14,
    parameter i2 = 2,
    parameter f2 = 14,
    parameter i3 = 2,
    parameter f3 = 14
  )(
    input [i1+f1-1 :0] a,
    input s1,
    input [i2+f2-1 :0] b,
    input s2,
    output [i3+f3-1 :0] c,
    output sign,
    output reg overflow,
    output reg underflow
  );
  localparam ideal_i=i1+i2;
  localparam ideal_f=f1+f2;
  localparam ideal_width=ideal_i+ideal_f;
  //localparam shift=ideal_f-f3;
  localparam total_ofbits=ideal_i-i3+1;
  localparam total_ufbits=ideal_f-f3;
  reg [i3+f3-1 :0] c_ref;
  reg [ideal_width-1 :0] ideal,ta,tb;    //4.28

  reg overflow_may = ideal_i>i3;
  reg underflow_may = ideal_f>f3;

  assign sign = s1 || s2;

  always_comb
  begin
    if (sign)
    begin
      if (s1)
        ta = $signed(a);
      else
        ta = a;
      if (s2)
        tb = $signed(b);
      else
        tb = b;
      ideal=$signed(ta) * $signed(tb);

overflow = overflow_may?ideal[ideal_width - 1]? (~&ideal[ideal_width - 1 -: total_ofbits] == ideal[ideal_width - 1]):|ideal[ideal_width - 1:ideal_width -ideal_i+i3-1]:0;
underflow = underflow_may?|$signed(ideal[ideal_width-ideal_i-1+i3:ideal_f-f3])?0:|$signed(ideal[ideal_f-f3-1:0]):0;

c_ref=overflow?ideal[ideal_width - 1]?{{i3+f3}{1'b0}}:{{i3+f3}{1'b1}}:$signed(ideal[ideal_width-ideal_i-1+i3:ideal_f-f3]);
    end
    else
    begin

      ideal=a*b;
      overflow=overflow_may?ideal[ideal_width-1]:0;
underflow = underflow_may?|ideal[ideal_width-ideal_i-1+i3:ideal_f-f3]?0:|ideal[ideal_f-f3-1:0]:0;
      c_ref=overflow?{{i3+f3}{1'b1}}:ideal[ideal_width-ideal_i+i3-1:ideal_f-f3];
    end



  end

  assign c = c_ref;

endmodule
