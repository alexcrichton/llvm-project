// WebAssemblyInstrInteger.td-WebAssembly Integer codegen -------*- tablegen -*-
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file
/// WebAssembly Integer operand code-gen constructs.
///
//===----------------------------------------------------------------------===//

multiclass UnaryInt<SDNode node, string name, bits<32> i32Inst,
                    bits<32> i64Inst> {
  defm _I32 : I<(outs I32:$dst), (ins I32:$src), (outs), (ins),
                [(set I32:$dst, (node I32:$src))],
                !strconcat("i32.", !strconcat(name, "\t$dst, $src")),
                !strconcat("i32.", name), i32Inst>;
  defm _I64 : I<(outs I64:$dst), (ins I64:$src), (outs), (ins),
                [(set I64:$dst, (node I64:$src))],
                !strconcat("i64.", !strconcat(name, "\t$dst, $src")),
                !strconcat("i64.", name), i64Inst>;
}
multiclass BinaryInt<SDNode node, string name, bits<32> i32Inst,
                     bits<32> i64Inst> {
  defm _I32 : I<(outs I32:$dst), (ins I32:$lhs, I32:$rhs), (outs), (ins),
                [(set I32:$dst, (node I32:$lhs, I32:$rhs))],
                !strconcat("i32.", !strconcat(name, "\t$dst, $lhs, $rhs")),
                !strconcat("i32.", name), i32Inst>;
  defm _I64 : I<(outs I64:$dst), (ins I64:$lhs, I64:$rhs), (outs), (ins),
                [(set I64:$dst, (node I64:$lhs, I64:$rhs))],
                !strconcat("i64.", !strconcat(name, "\t$dst, $lhs, $rhs")),
                !strconcat("i64.", name), i64Inst>;
}
multiclass ComparisonInt<CondCode cond, string name, bits<32> i32Inst, bits<32> i64Inst> {
  defm _I32 : I<(outs I32:$dst), (ins I32:$lhs, I32:$rhs), (outs), (ins),
                [(set I32:$dst, (setcc I32:$lhs, I32:$rhs, cond))],
                !strconcat("i32.", !strconcat(name, "\t$dst, $lhs, $rhs")),
                !strconcat("i32.", name), i32Inst>;
  defm _I64 : I<(outs I32:$dst), (ins I64:$lhs, I64:$rhs), (outs), (ins),
                [(set I32:$dst, (setcc I64:$lhs, I64:$rhs, cond))],
                !strconcat("i64.", !strconcat(name, "\t$dst, $lhs, $rhs")),
                !strconcat("i64.", name), i64Inst>;
}

// The spaces after the names are for aesthetic purposes only, to make
// operands line up vertically after tab expansion.
let isCommutable = 1 in
defm ADD : BinaryInt<add, "add ", 0x6a, 0x7c>;
defm SUB : BinaryInt<sub, "sub ", 0x6b, 0x7d>;
let isCommutable = 1 in
defm MUL : BinaryInt<mul, "mul ", 0x6c, 0x7e>;
// Divide and remainder trap on a zero denominator.
let hasSideEffects = 1 in {
defm DIV_S : BinaryInt<sdiv, "div_s", 0x6d, 0x7f>;
defm DIV_U : BinaryInt<udiv, "div_u", 0x6e, 0x80>;
defm REM_S : BinaryInt<srem, "rem_s", 0x6f, 0x81>;
defm REM_U : BinaryInt<urem, "rem_u", 0x70, 0x82>;
} // hasSideEffects = 1
let isCommutable = 1 in {
defm AND : BinaryInt<and, "and ", 0x71, 0x83>;
defm OR : BinaryInt<or, "or  ", 0x72, 0x84>;
defm XOR : BinaryInt<xor, "xor ", 0x73, 0x85>;
} // isCommutable = 1
defm SHL : BinaryInt<shl, "shl ", 0x74, 0x86>;
defm SHR_S : BinaryInt<sra, "shr_s", 0x75, 0x87>;
defm SHR_U : BinaryInt<srl, "shr_u", 0x76, 0x88>;
defm ROTL : BinaryInt<rotl, "rotl", 0x77, 0x89>;
defm ROTR : BinaryInt<rotr, "rotr", 0x78, 0x8a>;

