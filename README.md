# Verilog IEEE 754 Division Module

## Description

First version of the floating point division module. No optimization.

The code is explained in the video series [Building an FPU in Verilog](https://www.youtube.com/watch?v=rYkVdJnVJFQ&list=PLlO9sSrh8HrwcDHAtwec1ycV-m50nfUVs).
See the video *Building an FPU in Verilog: Dividing Floating Point Numbers, Part 1*.

## Manifest

|   Filename        |                        Description                           |
|-------------------|--------------------------------------------------------------|
| README.md         | This file.                                                   |
| fp_class.sv       | Utility module to identify the type of the IEEE 754 value passed in, and extract the exponent & significand fields for use by other modules. |
| fp_div.v          | Circuit to compute floating point division.                  |
| fp_div_tb.v       | Testbench for division circuit.                              |
| ieee-754-flags.vh | Verilog header file to define constants for datum type (NaN, Infinity, Zero, Subnormal, and Normal), rounding attributes, and IEEE exceptions. |
| padder11.v        | Prefix adder used by round module.                           |
| padder113.v       | Prefix adder used by round module.                           |
| padder24.v        | Prefix adder used by round module.                           |
| padder53.v        | Prefix adder used by fp_as module.                    |
| PijGij.v          | Utility routines needed by the various prefix adder modules. |
| round.v           | Parameterized rounding module.                               |
| simulate.roundTiesToEven-16 | Test bench results for binary16, roundTiesToEven. |
| simulate.roundTowardNegative-16 | Test bench results for binary16, roundTowardNegative. |
| simulate.roundTowardPositive-16 | Test bench results for binary16, roundTowardPositive. |
| simulate.roundTowardZero-16 | Test bench results for binary16, roundTowardZero. |

## Copyright

:copyright: Chris Larsen, 2019-2022
