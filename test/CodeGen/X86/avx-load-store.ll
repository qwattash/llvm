; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=avx,slow-unaligned-mem-32 | FileCheck %s
; RUN: llc -O0 < %s -mtriple=x86_64-unknown-unknown -mattr=avx,slow-unaligned-mem-32 | FileCheck %s -check-prefix=CHECK_O0

define void @test_256_load(double* nocapture %d, float* nocapture %f, <4 x i64>* nocapture %i) nounwind {
; CHECK-LABEL: test_256_load:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pushq %r15
; CHECK-NEXT:    pushq %r14
; CHECK-NEXT:    pushq %rbx
; CHECK-NEXT:    subq $96, %rsp
; CHECK-NEXT:    movq %rdx, %r14
; CHECK-NEXT:    movq %rsi, %r15
; CHECK-NEXT:    movq %rdi, %rbx
; CHECK-NEXT:    vmovaps (%rbx), %ymm0
; CHECK-NEXT:    vmovups %ymm0, {{[0-9]+}}(%rsp) # 32-byte Spill
; CHECK-NEXT:    vmovaps (%r15), %ymm1
; CHECK-NEXT:    vmovups %ymm1, {{[0-9]+}}(%rsp) # 32-byte Spill
; CHECK-NEXT:    vmovaps (%r14), %ymm2
; CHECK-NEXT:    vmovups %ymm2, (%rsp) # 32-byte Spill
; CHECK-NEXT:    callq dummy
; CHECK-NEXT:    vmovups {{[0-9]+}}(%rsp), %ymm0 # 32-byte Reload
; CHECK-NEXT:    vmovaps %ymm0, (%rbx)
; CHECK-NEXT:    vmovups {{[0-9]+}}(%rsp), %ymm0 # 32-byte Reload
; CHECK-NEXT:    vmovaps %ymm0, (%r15)
; CHECK-NEXT:    vmovups (%rsp), %ymm0 # 32-byte Reload
; CHECK-NEXT:    vmovaps %ymm0, (%r14)
; CHECK-NEXT:    addq $96, %rsp
; CHECK-NEXT:    popq %rbx
; CHECK-NEXT:    popq %r14
; CHECK-NEXT:    popq %r15
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
;
; CHECK_O0-LABEL: test_256_load:
; CHECK_O0:       # %bb.0: # %entry
; CHECK_O0-NEXT:    subq $152, %rsp
; CHECK_O0-NEXT:    vmovapd (%rdi), %ymm0
; CHECK_O0-NEXT:    vmovaps (%rsi), %ymm1
; CHECK_O0-NEXT:    vmovdqa (%rdx), %ymm2
; CHECK_O0-NEXT:    vmovups %ymm0, {{[0-9]+}}(%rsp) # 32-byte Spill
; CHECK_O0-NEXT:    vmovups %ymm1, {{[0-9]+}}(%rsp) # 32-byte Spill
; CHECK_O0-NEXT:    vmovups %ymm2, {{[0-9]+}}(%rsp) # 32-byte Spill
; CHECK_O0-NEXT:    movq %rsi, {{[0-9]+}}(%rsp) # 8-byte Spill
; CHECK_O0-NEXT:    movq %rdi, {{[0-9]+}}(%rsp) # 8-byte Spill
; CHECK_O0-NEXT:    movq %rdx, {{[0-9]+}}(%rsp) # 8-byte Spill
; CHECK_O0-NEXT:    callq dummy
; CHECK_O0-NEXT:    movq {{[0-9]+}}(%rsp), %rdx # 8-byte Reload
; CHECK_O0-NEXT:    vmovups {{[0-9]+}}(%rsp), %ymm0 # 32-byte Reload
; CHECK_O0-NEXT:    vmovapd %ymm0, (%rdx)
; CHECK_O0-NEXT:    movq {{[0-9]+}}(%rsp), %rsi # 8-byte Reload
; CHECK_O0-NEXT:    vmovups {{[0-9]+}}(%rsp), %ymm1 # 32-byte Reload
; CHECK_O0-NEXT:    vmovaps %ymm1, (%rsi)
; CHECK_O0-NEXT:    movq {{[0-9]+}}(%rsp), %rdi # 8-byte Reload
; CHECK_O0-NEXT:    vmovups {{[0-9]+}}(%rsp), %ymm2 # 32-byte Reload
; CHECK_O0-NEXT:    vmovdqa %ymm2, (%rdi)
; CHECK_O0-NEXT:    addq $152, %rsp
; CHECK_O0-NEXT:    vzeroupper
; CHECK_O0-NEXT:    retq
entry:
  %0 = bitcast double* %d to <4 x double>*
  %tmp1.i = load <4 x double>, <4 x double>* %0, align 32
  %1 = bitcast float* %f to <8 x float>*
  %tmp1.i17 = load <8 x float>, <8 x float>* %1, align 32
  %tmp1.i16 = load <4 x i64>, <4 x i64>* %i, align 32
  tail call void @dummy(<4 x double> %tmp1.i, <8 x float> %tmp1.i17, <4 x i64> %tmp1.i16) nounwind
  store <4 x double> %tmp1.i, <4 x double>* %0, align 32
  store <8 x float> %tmp1.i17, <8 x float>* %1, align 32
  store <4 x i64> %tmp1.i16, <4 x i64>* %i, align 32
  ret void
}

