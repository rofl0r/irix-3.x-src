|addressed unsigned long remainder: *dividend = *dividend % divisor
|
| GB - SGI. mc68020 version  5/19/85

include(../DEFS.m4)

ASENTRY(aulrem)
|
|	addressed signed long remainder.  
|	
|	sp@(4) - address of dividend
|	sp@(8) - divisor
|
	movl	sp@(8),d0
	movl	sp@(4),a0
	bra	goaulrem

RASENTRY(raulrem)
|
|	a0 - address of dividend
|	d0 - divisor
|
goaulrem:
|	
|	d1 is volatile, so we can clobber it.
|	
	movl	a0@,d1		|get dividend
	divull	d0,d0:d1	|do the 32/32 division 
				|and get remainder in d0	
	movl	d0,a0@
	rts
