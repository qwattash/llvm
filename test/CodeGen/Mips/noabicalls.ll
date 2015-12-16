; check behaviour for non-pic code generation in MIPS n64
; RUN: llc -filetype=asm -mtriple mips64el-unknown-linux -mcpu=mips64 -relocation-model=static -mattr noabicalls %s -o - | FileCheck -implicit-check-not='.abicalls' %s

@glob_ext = external global i32, align 4

; Function Attrs: nounwind
define i32 @call_ext() #0 {

; TO DO permissively allow all registers for relocation, restrict later if needed
; CHECK: lui [[VREG_HI:\$[0-9]+]],%highest(glob_ext)
; CHECK: daddiu [[VREG_ADDR:\$[0-9]+]],[[VREG_HI]],%higher(glob_ext)
; CHECK: dsll [[VREG_ADDR]],[[VREG_ADDR]],16
; CHECK: daddiu [[VREG_ADDR]],[[VREG_ADDR]],%hi(glob_ext)
; CHECK: dsll [[VREG_ADDR]],[[VREG_ADDR]],16
; CHECK: daddiu [[VREG_ADDR]],[[VREG_ADDR]],%lo(glob_ext)
; CHECK: ld {{\$[0-9]+}},[[VREG_ADDR]]
  %1 = load i32, i32* @glob_ext, align 4

; TO DO permissively allow all registers for relocation, restrict later if needed
; CHECK: lui [[FREG_HI:\$[0-9]+]],%highest(f_glob)
; CHECK: daddiu [[FREG_ADDR:\$[0-9]+]],[[FREG_HI]],%higher(f_glob)
; CHECK: dsll [[FREG_ADDR]],[[FREG_ADDR]],16
; CHECK: daddiu [[FREG_ADDR]],[[FREG_ADDR]],%hi(f_glob)
; CHECK: dsll [[FREG_ADDR]],[[FREG_ADDR]],16
; CHECK: daddiu [[FREG_ADDR]],[[FREG_ADDR]],%lo(f_glob)
; CHECK: jalr [[FREG_ADDR]]
  %2 = call i32 @f_glob(i32 signext %1)
  ret i32 %2
}

declare i32 @f_glob(i32 signext) #1

;