let isCommutable = 1 in {
defm EQ : ComparisonInt<SETEQ, "eq  ", 0x46, 0x51>;
defm NE : ComparisonInt<SETNE, "ne  ", 0x47, 0x52>;
} // isCommutable = 1
defm LT_S : ComparisonInt<SETLT,  "lt_s", 0x48, 0x53>;
defm LT_U : ComparisonInt<SETULT, "lt_u", 0x49, 0x54>;
defm GT_S : ComparisonInt<SETGT,  "gt_s", 0x4a, 0x55>;
defm GT_U : ComparisonInt<SETUGT, "gt_u", 0x4b, 0x56>;
defm LE_S : ComparisonInt<SETLE,  "le_s", 0x4c, 0x57>;
defm LE_U : ComparisonInt<SETULE, "le_u", 0x4d, 0x58>;
defm GE_S : ComparisonInt<SETGE,  "ge_s", 0x4e, 0x59>;
defm GE_U : ComparisonInt<SETUGE, "ge_u", 0x4f, 0x5a>;

defm CLZ : UnaryInt<ctlz, "clz ", 0x67, 0x79>;
defm CTZ : UnaryInt<cttz, "ctz ", 0x68, 0x7a>;
defm POPCNT : UnaryInt<ctpop, "popcnt", 0x69, 0x7b>;

defm EQZ_I32 : I<(outs I32:$dst), (ins I32:$src), (outs), (ins),
                 [(set I32:$dst, (setcc I32:$src, 0, SETEQ))],
                 "i32.eqz \t$dst, $src", "i32.eqz", 0x45>;
defm EQZ_I64 : I<(outs I32:$dst), (ins I64:$src), (outs), (ins),
                 [(set I32:$dst, (setcc I64:$src, 0, SETEQ))],
                 "i64.eqz \t$dst, $src", "i64.eqz", 0x50>;

// Optimize away an explicit mask on a shift count.
def : Pat<(shl I32:$lhs, (and I32:$rhs, 31)), (SHL_I32 I32:$lhs, I32:$rhs)>;
def : Pat<(sra I32:$lhs, (and I32:$rhs, 31)), (SHR_S_I32 I32:$lhs, I32:$rhs)>;
def : Pat<(srl I32:$lhs, (and I32:$rhs, 31)), (SHR_U_I32 I32:$lhs, I32:$rhs)>;
def : Pat<(shl I64:$lhs, (and I64:$rhs, 63)), (SHL_I64 I64:$lhs, I64:$rhs)>;
def : Pat<(sra I64:$lhs, (and I64:$rhs, 63)), (SHR_S_I64 I64:$lhs, I64:$rhs)>;
def : Pat<(srl I64:$lhs, (and I64:$rhs, 63)), (SHR_U_I64 I64:$lhs, I64:$rhs)>;

// Optimize away an explicit mask on a rotate count.
def : Pat<(rotl I32:$lhs, (and I32:$rhs, 31)), (ROTL_I32 I32:$lhs, I32:$rhs)>;
def : Pat<(rotr I32:$lhs, (and I32:$rhs, 31)), (ROTR_I32 I32:$lhs, I32:$rhs)>;
def : Pat<(rotl I64:$lhs, (and I64:$rhs, 63)), (ROTL_I64 I64:$lhs, I64:$rhs)>;
def : Pat<(rotr I64:$lhs, (and I64:$rhs, 63)), (ROTR_I64 I64:$lhs, I64:$rhs)>;

defm SELECT_I32 : I<(outs I32:$dst), (ins I32:$lhs, I32:$rhs, I32:$cond),
                    (outs), (ins),
                    [(set I32:$dst, (select I32:$cond, I32:$lhs, I32:$rhs))],
                    "i32.select\t$dst, $lhs, $rhs, $cond", "i32.select", 0x1b>;
