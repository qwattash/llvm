# RUN: llvm-mc %s -triple=cheri-unknown-freebsd -show-encoding -mcpu=cheri | FileCheck %s
#
# Check that the assembler is able to handle capability get instructions.
#

# CHECK: csealdata	$c1, $c2, $c3
# CHECK: encoding: [0x48,0x41,0x10,0xc0]
	csealdata	$c1, $c2, $c3
# CHECK: cunseal	$c1, $c2, $c3
# CHECK: encoding: [0x48,0x61,0x10,0xc0]
	cunseal		$c1, $c2, $c3
# CHECK: csealcode	$c1, $c2
# CHECK: encoding: [0x48,0x21,0x10,0x00]
	csealcode	$c1, $c2
# CHECK: candperm	$c1, $c2, $12
# CHECK: encoding: [0x48,0x81,0x13,0x00]
	candperm	$c1, $c2, $t0
# CHECK: csettype	$c1, $c2, $12
# CHECK: encoding: [0x48,0x81,0x13,0x01]
	csettype	$c1, $c2, $t0
# CHECK: cincbase	$c1, $c2, $12
# CHECK: encoding: [0x48,0x81,0x13,0x02]
	cincbase	$c1, $c2, $t0
# CHECK: csetlen	$c1, $c2, $12
# CHECK: encoding: [0x48,0x81,0x13,0x03]
	csetlen		$c1, $c2, $t0
# CHECK: ccleartag	$c1
# CHECK: encoding: [0x48,0x81,0x00,0x05]
	ccleartag	$c1