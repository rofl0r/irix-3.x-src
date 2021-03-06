; File: umem.text
; Date: 08-Nov-83

        IDENT   IDMEM
        
        GLOBAL  %_NEW,%_NEW4
        EXTERN  _sbrk
        EXTERN  %_PANIC,%_HALTF,%_PRLOC
        
FREEMEM EQU     28              ; FREEMEM(A5) is pointer to heap top
BRKADDR EQU   1868              ; BRKADDR(A5) is break address

;
; %_NEW - Allocate memory in the heap
;
; Parameters:  ST.W - Number of bytes needed
;
;
; %_NEW4 - Allocate memory in the heap
;
; Parameters:  ST.L - Number of bytes needed
;
; Scratches D0,D1,D2,A0,A1
;

%_NEW
        MOVE.L  (SP)+,A1        ; Return address
        MOVE.W  (SP)+,D0        ; Number of bytes
        EXT.L   D0              ; Make it a long
        MOVE.L  D0,-(SP)        ; Push it for call on %_NEW4
        MOVE.L  A1,-(SP)        ; Replace return address, fall through to %_NEW4

%_NEW4
        MOVE.L  4(SP),D0        ; Number of bytes
        MOVE.L  (SP)+,(SP)      ; Position return address
        MOVE.L  D0,D2           ; Need a copy to destroy
        ANDI.L  #1,D2           ; Is it odd
        BEQ.S   EVEN
        ADDQ.L  #1,D0           ; Round odd up
EVEN    MOVE.L  FREEMEM(A5),D1  ; Pointer to top of heap
        MOVE.L  D1,-(SP)        ; Push the pointer (return value)
        ADD.L   D0,D1           ; Allocate the space
        MOVE.L  D1,FREEMEM(A5)  ; Remember new top of heap
        SUB.L   BRKADDR(A5),D1  ; D1 is number of bytes beyond break
        BLT.S   NWOK            ; Negative, then not beyond break
        ADD.L   #4096,D1        ; Add some breathing room on
        ADD.L   D1,BRKADDR(A5)  ; Set BRKADDR to new break
        MOVEM.L D3-D7/A2-A6,-(SP) ; Don't count on _sbrk to preserve anything
        MOVE.L  D1,-(SP)        ; Want this many bytes
        JSR     _sbrk           ; Get them
        ADDQ.W  #4,SP           ; Discard parameter
        MOVEM.L (SP)+,D3-D7/A2-A6 ; Restore regs
        TST.L   D0              ; Succeed?
        BLT.S   NERR            ; If less than zero, can break for more space
NWOK    MOVE.L  (SP)+,D0        ; Return the value
        RTS
NERR    LEA     NMESS,A0
        MOVEQ   #18,D0
        JSR     %_PANIC         ; Print an error message
        MOVE.L  4(SP),-(SP)     ; Push return address
        JSR     %_PRLOC         ; Print location
        JSR     %_HALTF         ; Kill this process

NMESS   DATA.B  'Ran out of memory '
        
        END
        
        IDENT   IDMEM2
        
        GLOBAL  %_MARK,%_RELSE,%_MEMAV,%_DISP
        GLOBAL  %_DISP4
        
FREEMEM EQU     28              ; FREEMEM(A5) is pointer to heap top

;
; %_MARK - Mark the heap
;
; Parameters:  ST.L - Address of pointer to be marked
;

%_MARK
        MOVE.L  (SP)+,A1        ; Return address
        MOVE.L  (SP)+,A0        ; Address of pointer
        MOVE.L  FREEMEM(A5),(A0)
        JMP     (A1)

;
; %_RELSE - Release the heap
;
; Parameters:  ST.L - Address of pointer to release to
;

%_RELSE
        MOVE.L  (SP)+,A1        ; Return address
        MOVE.L  (SP)+,A0        ; Address of pointer
        MOVE.L  (A0),FREEMEM(A5)
        JMP     (A1)

;
; %_MEMAV - Memory Available in the heap
;
; Parameters:  None.
;
; Results:     D0.L - #bytes available
;
; Scratches: Only D0
;

%_MEMAV
        MOVE.L  #30000,D0       ; Any large number is an ok return
        RTS

;
; %_DISP - Dispose
;
; Parameters:  ST.L - Address of pointer
;              ST.W - Number of bytes to free
;

%_DISP
        MOVE.L  (SP)+,A1        ; Return address
        MOVE.W  (SP)+,D0        ; Number of bytes
        MOVE.L  (SP)+,A0        ; Address of pointer
        CLR.L   (A0)            ; Set the pointer to NIL
        JMP     (A1)
        
;
; %_DISP4 - Dispose
;
; Parameters:  ST.L - Address of pointer
;              ST.L - Number of bytes to free
;

%_DISP4
        MOVE.L  (SP)+,A1        ; Return address
        MOVE.L  (SP)+,D0        ; Number of bytes
        MOVE.L  (SP)+,A0        ; Address of pointer
        CLR.L   (A0)            ; Set the pointer to NIL
        JMP     (A1)
        
        END

                                                                                     