defm SELECT_I64 : I<(outs I64:$dst), (ins I64:$lhs, I64:$rhs, I32:$cond),
                    (outs), (ins),
                    [(set I64:$dst, (select I32:$cond, I64:$lhs, I64:$rhs))],
                    "i64.select\t$dst, $lhs, $rhs, $cond", "i64.select", 0x1b>;

// ISD::SELECT requires its operand to conform to getBooleanContents, but
// WebAssembly's select interprets any non-zero value as true, so we can fold
// a setne with 0 into a select.
def : Pat<(select (i32 (setne I32:$cond, 0)), I32:$lhs, I32:$rhs),
          (SELECT_I32 I32:$lhs, I32:$rhs, I32:$cond)>;
def : Pat<(select (i32 (setne I32:$cond, 0)), I64:$lhs, I64:$rhs),
          (SELECT_I64 I64:$lhs, I64:$rhs, I32:$cond)>;

// And again, this time with seteq instead of setne and the arms reversed.
def : Pat<(select (i32 (seteq I32:$cond, 0)), I32:$lhs, I32:$rhs),
          (SELECT_I32 I32:$rhs, I32:$lhs, I32:$cond)>;
def : Pat<(select (i32 (seteq I32:$cond, 0)), I64:$lhs, I64:$rhs),
          (SELECT_I64 I64:$rhs, I64:$lhs, I32:$cond)>;

let Predicates = [HasAlexMisc] in {
defm I32_SWAP_BYTES : I<(outs I32:$dst), (ins I32:$src),
                        (outs), (ins),
                        [(set I32:$dst, (bswap I32:$src))],
                        "i32.swap_bytes\t$dst, $src",
                        "i32.swap_bytes",
                        0xfc70>;
defm I64_SWAP_BYTES : I<(outs I64:$dst), (ins I64:$src),
                        (outs), (ins),
                        [(set I64:$dst, (bswap I64:$src))],
                        "i64.swap_bytes\t$dst, $src",
                        "i64.swap_bytes",
                        0xfc71>;
defm I64_MUL_HIGH_U : I<(outs I64:$dst), (ins I64:$lhs, I64:$rhs),
                        (outs), (ins),
                        [(set I64:$dst, (mulhu I64:$lhs, I64:$rhs))],
                        "i64.mul_high_u\t$dst, $lhs, $rhs",
                        "i64.mul_high_u",
                        0xfc6e>;
defm I64_MUL_HIGH_S : I<(outs I64:$dst), (ins I64:$lhs, I64:$rhs),
                        (outs), (ins),
                        [(set I64:$dst, (mulhs I64:$lhs, I64:$rhs))],
                        "i64.mul_high_s\t$dst, $lhs, $rhs",
                        "i64.mul_high_s",
                        0xfc6f>;
} // Predicates = [HasAlexMisc]

