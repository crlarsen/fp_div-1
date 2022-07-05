`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2022 08:48:38 AM
// Design Name: 
// Module Name: fp_div_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module fp_div_tb();
  localparam NEXP = 5;
  localparam NSIG = 10;
  `include "ieee-754-flags.vh"
  reg [NEXP+NSIG:0] a, b;
  // roundTiesToEven roundTowardZero roundTowardPositive roundTowardNegative
  reg [NRAS:0] ra = 1 << roundTiesToEven;
  wire [NEXP+NSIG:0] q;
  wire [NTYPES-1:0] qFlags;
  wire [NEXCEPTIONS-1:0] exception;
  
  integer i, j;

  initial
  begin
      $display("Test division circuit for binary%0d, %0s:", NEXP+NSIG+1,
              ra[roundTiesToEven] ? "roundTiesToEven" :
                (ra[roundTowardZero] ? "roundTowardZero" :
                  (ra[roundTowardPositive] ? "roundTowardPositive" :
                    (ra[roundTowardNegative] ? "roundTowardNegative" :
                      (ra[roundTiesToAway] ? "roundTiesToAway" : "NO VALID ROUNDING MODE")))));
                      
    // For these tests a is always a signalling NaN.
    $display("\nsNaN / {sNaN, qNaN, infinity, zero, subnormal, normal}:");
    #0  a = {1'b0, {NEXP{1'b1}}, 1'b0, ({NSIG-1{1'b0}} | 4'hA)};
        b = {1'b0, {NEXP{1'b1}}, 1'b0, ({NSIG-1{1'b0}} | 4'hB)};
    #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
    b = {1'b0, {NEXP{1'b1}}, 1'b1, ({NSIG-1{1'b0}} | 4'hB)};
    #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
    b = {1'b0, {NEXP{1'b1}}, {NSIG{1'b0}}};
    #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
    b = {1'b0, {NEXP{1'b0}}, {NSIG{1'b0}}};
    #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
    b = {1'b0, {NEXP{1'b0}}, ({NSIG{1'b0}} | 4'hB)};
    #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
    b = {1'b0, 1'b0, {NEXP-1{1'b1}}, ({NSIG{1'b0}} | 4'hB)};
    #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);

    // For these tests b is always a signalling NaN.
    $display("\n{qNaN, infinity, zero, subnormal, normal} / sNaN:");
    b = {1'b0, {NEXP{1'b1}}, 1'b0, ({NSIG-1{1'b0}} | 4'hB)};
    a = {1'b0, {NEXP{1'b1}}, 1'b1, ({NSIG-1{1'b0}} | 4'hA)};
    #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
    a = {1'b0, {NEXP{1'b1}}, {NSIG{1'b0}}};
    #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
    a = {1'b0, {NEXP{1'b0}}, {NSIG{1'b0}}};
    #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
    a = {1'b0, {NEXP{1'b0}}, ({NSIG{1'b0}} | 4'hA)};
    #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
    a = {1'b0, 1'b0, {NEXP-1{1'b1}}, ({NSIG{1'b0}} | 4'hA)};
    #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);

    // For these tests a is always a quiet NaN.
    $display("\nqNaN / {qNaN, infinity, zero, subnormal, normal}:");
    a = {1'b0, {NEXP{1'b1}}, 1'b1, ({NSIG-1{1'b0}} | 4'hA)};
    b = {1'b0, {NEXP{1'b1}}, 1'b1, ({NSIG-1{1'b0}} | 4'hB)};
    #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
    b = {1'b0, {NEXP{1'b1}}, {NSIG{1'b0}}};
    #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
    b = {1'b0, {NEXP{1'b0}}, {NSIG{1'b0}}};
    #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
    b = {1'b0, {NEXP{1'b0}}, ({NSIG{1'b0}} | 4'hB)};
    #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
    b = {1'b0, 1'b0, {NEXP-1{1'b1}}, ({NSIG{1'b0}} | 4'hB)};
    #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);

    // For these tests b is always a quiet NaN.
    $display("\n{infinity, zero, subnormal, normal} / qNaN:");
    b = {1'b0, {NEXP{1'b1}}, 1'b1, ({NSIG-1{1'b0}} | 4'hB)};
    a = {1'b0, {NEXP{1'b1}}, {NSIG{1'b0}}};
    #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
    #10 a = {1'b0, {NEXP{1'b0}}, {NSIG{1'b0}}};
    #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
    #10 a = {1'b0, {NEXP{1'b0}}, ({NSIG{1'b0}} | 4'hA)};
    #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
    #10 a = {1'b0, 1'b0, {NEXP-1{1'b1}}, ({NSIG{1'b0}} | 4'hA)};
    #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);

    // Test signed multiplication of Infinity:
    for (i = 0; i < 2; i = i + 1)
      for (j = 0; j < 2; j = j + 1)
        begin
          // For these tests a is always Infinity.
          $display("\n%sinfinity / {%sinfinity, %szero, %ssubnormal, %snormal}:", (i ? "-" : "+"), (j ? "-" : "+"), (j ? "-" : "+"), (j ? "-" : "+"), (j ? "-" : "+"));
          a = {1'b0, {NEXP{1'b1}}, {NSIG{1'b0}}} | (i << NEXP+NSIG);
          b = {1'b0, {NEXP{1'b1}}, {NSIG{1'b0}}} | (j << NEXP+NSIG);
          #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
          b = {1'b0, {NEXP{1'b0}}, {NSIG{1'b0}}} | (j << NEXP+NSIG);
          #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
          b = {1'b0, {NEXP{1'b0}}, ({NSIG{1'b0}} | 4'hB)} | (j << NEXP+NSIG);
          #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
          b = {1'b0, 1'b0, {NEXP-1{1'b1}}, ({NSIG{1'b0}} | 4'hB)} | (j << NEXP+NSIG);
          #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);

          // For these tests b is always Infinity.
          $display("\n{%szero, %ssubnormal, %snormal} / %sinfinity:", (i ? "-" : "+"), (i ? "-" : "+"), (i ? "-" : "+"), (j ? "-" : "+"));
          b = {1'b0, {NEXP{1'b1}}, {NSIG{1'b0}}} | (j << NEXP+NSIG);
          a = {1'b0, {NEXP{1'b0}}, {NSIG{1'b0}}} | (i << NEXP+NSIG);
          #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
          a = {1'b0, {NEXP{1'b0}}, ({NSIG{1'b0}} | 4'hA)} | (i << NEXP+NSIG);
          #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
          a = {1'b0, 1'b0, {NEXP-1{1'b1}}, ({NSIG{1'b0}} | 4'hA)} | (i << NEXP+NSIG);
          #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
        end

    // Test signed multiplication of Zero:
    for (i = 0; i < 2; i = i + 1)
      for (j = 0; j < 2; j = j + 1)
        begin
          // For these tests a is always Zero.
          $display("\n%szero / {%szero, %ssubnormal, %snormal}:", (j ? "-" : "+"), (i ? "-" : "+"), (i ? "-" : "+"), (i ? "-" : "+"));
          a = {1'b0, {NEXP{1'b0}}, {NSIG{1'b0}}} | (j << NEXP+NSIG);
          b = {1'b0, {NEXP{1'b0}}, {NSIG{1'b0}}} | (i << NEXP+NSIG);
          #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
          b = {1'b0, {NEXP{1'b0}}, ({NSIG{1'b0}} | 4'hB)} | (i << NEXP+NSIG);
          #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
          b = {1'b0, 1'b0, {NEXP-1{1'b1}}, ({NSIG{1'b0}} | 4'hB)} | (i << NEXP+NSIG);
          #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);

          // For these tests b is always Zero.
          $display("\n{%ssubnormal, %snormal} / %szero:", (j ? "-" : "+"), (j ? "-" : "+"), (i ? "-" : "+"));
          b = {1'b0, {NEXP{1'b0}}, {NSIG{1'b0}}} | (i << NEXP+NSIG);
          a = {1'b0, {NEXP{1'b0}}, ({NSIG{1'b0}} | 4'hA)} | (j << NEXP+NSIG);
          #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
          a = {1'b0, 1'b0, {NEXP-1{1'b1}}, ({NSIG{1'b0}} | 4'hA)} | (j << NEXP+NSIG);
          #10 $display("q (%x %b %b) = a (%x) / b (%x)", q, qFlags, exception, a, b);
        end

    $display("\nApproximate PI using 3/1:");
    a = 16'h4200; b = 16'h3C00;
    #10 $display("a = %x, b = %x, q = %x", a, b, q);
    
    $display("\nApproximate PI using 22/7:");
    a = 16'h4D80; b = 16'h4700;
    #10 $display("a = %x, b = %x, q = %x", a, b, q);
    
    $display("\nApproximate PI using 355/113:");
    #10 a = 16'h5D8C; b = 16'h5710;
    #10 $display("a = %x, b = %x, q = %x", a, b, q);
    
    $display("\n1 / 3:");
    a = 16'h3C00; b = 16'h4200;
    #10 $display("a = %x, b = %x, q = %x", a, b, q);
    
    $display("\n2 / 3:");
    a = 16'h4000; b = 16'h4200;
    #10 $display("a = %x, b = %x, q = %x", a, b, q);
    
    $display("\n10 / 3:");
    a = 16'h4900; b = 16'h4200;
    #10 $display("a = %x, b = %x, q = %x", a, b, q);

    $display("\n3 / 5:");
    a = 16'h4200; b = 16'h4500;
    #10 $display("a = %x, b = %x, q = %x", a, b, q);
    
    $display("\n5 / 3:");
    a = 16'h4500; b = 16'h4200;
    #10 $display("a = %x, b = %x, q = %x", a, b, q);

    #20 $display("\nEnd of tests : %t", $time);
    #20 $stop;
  end
    
  fp_div #(NEXP, NSIG) U0(a, b, ra, q, qFlags, exception);
endmodule