declare void @dummy(<4 x double>, <8 x float>, <4 x i64>)

;;
;; The two tests below check that we must fold load + scalar_to_vector
;; + ins_subvec+ zext into only a single vmovss or vmovsd or vinsertps from memory

define <8 x float> @mov00(<8 x float> %v, float * %ptr) nounwind {
; CHECK-LABEL: mov00:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-NEXT:    retq
;
; CHECK_O0-LABEL: mov00:
; CHECK_O0:       # %bb.0:
; CHECK_O0-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK_O0-NEXT:    # implicit-def: $ymm1
; CHECK_O0-NEXT:    vmovaps %xmm0, %xmm1
; CHECK_O0-NEXT:    vxorps %xmm2, %xmm2, %xmm2
; CHECK_O0-NEXT:    vblendps {{.*#+}} ymm0 = ymm1[0],ymm2[1,2,3,4,5,6,7]
; CHECK_O0-NEXT:    retq
  %val = load float, float* %ptr
  %i0 = insertelement <8 x float> zeroinitializer, float %val, i32 0
  ret <8 x float> %i0
}

define <4 x double> @mov01(<4 x double> %v, double * %ptr) nounwind {
; CHECK-LABEL: mov01:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-NEXT:    retq
;
; CHECK_O0-LABEL: mov01:
; CHECK_O0:       # %bb.0:
; CHECK_O0-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; CHECK_O0-NEXT:    # implicit-def: $ymm1
; CHECK_O0-NEXT:    vmovaps %xmm0, %xmm1
; CHECK_O0-NEXT:    vxorps %xmm2, %xmm2, %xmm2
; CHECK_O0-NEXT:    vblendpd {{.*#+}} ymm0 = ymm1[0],ymm2[1,2,3]
; CHECK_O0-NEXT:    retq
  %val = load double, double* %ptr
  %i0 = insertelement <4 x double> zeroinitializer, double %val, i32 0
  ret <4 x double> %i0
}

define void @storev16i16(<16 x i16> %a) nounwind {
; CHECK-LABEL: storev16i16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovaps %ymm0, (%rax)
;
; CHECK_O0-LABEL: storev16i16:
; CHECK_O0:       # %bb.0:
; CHECK_O0-NEXT:    # implicit-def: $rax
; CHECK_O0-NEXT:    vmovdqa %ymm0, (%rax)
  store <16 x i16> %a, <16 x i16>* undef, align 32
  unreachable
}

define void @storev16i16_01(<16 x i16> %a) nounwind {
; CHECK-LABEL: storev16i16_01:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vextractf128 $1, %ymm0, (%rax)
; CHECK-NEXT:    vmovups %xmm0, (%rax)
;
; CHECK_O0-LABEL: storev16i16_01:
; CHECK_O0:       # %bb.0:
; CHECK_O0-NEXT:    # implicit-def: $rax
; CHECK_O0-NEXT:    vmovdqu %ymm0, (%rax)
  store <16 x i16> %a, <16 x i16>* undef, align 4
  unreachable
}

define void @storev32i8(<32 x i8> %a) nounwind {
; CHECK-LABEL: storev32i8:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovaps %ymm0, (%rax)
;
; CHECK_O0-LABEL: storev32i8:
; CHECK_O0:       # %bb.0:
; CHECK_O0-NEXT:    # implicit-def: $rax
; CHECK_O0-NEXT:    vmovdqa %ymm0, (%rax)
  store <32 x i8> %a, <32 x i8>* undef, align 32
  unreachable
}

define void @storev32i8_01(<32 x i8> %a) nounwind {
; CHECK-LABEL: storev32i8_01:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vextractf128 $1, %ymm0, (%rax)
; CHECK-NEXT:    vmovups %xmm0, (%rax)
;
; CHECK_O0-LABEL: storev32i8_01:
; CHECK_O0:       # %bb.0:
; CHECK_O0-NEXT:    # implicit-def: $rax
; CHECK_O0-NEXT:    vmovdqu %ymm0, (%rax)
  store <32 x i8> %a, <32 x i8>* undef, align 4
  unreachable
}

; It is faster to make two saves, if the data is already in xmm registers. For
; example, after making an integer operation.
define void @double_save(<4 x i32> %A, <4 x i32> %B, <8 x i32>* %P) nounwind ssp {
; CHECK-LABEL: double_save:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovaps %xmm1, 16(%rdi)
; CHECK-NEXT:    vmovaps %xmm0, (%rdi)
; CHECK-NEXT:    retq
;
; CHECK_O0-LABEL: double_save:
; CHECK_O0:       # %bb.0:
; CHECK_O0-NEXT:    # implicit-def: $ymm2
; CHECK_O0-NEXT:    vmovaps %xmm0, %xmm2
; CHECK_O0-NEXT:    vinsertf128 $1, %xmm1, %ymm2, %ymm2
; CHECK_O0-NEXT:    vmovdqu %ymm2, (%rdi)
; CHECK_O0-NEXT:    vzeroupper
; CHECK_O0-NEXT:    retq
  %Z = shufflevector <4 x i32>%A, <4 x i32>%B, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  store <8 x i32> %Z, <8 x i32>* %P, align 16
  ret void
}

declare void @llvm.x86.avx.maskstore.ps.256(i8*, <8 x i32>, <8 x float>) nounwind

define void @f_f() nounwind {
; CHECK-LABEL: f_f:
; CHECK:       # %bb.0: # %allocas
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    testb %al, %al
; CHECK-NEXT:    jne .LBB8_2
; CHECK-NEXT:  # %bb.1: # %cif_mask_all
; CHECK-NEXT:  .LBB8_2: # %cif_mask_mixed
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    testb %al, %al
; CHECK-NEXT:    jne .LBB8_4
; CHECK-NEXT:  # %bb.3: # %cif_mixed_test_all
; CHECK-NEXT:    movl $-1, %eax
; CHECK-NEXT:    vmovd %eax, %xmm0
; CHECK-NEXT:    vmaskmovps %ymm0, %ymm0, (%rax)
; CHECK-NEXT:  .LBB8_4: # %cif_mixed_test_any_check
;
; CHECK_O0-LABEL: f_f:
; CHECK_O0:       # %bb.0: # %allocas
; CHECK_O0-NEXT:    # implicit-def: $al
; CHECK_O0-NEXT:    testb $1, %al
; CHECK_O0-NEXT:    jne .LBB8_1
; CHECK_O0-NEXT:    jmp .LBB8_2
; CHECK_O0-NEXT:  .LBB8_1: # %cif_mask_all
; CHECK_O0-NEXT:  .LBB8_2: # %cif_mask_mixed
; CHECK_O0-NEXT:    # implicit-def: $al
; CHECK_O0-NEXT:    testb $1, %al
; CHECK_O0-NEXT:    jne .LBB8_3
; CHECK_O0-NEXT:    jmp .LBB8_4
; CHECK_O0-NEXT:  .LBB8_3: # %cif_mixed_test_all
; CHECK_O0-NEXT:    movl $-1, %eax
; CHECK_O0-NEXT:    vmovd %eax, %xmm0
; CHECK_O0-NEXT:    vmovaps %xmm0, %xmm1
; CHECK_O0-NEXT:    # implicit-def: $rcx
; CHECK_O0-NEXT:    # implicit-def: $ymm2
; CHECK_O0-NEXT:    vmaskmovps %ymm2, %ymm1, (%rcx)
; CHECK_O0-NEXT:  .LBB8_4: # %cif_mixed_test_any_check
allocas:
  br i1 undef, label %cif_mask_all, label %cif_mask_mixed

cif_mask_all:
  unreachable

cif_mask_mixed:
  br i1 undef, label %cif_mixed_test_all, label %cif_mixed_test_any_check

cif_mixed_test_all:
  call void @llvm.x86.avx.maskstore.ps.256(i8* undef, <8 x i32> <i32 -1, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0>, <8 x float> undef) nounwind
  unreachable

cif_mixed_test_any_check:
  unreachable
}

define void @add8i32(<8 x i32>* %ret, <8 x i32>* %bp) nounwind {
; CHECK-LABEL: add8i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovups (%rsi), %xmm0
; CHECK-NEXT:    vmovups 16(%rsi), %xmm1
; CHECK-NEXT:    vmovups %xmm1, 16(%rdi)
; CHECK-NEXT:    vmovups %xmm0, (%rdi)
; CHECK-NEXT:    retq
;
; CHECK_O0-LABEL: add8i32:
; CHECK_O0:       # %bb.0:
; CHECK_O0-NEXT:    vmovdqu (%rsi), %xmm0
; CHECK_O0-NEXT:    vmovdqu 16(%rsi), %xmm1
; CHECK_O0-NEXT:    # implicit-def: $ymm2
; CHECK_O0-NEXT:    vmovaps %xmm0, %xmm2
; CHECK_O0-NEXT:    vinsertf128 $1, %xmm1, %ymm2, %ymm2
; CHECK_O0-NEXT:    vmovdqu %ymm2, (%rdi)
; CHECK_O0-NEXT:    vzeroupper
; CHECK_O0-NEXT:    retq
  %b = load <8 x i32>, <8 x i32>* %bp, align 1
  %x = add <8 x i32> zeroinitializer, %b
  store <8 x i32> %x, <8 x i32>* %ret, align 1
  ret void
}

define void @add4i64a64(<4 x i64>* %ret, <4 x i64>* %bp) nounwind {
; CHECK-LABEL: add4i64a64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovaps (%rsi), %ymm0
; CHECK-NEXT:    vmovaps %ymm0, (%rdi)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
;
; CHECK_O0-LABEL: add4i64a64:
; CHECK_O0:       # %bb.0:
; CHECK_O0-NEXT:    vmovaps (%rsi), %ymm0
; CHECK_O0-NEXT:    vmovdqa %ymm0, (%rdi)
; CHECK_O0-NEXT:    vzeroupper
; CHECK_O0-NEXT:    retq
  %b = load <4 x i64>, <4 x i64>* %bp, align 64
  %x = add <4 x i64> zeroinitializer, %b
  store <4 x i64> %x, <4 x i64>* %ret, align 64
  ret void
}

define void @add4i64a16(<4 x i64>* %ret, <4 x i64>* %bp) nounwind {
; CHECK-LABEL: add4i64a16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovaps (%rsi), %xmm0
; CHECK-NEXT:    vmovaps 16(%rsi), %xmm1
; CHECK-NEXT:    vmovaps %xmm1, 16(%rdi)
; CHECK-NEXT:    vmovaps %xmm0, (%rdi)
; CHECK-NEXT:    retq
;
; CHECK_O0-LABEL: add4i64a16:
; CHECK_O0:       # %bb.0:
; CHECK_O0-NEXT:    vmovdqa (%rsi), %xmm0
; CHECK_O0-NEXT:    vmovdqa 16(%rsi), %xmm1
; CHECK_O0-NEXT:    # implicit-def: $ymm2
; CHECK_O0-NEXT:    vmovaps %xmm0, %xmm2
; CHECK_O0-NEXT:    vinsertf128 $1, %xmm1, %ymm2, %ymm2
; CHECK_O0-NEXT:    vmovdqu %ymm2, (%rdi)
; CHECK_O0-NEXT:    vzeroupper
; CHECK_O0-NEXT:    retq
  %b = load <4 x i64>, <4 x i64>* %bp, align 16
  %x = add <4 x i64> zeroinitializer, %b
  store <4 x i64> %x, <4 x i64>* %ret, align 16
  ret void
}