let Predicates = [HasAlexOverflow] in {
defm I32_ADD_OVERFLOW_S : I<(outs I32:$out, I32:$oflow), (ins I32:$lhs, I32:$rhs),
                            (outs), (ins),
                            [],
                             "i32.add_overflow_s\t$out, $oflow, $lhs, $rhs",
                             "i32.add_overflow_s",
                             0xfc74>;
defm I32_ADD_OVERFLOW_U : I<(outs I32:$out, I32:$oflow), (ins I32:$lhs, I32:$rhs),
                            (outs), (ins),
                            [],
                             "i32.add_overflow_u\t$out, $oflow, $lhs, $rhs",
                             "i32.add_overflow_u",
                             0xfc75>;
defm I32_SUB_OVERFLOW_S : I<(outs I32:$out, I32:$oflow), (ins I32:$lhs, I32:$rhs),
                            (outs), (ins),
                            [],
                             "i32.sub_overflow_s\t$out, $oflow, $lhs, $rhs",
                             "i32.sub_overflow_s",
                             0xfc76>;
defm I32_SUB_OVERFLOW_U : I<(outs I32:$out, I32:$oflow), (ins I32:$lhs, I32:$rhs),
                            (outs), (ins),
                            [],
                             "i32.sub_overflow_u\t$out, $oflow, $lhs, $rhs",
                             "i32.sub_overflow_u",
                             0xfc77>;
defm I32_MUL_OVERFLOW_S : I<(outs I32:$out, I32:$oflow), (ins I32:$lhs, I32:$rhs),
                            (outs), (ins),
                            [],
                             "i32.mul_overflow_s\t$out, $oflow, $lhs, $rhs",
                             "i32.mul_overflow_s",
                             0xfc78>;
defm I32_MUL_OVERFLOW_U : I<(outs I32:$out, I32:$oflow), (ins I32:$lhs, I32:$rhs),
                            (outs), (ins),
                            [],
                             "i32.mul_overflow_u\t$out, $oflow, $lhs, $rhs",
                             "i32.mul_overflow_u",
                             0xfc79>;

defm I64_ADD_OVERFLOW_S : I<(outs I64:$out, I32:$oflow), (ins I64:$lhs, I64:$rhs),
                            (outs), (ins),
                            [],
                             "i64.add_overflow_s\t$out, $oflow, $lhs, $rhs",
                             "i64.add_overflow_s",
                             0xfc7a>;
defm I64_ADD_OVERFLOW_U : I<(outs I64:$out, I32:$oflow), (ins I64:$lhs, I64:$rhs),
                            (outs), (ins),
                            [],
                             "i64.add_overflow_u\t$out, $oflow, $lhs, $rhs",
                             "i64.add_overflow_u",
                             0xfc7b>;
defm I64_SUB_OVERFLOW_S : I<(outs I64:$out, I32:$oflow), (ins I64:$lhs, I64:$rhs),
                            (outs), (ins),
                            [],
                             "i64.sub_overflow_s\t$out, $oflow, $lhs, $rhs",
                             "i64.sub_overflow_s",
                             0xfc7c>;
defm I64_SUB_OVERFLOW_U : I<(outs I64:$out, I32:$oflow), (ins I64:$lhs, I64:$rhs),
                            (outs), (ins),
                            [],
                             "i64.sub_overflow_u\t$out, $oflow, $lhs, $rhs",
                             "i64.sub_overflow_u",
                             0xfc7d>;
defm I64_MUL_OVERFLOW_S : I<(outs I64:$out, I32:$oflow), (ins I64:$lhs, I64:$rhs),
                            (outs), (ins),
                            [],
                             "i64.mul_overflow_s\t$out, $oflow, $lhs, $rhs",
                             "i64.mul_overflow_s",
                             0xfc7e>;
defm I64_MUL_OVERFLOW_U : I<(outs I64:$out, I32:$oflow), (ins I64:$lhs, I64:$rhs),
                            (outs), (ins),
                            [],
                             "i64.mul_overflow_u\t$out, $oflow, $lhs, $rhs",
                             "i64.mul_overflow_u",
                             0xfc7f>;

defm I64_MUL_WIDE_S : I<(outs I64:$lo, I64:$hi), (ins I64:$lhs, I64:$rhs),
                        (outs), (ins),
                        [],
                         "i64.mul_wide_s\t$lo, $hi, $lhs, $rhs",
                         "i64.mul_wide_s",
                         0xfc72>;
defm I64_MUL_WIDE_U : I<(outs I64:$lo, I64:$hi), (ins I64:$lhs, I64:$rhs),
                        (outs), (ins),
                        [],
                        "i64.mul_wide_u\t$lo, $hi, $lhs, $rhs",
                        "i64.mul_wide_u",
                        0xfc73>;

defm I32_ADD_WITH_CARRY_S : I<(outs I32:$out, I32:$oflow), (ins I32:$lhs, I32:$rhs, I32:$carry),
                              (outs), (ins),
                              [],
                               "i32.add_with_carry_s\t$out, $oflow, $lhs, $rhs, $carry",
                               "i32.add_with_carry_s",
                               0xfc50>;
defm I32_ADD_WITH_CARRY_U : I<(outs I32:$out, I32:$oflow), (ins I32:$lhs, I32:$rhs, I32:$carry),
                              (outs), (ins),
                              [],
                               "i32.add_with_carry_u\t$out, $oflow, $lhs, $rhs, $carry",
                               "i32.add_with_carry_u",
                               0xfc51>;
defm I32_SUB_WITH_CARRY_S : I<(outs I32:$out, I32:$oflow), (ins I32:$lhs, I32:$rhs, I32:$carry),
                              (outs), (ins),
                              [],
                               "i32.sub_with_carry_s\t$out, $oflow, $lhs, $rhs, $carry",
                               "i32.sub_with_carry_s",
                               0xfc52>;
defm I32_SUB_WITH_CARRY_U : I<(outs I32:$out, I32:$oflow), (ins I32:$lhs, I32:$rhs, I32:$carry),
                              (outs), (ins),
                              [],
                               "i32.sub_with_carry_u\t$out, $oflow, $lhs, $rhs, $carry",
                               "i32.sub_with_carry_u",
                               0xfc53>;

defm I64_ADD_WITH_CARRY_S : I<(outs I64:$out, I32:$oflow), (ins I64:$lhs, I64:$rhs, I32:$carry),
                              (outs), (ins),
                              [],
                               "i64.add_with_carry_s\t$out, $oflow, $lhs, $rhs, $carry",
                               "i64.add_with_carry_s",
                               0xfc54>;
defm I64_ADD_WITH_CARRY_U : I<(outs I64:$out, I32:$oflow), (ins I64:$lhs, I64:$rhs, I32:$carry),
                              (outs), (ins),
                              [],
                               "i64.add_with_carry_u\t$out, $oflow, $lhs, $rhs, $carry",
                               "i64.add_with_carry_u",
                               0xfc55>;
defm I64_SUB_WITH_CARRY_S : I<(outs I64:$out, I32:$oflow), (ins I64:$lhs, I64:$rhs, I32:$carry),
                              (outs), (ins),
                              [],
                               "i64.sub_with_carry_s\t$out, $oflow, $lhs, $rhs, $carry",
                               "i64.sub_with_carry_s",
                               0xfc56>;
defm I64_SUB_WITH_CARRY_U : I<(outs I64:$out, I32:$oflow), (ins I64:$lhs, I64:$rhs, I32:$carry),
                              (outs), (ins),
                              [],
                               "i64.sub_with_carry_u\t$out, $oflow, $lhs, $rhs, $carry",
                               "i64.sub_with_carry_u",
                               0xfc57>;

} // Predicates = [HasAlexOverflow]

