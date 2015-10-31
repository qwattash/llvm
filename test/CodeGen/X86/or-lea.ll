; RUN: llc < %s -mtriple=x86_64-unknown-unknown | FileCheck %s

; InstCombine and DAGCombiner transform an 'add' into an 'or'
; if there are no common bits from the incoming operands.
; LEA instruction selection should be able to see through that
; transform and reduce add/shift/or instruction counts.

define i32 @or_shift1_and1(i32 %x, i32 %y) {
; CHECK-LABEL: or_shift1_and1:
; CHECK:       # BB#0:
; CHECK-NEXT:    addl %edi, %edi
; CHECK-NEXT:    andl $1, %esi
; CHECK-NEXT:    leal (%rsi,%rdi), %eax
; CHECK-NEXT:    retq

  %shl = shl i32 %x, 1
  %and = and i32 %y, 1
  %or = or i32 %and, %shl
  ret i32 %or
}

define i32 @or_shift1_and1_swapped(i32 %x, i32 %y) {
; CHECK-LABEL: or_shift1_and1_swapped:
; CHECK:       # BB#0:
; CHECK-NEXT:    leal (%rdi,%rdi), %eax
; CHECK-NEXT:    andl $1, %esi
; CHECK-NEXT:    orl %esi, %eax
; CHECK-NEXT:    retq

  %shl = shl i32 %x, 1
  %and = and i32 %y, 1
  %or = or i32 %shl, %and
  ret i32 %or
}

define i32 @or_shift2_and1(i32 %x, i32 %y) {
; CHECK-LABEL: or_shift2_and1:
; CHECK:       # BB#0:
; CHECK-NEXT:    leal (,%rdi,4), %eax
; CHECK-NEXT:    andl $1, %esi
; CHECK-NEXT:    orl %esi, %eax
; CHECK-NEXT:    retq

  %shl = shl i32 %x, 2
  %and = and i32 %y, 1
  %or = or i32 %shl, %and
  ret i32 %or
}

define i32 @or_shift3_and1(i32 %x, i32 %y) {
; CHECK-LABEL: or_shift3_and1:
; CHECK:       # BB#0:
; CHECK-NEXT:    leal (,%rdi,8), %eax
; CHECK-NEXT:    andl $1, %esi
; CHECK-NEXT:    orl %esi, %eax
; CHECK-NEXT:    retq

  %shl = shl i32 %x, 3
  %and = and i32 %y, 1
  %or = or i32 %shl, %and
  ret i32 %or
}

define i32 @or_shift3_and7(i32 %x, i32 %y) {
; CHECK-LABEL: or_shift3_and7:
; CHECK:       # BB#0:
; CHECK-NEXT:    leal (,%rdi,8), %eax
; CHECK-NEXT:    andl $7, %esi
; CHECK-NEXT:    orl %esi, %eax
; CHECK-NEXT:    retq

  %shl = shl i32 %x, 3
  %and = and i32 %y, 7
  %or = or i32 %shl, %and
  ret i32 %or
}

; The shift is too big for an LEA.

define i32 @or_shift4_and1(i32 %x, i32 %y) {
; CHECK-LABEL: or_shift4_and1:
; CHECK:       # BB#0:
; CHECK-NEXT:    shll $4, %edi
; CHECK-NEXT:    andl $1, %esi
; CHECK-NEXT:    leal (%rsi,%rdi), %eax
; CHECK-NEXT:    retq

  %shl = shl i32 %x, 4
  %and = and i32 %y, 1
  %or = or i32 %shl, %and
  ret i32 %or
}

; The mask is too big for the shift, so the 'or' isn't equivalent to an 'add'.

define i32 @or_shift3_and8(i32 %x, i32 %y) {
; CHECK-LABEL: or_shift3_and8:
; CHECK:       # BB#0:
; CHECK-NEXT:    leal (,%rdi,8), %eax
; CHECK-NEXT:    andl $8, %esi
; CHECK-NEXT:    orl %esi, %eax
; CHECK-NEXT:    retq

  %shl = shl i32 %x, 3
  %and = and i32 %y, 8
  %or = or i32 %shl, %and
  ret i32 %or
}

; 64-bit operands should work too.

define i64 @or_shift1_and1_64(i64 %x, i64 %y) {
; CHECK-LABEL: or_shift1_and1_64:
; CHECK:       # BB#0:
; CHECK-NEXT:    addq %rdi, %rdi
; CHECK-NEXT:    andl $1, %esi
; CHECK-NEXT:    leaq (%rsi,%rdi), %rax
; CHECK-NEXT:    retq

  %shl = shl i64 %x, 1
  %and = and i64 %y, 1
  %or = or i64 %and, %shl
  ret i64 %or
}

