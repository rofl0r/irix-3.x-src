; File: pasmove.text
; Date: 08-Nov-83

        ident   pasmove
        
        global  %_MOVEL
        
;
; %_MOVEL - Moveleft
;
; Parameters: ST.L - From Address
;             ST.L - To Address
;             ST.W - # Bytes to move
;
; Scratches: D0,D1,A0,A1
;

%_MOVEL 
        move.l  (sp)+,d1        ; Pop return address
        move.w  (sp)+,d0        ; Pop # bytes
        move.l  (sp)+,a0        ; Pop TO address
        move.l  (sp)+,a1        ; Pop FROM address
        move.l  d1,-(sp)
        bra.s   l_test
l_loop  move.b  (a1)+,(a0)+
l_test  subq.w  #1,d0
        bpl.s   l_loop
        rts
        
        end
        
        ident   pasmove2
        
        global  %_MOVER,%_FILLC,%_SCANE,%_SCANN
        
;
; %_MOVER - Moveright
;
; Parameters: ST.L - From Address
;             ST.L - To Address
;             ST.W - # Bytes to move
;
; Scratches: D0,D1,A0,A1
;

%_MOVER 
        move.l  (sp)+,d1        ; Pop return address
        move.w  (sp)+,d0        ; Pop # bytes
        move.l  (sp)+,a0        ; Pop TO address
        move.l  (sp)+,a1        ; Pop FROM address
        move.l  d1,-(sp)
        adda.w  d0,a0
        adda.w  d0,a1
        bra.s   r_test
r_loop  move.b  -(a1),-(a0)
r_test  subq.w  #1,d0
        bpl.s   r_loop
        rts
        
;
; %_FILLC - Fillchar
;
; Parameters: ST.L - Address to fill
;             ST.W - # Bytes
;             ST.W - Char
;
; Scratches: D0,D1,A0,A1
;

%_FILLC 
        move.l  (sp)+,a1        ; Pop return address
        move.w  (sp)+,d0        ; Pop character
        move.w  (sp)+,d1        ; Pop # bytes
        move.l  (sp)+,a0        ; Pop address to fill
        bra.s   f_test
f_loop  move.b  d0,(a0)+
f_test  subq.w  #1,d1
        bpl.s   f_loop
        jmp     (a1)

;
; %_SCANE - Scan equal
;
; Parameters: ST.W - Length to scan
;             ST.W - Character to scan for
;             ST.L - Address to scan
;
; Result:     D0.W - Result
;
; Scratches: Only D0
;

%_SCANE 
        movem.l d1-d2/a0,-(sp)
        clr.w   d2              ; The Result
        move.l  16(sp),a0       ; Address to scan
        move.w  20(sp),d0       ; Character to scan for
        move.w  22(sp),d1       ; Length to scan
        beq.s   se_done
        bmi.s   se_mi
ep_loop cmp.b   (a0)+,d0
        beq.s   se_done
        addq.w  #1,d2           ; Bump result
        subq.w  #1,d1
        bgt.s   ep_loop
        bra.s   se_done
se_mi   addq.l  #1,a0
em_loop cmp.b   -(a0),d0
        beq.s   se_done
        subq.w  #1,d2
        addq.w  #1,d1
        bmi.s   em_loop
se_done move.w  d2,d0           ; Store the result
        move.l  12(sp),20(sp)   ; Set up return address
        movem.l (sp)+,d1-d2/a0
        addq.l  #8,sp
        rts

;
; %_SCANN - Scan not equal
;
; Parameters: ST.W - Length to scan
;             ST.W - Character to scan for
;             ST.L - Address to scan
;
; Result:     D0.W - Result
;
; Scratches: Only D0
;

%_SCANN 
        movem.l d1-d2/a0,-(sp)
        clr.w   d2              ; The Result
        move.l  16(sp),a0       ; Address to scan
        move.w  20(sp),d0       ; Character to scan for
        move.w  22(sp),d1       ; Length to scan
        beq.s   sn_done
        bmi.s   sn_mi
np_loop cmp.b   (a0)+,d0
        bne.s   sn_done
        addq.w  #1,d2           ; Bump result
        subq.w  #1,d1
        bgt.s   np_loop
        bra.s   sn_done
sn_mi   addq.l  #1,a0
nm_loop cmp.b   -(a0),d0
        bne.s   sn_done
        subq.w  #1,d2
        addq.w  #1,d1
        bmi.s   nm_loop
sn_done move.w  d2,d0           ; Store the result
        move.l  12(sp),20(sp)   ; Set up return address
        movem.l (sp)+,d1-d2/a0
        addq.l  #8,sp
        rts

        end

                                                                                                                                                                                                                                                                                                                                                                                                                    