def wasm_mul_wide_s_t : SDTypeProfile<2, 2, []>;
def wasm_mul_wide_s : SDNode<"WebAssemblyISD::I64_MUL_WIDE_S", wasm_mul_wide_s_t>;
def wasm_mul_wide_u_t : SDTypeProfile<2, 2, []>;
def wasm_mul_wide_u : SDNode<"WebAssemblyISD::I64_MUL_WIDE_U", wasm_mul_wide_u_t>;

def : Pat<(wasm_mul_wide_s I64:$x, I64:$y),
          (I64_MUL_WIDE_S $x, $y)>;
def : Pat<(wasm_mul_wide_u I64:$x, I64:$y),
          (I64_MUL_WIDE_U $x, $y)>;

def wasm_i32_add_overflow_s_t : SDTypeProfile<2, 2, []>;
def wasm_i32_add_overflow_s : SDNode<"WebAssemblyISD::I32_ADD_OVERFLOW_S", wasm_i32_add_overflow_s_t>;
def : Pat<(wasm_i32_add_overflow_s I32:$x, I32:$y),
          (I32_ADD_OVERFLOW_S $x, $y)>;

def wasm_i32_add_overflow_u_t : SDTypeProfile<2, 2, []>;
def wasm_i32_add_overflow_u : SDNode<"WebAssemblyISD::I32_ADD_OVERFLOW_U", wasm_i32_add_overflow_u_t>;
def : Pat<(wasm_i32_add_overflow_u I32:$x, I32:$y),
          (I32_ADD_OVERFLOW_U $x, $y)>;

