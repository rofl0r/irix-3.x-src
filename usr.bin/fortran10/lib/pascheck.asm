; File: pascheck.text
; Date: 09-Mar-83

        ident   pascheck
        
        global  %_RCHCK,%_SRCHK,%_LRCHK
        global  %_FLTCHK,%_DBLCHK
        global  %_CHKSTK

        extern  %_PANIC,%_PRLOC,%_HALTF,%_MEMAV
        
;
; %_RCHCK - Range check
;
; Parameters:  ST.W - Value to check
;              ST.W - Lower bound
;              ST.W - Upper bound
;
; Returns:     ---
;
; All regsters are preserved.
;

%_RCHCK
        move.l  d0,-(sp)        ; Save D0
        move.w  12(sp),d0       ; Fetch value
        cmp.w   10(sp),d0       ; Compare with lower bound
        blt.s   rerr            ; Print error if too small
        cmp.w   8(sp),d0        ; Compare with upper bound
        bgt.s   rerr            ; Print error if too large
        move.l  (sp)+,d0        ; Restore D0
        move.l  (sp),6(sp)      ; Move return address
        addq.l  #6,sp           ; Pop junk
        rts

;
; %_LRCHK - Long range check
;
; Parameters:  ST.L - Value to check
;              ST.L - Lower bound
;              ST.L - Upper bound
;
; Returns:     ---
;
; All regsters are preserved.
;

%_LRCHK
        move.l  d0,-(sp)        ; Save D0
        move.l  16(sp),d0       ; Fetch value
        cmp.l   12(sp),d0       ; Compare with lower bound
        blt.s   rerr            ; Print error if too small
        cmp.l   8(sp),d0        ; Compare with upper bound
        bgt.s   rerr            ; Print error if too large
        move.l  (sp)+,d0        ; Restore D0
        move.l  (sp),12(sp)     ; Move return address
        adda.w  #12,sp          ; Pop junk
        rts

rerr    lea     rmess,a0
        moveq   #12,d0
        jsr     %_PANIC         ; Print an error message
        move.l  4(sp),-(sp)     ; Push return address
        jsr     %_PRLOC         ; Print seg/offset
        jsr     %_HALTF

;
; %_SRCHK - String range check
;
; Parameters:  ST.B - Value to check: 0..255
;              ST.W - Upper bound
;
; Returns:     ---
;
; All regsters are preserved.
;

%_SRCHK
        move.w  d0,-(sp)        ; Save D0
        move.b  8(sp),d0        ; Fetch value
        andi.w  #$ff,d0         ; Make it a word
        cmp.w   6(sp),d0        ; Compare with upper bound
        bgt.s   serr            ; Print error if too large
        move.w  (sp)+,d0        ; Restore D0
        move.l  (sp),4(sp)      ; Move return address
        addq.l  #4,sp           ; Pop junk
        rts
serr    lea     smess,a0
        moveq   #19,d0
        jsr     %_PANIC         ; Print an error message
        move.l  2(sp),-(sp)     ; Push return address
        jsr     %_PRLOC         ; Print seg/offset
        jsr     %_HALTF

        
;
; %_FLTCHK - Check floating point number for INF or NAN
;
; Parameters:  ST.L - Value to check
;
; Returns:     ---
;
; All regsters are preserved.
;

%_FLTCHK
        move.w  d0,-(sp)
        move.w  6(sp),d0        ; Fetch value
        andi.w  #$7F80,d0       ; Mask off exponent
        cmpi.w  #$7F80,d0       ; Is it INF or NAN?
        beq.s   ferr            ; Yes.
        move.w  (sp)+,d0
        rts
ferr    move.l  6(sp),d0
        andi.l  #$007FFFFF,d0   ; Is it a NAN?
        beq.s   finf            ; No.
        lea     fnmess,a0
        moveq   #19,d0
        bra.s   fdoit
finf    lea     fimess,a0
        moveq   #24,d0
fdoit   jsr     %_PANIC         ; Print an error message
        move.l  2(sp),-(sp)     ; Push return address
        jsr     %_PRLOC         ; Print seg/offset
        jsr     %_HALTF
        
;
; %_DBLCHK - Check double floating point number for INF or NAN
;
; Parameters:  ST.Q - Value to check
;
; Returns:     ---
;
; All regsters are preserved.
;

%_DBLCHK
        move.w  d0,-(sp)
        move.w  6(sp),d0        ; Fetch value
        andi.w  #$7FF0,d0       ; Mask off exponent
        cmpi.w  #$7FF0,d0       ; Is it INF or NAN?
        beq.s   derr            ; Yes.
        move.w  (sp)+,d0
        rts
derr    move.l  6(sp),d0
        andi.l  #$000FFFFF,d0   ; Is it a NAN?
        bne.s   dnan            ; Yes.
        move.l  10(sp),d0       ; Don't know. Check lower part
        bne.s   dnan            ; It is a NAN
        lea     fimess,a0
        moveq   #24,d0
        bra.s   ddoit
dnan    lea     fnmess,a0
        moveq   #19,d0
ddoit   jsr     %_PANIC         ; Print an error message
        move.l  2(sp),-(sp)     ; Push return address
        jsr     %_PRLOC
        jsr     %_HALTF
        
;
; %_CHKSTK - check for stack overflow
;
; Scratches: D0
;

%_CHKSTK
        jsr     %_MEMAV
        cmpi.l  #600,d0
        blt.s   oops
        rts
oops    lea     stkmess,a0
        moveq   #15,d0
        jsr     %_PANIC
        jsr     %_PRLOC
        jsr     %_HALTF

;
; Error messages
;

rmess   data.b  'Range error '
smess   data.b  'String range error ',0
fnmess  data.b  'Floating point NAN ',0
fimess  data.b  'Floating point infinity '
stkmess data.b  'Stack overflow ',0

        end

                                                                                                                                                                                                       