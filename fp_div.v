`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/21/2022 09:19:56 PM
// Design Name: 
// Module Name: fp_div
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Floating point division written as combinatorial logic.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module fp_div(a, b, ra, q, qFlags, exception);
  parameter NEXP = 5;
  parameter NSIG = 10;
  `include "ieee-754-flags.vh"
  input [NEXP+NSIG:0] a, b;   // Operands
  input [NRAS:0] ra;          // Rounding Attribute
  output [NEXP+NSIG:0] q;     // Quotient Return Value
  output [NTYPES-1:0] qFlags; // Type of return value: sNaN, qNaN, Infinity,
  reg [NTYPES-1:0] qFlags;    // Zero, Normal, or Subnormal.
  output [NEXCEPTIONS-1:0] exception; // Which exceptions were signalled?
  reg [NEXCEPTIONS-1:0] exception;
  
  wire signed [NEXP+1:0] aExp, bExp, expOut;
  // qExp is the quotient for the exponent portion of our result.
  reg signed [NEXP+1:0] normExp, expIn, qExp;
  wire [NSIG:0] aSigWire, bSigWire, sigOut;
  // aSig is the portion of the dividend which hasn't yet been processed.
  // bSig is the zero-extended divisor
  // rSig is our guess for the next value of aSig. If rSig is negative
  // our guess was wrong and we reuse the current aSig.
  reg signed [NSIG+2:0] aSig, bSig, rSig;
  // qSig is the temporary value used to calculate qSig in the always
  // block.
  reg [NSIG+2:0] qSig;
  wire [NTYPES-1:0] aFlags, bFlags;
  wire qSign = a[NEXP+NSIG]^b[NEXP+NSIG];
  wire inexact;
  
  fp_class #(NEXP,NSIG) aClass(a, aExp, aSigWire, aFlags);
  fp_class #(NEXP,NSIG) bClass(b, bExp, bSigWire, bFlags);
  
  reg [NEXP+NSIG:0] alwaysQ; // Quotient generated inside the
                             // always block.
  reg si; // Used to compute how to round infinities.

  integer i;

  always @(*)
  begin
    qSig = 0;
    aSig = {2'b00, aSigWire};
    bSig = {2'b00, bSigWire};
    exception = 0;
    normExp = 0;
        
    qFlags = 0;

    if (aFlags[SNAN] | bFlags[SNAN])
      begin
        {alwaysQ, qFlags} = aFlags[SNAN] ? {a, aFlags} : {b, bFlags};
      end
    else if (aFlags[QNAN] | bFlags[QNAN])
      begin
        {alwaysQ, qFlags} = aFlags[QNAN] ? {a, aFlags} : {b, bFlags};
      end
    else if (aFlags[INFINITY] & bFlags[INFINITY])
      begin
        qFlags[QNAN] = 1;
        alwaysQ = {qSign, {NEXP+NSIG{1'b1}}};
        exception[INVALID] = 1;
      end
    else if (aFlags[INFINITY])
      begin
        si = ra[roundTowardZero] |
            (ra[roundTowardNegative] & ~qSign) |
            (ra[roundTowardPositive] &  qSign);
        alwaysQ = {qSign, {NEXP-1{1'b1}}, ~si, {NSIG{si}}};
        qFlags[INFINITY] = ~si;
        qFlags[NORMAL]   =  si;
        exception[OVERFLOW] = 1;
      end
    else if (bFlags[INFINITY]) // a is Zero, Subnormal, or Normal
      begin
        qFlags[ZERO] = 1;
        alwaysQ = {qSign, {NEXP+NSIG{1'b0}}};
      end
    else if (aFlags[ZERO] & bFlags[ZERO])
      begin
        qFlags[QNAN] = 1;
        alwaysQ = {qSign, {NEXP+NSIG{1'b1}}};
        exception[INVALID] = 1;
      end
    else if (aFlags[ZERO])
      begin
        qFlags[ZERO] = 1;
        alwaysQ = {qSign, {NEXP+NSIG{1'b0}}};
      end
    else if (bFlags[ZERO])
      begin
        si = ra[roundTowardZero] |
            (ra[roundTowardNegative] & ~qSign) |
            (ra[roundTowardPositive] &  qSign);
        alwaysQ = {qSign, {NEXP-1{1'b1}}, ~si, {NSIG{si}}};
        qFlags[INFINITY] = ~si;
        qFlags[NORMAL]   =  si;
        exception[DIVIDEBYZERO] = 1;
      end
    else
      begin
        for (i = 0; i < NSIG+3; i = i + 1)
          begin
            rSig = aSig - bSig;
            qSig = {qSig[NSIG+1:0], ~rSig[NSIG+2]};
            aSig = {(rSig[NSIG+2] ? aSig[NSIG+1:0] : rSig[NSIG+1:0]), 1'b0};
          end
    
        // Renormalize if the MSB of the significand quotient is zero.
        normExp[0] = ~qSig[NSIG+2];
        expIn = aExp - bExp - normExp;
        qSig = qSig << ~qSig[NSIG+2];

        if (~|sigOut)
          begin
            qFlags[ZERO] = 1;
            alwaysQ = {ra[roundTowardNegative], {NEXP+NSIG{1'b0}}};
          end
        else if (expOut < EMIN)
          begin
            qFlags[SUBNORMAL] = 1;
            alwaysQ = {qSign, {NEXP{1'b0}}, sigOut[NSIG:1]};
          end
        else if (expOut > EMAX)
          begin
            si = ra[roundTowardZero] |
                (ra[roundTowardNegative] & ~qSign) |
                (ra[roundTowardPositive] &  qSign);
            alwaysQ = {qSign, {NEXP-1{1'b1}}, ~si, {NSIG{si}}};
            qFlags[INFINITY] = ~si;
            qFlags[NORMAL]   =  si;
            exception[OVERFLOW] = 1;
          end
        else
          begin
            qFlags[NORMAL] = 1;
            qExp = expOut + BIAS;

            alwaysQ = {qSign, qExp[NEXP-1:0], sigOut[NSIG-1:0]};
          end

        exception[INEXACT] = inexact;
        exception[OVERFLOW] = 0;
      end
  end
  
  // Round the significand.
  round #(2*NSIG+6, NEXP, NSIG) U0(qSign, expIn, {qSig, aSig}, ra,
                                   expOut, sigOut, inexact);
      
  assign q = alwaysQ;
  
endmodule