def wasm_i32_sub_overflow_s_t : SDTypeProfile<2, 2, []>;
def wasm_i32_sub_overflow_s : SDNode<"WebAssemblyISD::I32_SUB_OVERFLOW_S", wasm_i32_sub_overflow_s_t>;
def : Pat<(wasm_i32_sub_overflow_s I32:$x, I32:$y),
          (I32_SUB_OVERFLOW_S $x, $y)>;

def wasm_i32_sub_overflow_u_t : SDTypeProfile<2, 2, []>;
def wasm_i32_sub_overflow_u : SDNode<"WebAssemblyISD::I32_SUB_OVERFLOW_U", wasm_i32_sub_overflow_u_t>;
def : Pat<(wasm_i32_sub_overflow_u I32:$x, I32:$y),
          (I32_SUB_OVERFLOW_U $x, $y)>;

def wasm_i32_mul_overflow_s_t : SDTypeProfile<2, 2, []>;
def wasm_i32_mul_overflow_s : SDNode<"WebAssemblyISD::I32_MUL_OVERFLOW_S", wasm_i32_mul_overflow_s_t>;
def : Pat<(wasm_i32_mul_overflow_s I32:$x, I32:$y),
          (I32_MUL_OVERFLOW_S $x, $y)>;

def wasm_i32_mul_overflow_u_t : SDTypeProfile<2, 2, []>;
def wasm_i32_mul_overflow_u : SDNode<"WebAssemblyISD::I32_MUL_OVERFLOW_U", wasm_i32_mul_overflow_u_t>;
def : Pat<(wasm_i32_mul_overflow_u I32:$x, I32:$y),
          (I32_MUL_OVERFLOW_U $x, $y)>;

def wasm_i64_add_overflow_s_t : SDTypeProfile<2, 2, []>;
def wasm_i64_add_overflow_s : SDNode<"WebAssemblyISD::I64_ADD_OVERFLOW_S", wasm_i64_add_overflow_s_t>;
def : Pat<(wasm_i64_add_overflow_s I64:$x, I64:$y),
          (I64_ADD_OVERFLOW_S $x, $y)>;

def wasm_i64_add_overflow_u_t : SDTypeProfile<2, 2, []>;
def wasm_i64_add_overflow_u : SDNode<"WebAssemblyISD::I64_ADD_OVERFLOW_U", wasm_i64_add_overflow_u_t>;
def : Pat<(wasm_i64_add_overflow_u I64:$x, I64:$y),
          (I64_ADD_OVERFLOW_U $x, $y)>;

def wasm_i64_sub_overflow_s_t : SDTypeProfile<2, 2, []>;
def wasm_i64_sub_overflow_s : SDNode<"WebAssemblyISD::I64_SUB_OVERFLOW_S", wasm_i64_sub_overflow_s_t>;
def : Pat<(wasm_i64_sub_overflow_s I64:$x, I64:$y),
          (I64_SUB_OVERFLOW_S $x, $y)>;

def wasm_i64_sub_overflow_u_t : SDTypeProfile<2, 2, []>;
def wasm_i64_sub_overflow_u : SDNode<"WebAssemblyISD::I64_SUB_OVERFLOW_U", wasm_i64_sub_overflow_u_t>;
def : Pat<(wasm_i64_sub_overflow_u I64:$x, I64:$y),
          (I64_SUB_OVERFLOW_U $x, $y)>;

def wasm_i64_mul_overflow_s_t : SDTypeProfile<2, 2, []>;
def wasm_i64_mul_overflow_s : SDNode<"WebAssemblyISD::I64_MUL_OVERFLOW_S", wasm_i64_mul_overflow_s_t>;
def : Pat<(wasm_i64_mul_overflow_s I64:$x, I64:$y),
          (I64_MUL_OVERFLOW_S $x, $y)>;

def wasm_i64_mul_overflow_u_t : SDTypeProfile<2, 2, []>;
def wasm_i64_mul_overflow_u : SDNode<"WebAssemblyISD::I64_MUL_OVERFLOW_U", wasm_i64_mul_overflow_u_t>;
def : Pat<(wasm_i64_mul_overflow_u I64:$x, I64:$y),
          (I64_MUL_OVERFLOW_U $x, $y)>;

def wasm_i32_add_with_carry_s_t : SDTypeProfile<2, 3, []>;
def wasm_i32_add_with_carry_s : SDNode<"WebAssemblyISD::I32_ADD_WITH_CARRY_S", wasm_i32_add_with_carry_s_t>;
def : Pat<(wasm_i32_add_with_carry_s I32:$x, I32:$y, I32:$carry),
          (I32_ADD_WITH_CARRY_S $x, $y, $carry)>;

def wasm_i32_add_with_carry_u_t : SDTypeProfile<2, 3, []>;
def wasm_i32_add_with_carry_u : SDNode<"WebAssemblyISD::I32_ADD_WITH_CARRY_U", wasm_i32_add_with_carry_u_t>;
def : Pat<(wasm_i32_add_with_carry_u I32:$x, I32:$y, I32:$carry),
          (I32_ADD_WITH_CARRY_U $x, $y, $carry)>;

def wasm_i32_sub_with_carry_s_t : SDTypeProfile<2, 3, []>;
def wasm_i32_sub_with_carry_s : SDNode<"WebAssemblyISD::I32_SUB_WITH_CARRY_S", wasm_i32_sub_with_carry_s_t>;
def : Pat<(wasm_i32_sub_with_carry_s I32:$x, I32:$y, I32:$carry),
          (I32_SUB_WITH_CARRY_S $x, $y, $carry)>;

def wasm_i32_sub_with_carry_u_t : SDTypeProfile<2, 3, []>;
def wasm_i32_sub_with_carry_u : SDNode<"WebAssemblyISD::I32_SUB_WITH_CARRY_U", wasm_i32_sub_with_carry_u_t>;
def : Pat<(wasm_i32_sub_with_carry_u I32:$x, I32:$y, I32:$carry),
          (I32_SUB_WITH_CARRY_U $x, $y, $carry)>;

def wasm_i64_add_with_carry_s_t : SDTypeProfile<2, 3, []>;
def wasm_i64_add_with_carry_s : SDNode<"WebAssemblyISD::I64_ADD_WITH_CARRY_S", wasm_i64_add_with_carry_s_t>;
def : Pat<(wasm_i64_add_with_carry_s I64:$x, I64:$y, I32:$carry),
          (I64_ADD_WITH_CARRY_S $x, $y, $carry)>;

def wasm_i64_add_with_carry_u_t : SDTypeProfile<2, 3, []>;
def wasm_i64_add_with_carry_u : SDNode<"WebAssemblyISD::I64_ADD_WITH_CARRY_U", wasm_i64_add_with_carry_u_t>;
def : Pat<(wasm_i64_add_with_carry_u I64:$x, I64:$y, I32:$carry),
          (I64_ADD_WITH_CARRY_U $x, $y, $carry)>;

def wasm_i64_sub_with_carry_s_t : SDTypeProfile<2, 3, []>;
def wasm_i64_sub_with_carry_s : SDNode<"WebAssemblyISD::I64_SUB_WITH_CARRY_S", wasm_i64_sub_with_carry_s_t>;
def : Pat<(wasm_i64_sub_with_carry_s I64:$x, I64:$y, I32:$carry),
          (I64_SUB_WITH_CARRY_S $x, $y, $carry)>;

def wasm_i64_sub_with_carry_u_t : SDTypeProfile<2, 3, []>;
def wasm_i64_sub_with_carry_u : SDNode<"WebAssemblyISD::I64_SUB_WITH_CARRY_U", wasm_i64_sub_with_carry_u_t>;
def : Pat<(wasm_i64_sub_with_carry_u I64:$x, I64:$y, I32:$carry),
          (I64_SUB_WITH_CARRY_U $x, $y, $carry)>;

let Predicates = [HasAlex128] in {
defm I64_ADD128 : I<(outs I64:$lo, I64:$hi), (ins I64:$lhs_lo, I64:$lhs_hi, I64:$rhs_lo, I64:$rhs_hi),
                    (outs), (ins),
                    [],
                     "i64.add128\t$lo, $hi, $lhs_lo, $lhs_hi, $rhs_lo, $rhs_hi",
                     "i64.add128",
                     0xfc58>;
defm I64_SUB128 : I<(outs I64:$lo, I64:$hi), (ins I64:$lhs_lo, I64:$lhs_hi, I64:$rhs_lo, I64:$rhs_hi),
                    (outs), (ins),
                    [],
                     "i64.sub128\t$lo, $hi, $lhs_lo, $lhs_hi, $rhs_lo, $rhs_hi",
                     "i64.sub128",
                     0xfc59>;
defm I64_MUL128 : I<(outs I64:$lo, I64:$hi), (ins I64:$lhs_lo, I64:$lhs_hi, I64:$rhs_lo, I64:$rhs_hi),
                    (outs), (ins),
                    [],
                     "i64.mul128\t$lo, $hi, $lhs_lo, $lhs_hi, $rhs_lo, $rhs_hi",
                     "i64.mul128",
                     0xfc5a>;
} // Predicates = [HasAlex128]

def wasm_add128_t : SDTypeProfile<2, 4, []>;
def wasm_add128 : SDNode<"WebAssemblyISD::I64_ADD128", wasm_add128_t>;
def : Pat<(wasm_add128 I64:$a, I64:$b, I64:$c, I64:$d),
          (I64_ADD128 $a, $b, $c, $d)>;

def wasm_sub128_t : SDTypeProfile<2, 4, []>;
def wasm_sub128 : SDNode<"WebAssemblyISD::I64_SUB128", wasm_sub128_t>;
def : Pat<(wasm_sub128 I64:$a, I64:$b, I64:$c, I64:$d),
          (I64_SUB128 $a, $b, $c, $d)>;

def wasm_mul128_t : SDTypeProfile<2, 4, []>;
def wasm_mul128 : SDNode<"WebAssemblyISD::I64_MUL128", wasm_mul128_t>;
def : Pat<(wasm_mul128 I64:$a, I64:$b, I64:$c, I64:$d),
          (I64_MUL128 $a, $b, $c, $d)>;

// TODO: document this
def SDT_SETCC128 : SDTypeProfile<1, 5, []>;
def SETCC128 : SDNode<"WebAssemblyISD::SETCC128", SDT_SETCC128>;

multiclass ComparisonInt128<CondCode cond, string name, bits<32> opcode> {
  defm _I : I<(outs I32:$dst), (ins I64:$lhs_lo, I64:$lhs_hi, I64:$rhs_lo, I64:$rhs_hi),
              (outs), (ins),
              [(set I32:$dst, (SETCC128 I64:$lhs_lo, I64:$lhs_hi, I64:$rhs_lo, I64:$rhs_hi, cond))],
              !strconcat(name, "\t$dst, $lhs_lo, $lhs_hi, $rhs_lo, $rhs_hi"),
              name, opcode>;
}

let Predicates = [HasAlex128Cmp] in {

defm I64_LT128_S : ComparisonInt128<SETLT,  "i64.lt128_s", 0xfc20>;
defm I64_LT128_U : ComparisonInt128<SETULT, "i64.lt128_u", 0xfc21>;
defm I64_GT128_S : ComparisonInt128<SETGT,  "i64.gt128_s", 0xfc22>;
defm I64_GT128_U : ComparisonInt128<SETUGT, "i64.gt128_u", 0xfc23>;
defm I64_LE128_S : ComparisonInt128<SETLE,  "i64.le128_s", 0xfc24>;
defm I64_LE128_U : ComparisonInt128<SETULE, "i64.le128_u", 0xfc25>;
defm I64_GE128_S : ComparisonInt128<SETGE,  "i64.ge128_s", 0xfc26>;
defm I64_GE128_U : ComparisonInt128<SETUGE, "i64.ge128_u", 0xfc27>;

} // Predicates = [HasAlex128Cmp]
