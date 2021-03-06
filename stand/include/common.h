/*
* $Source: /d2/3.7/src/stand/include/RCS/common.h,v $
* $Revision: 1.1 $
* $Date: 89/03/27 17:13:36 $
*/

/*
** The common area defined.  It lives at the beginning of the static
** ram.  A portion of it is considered non-volatile, and that portion
** is checksummed to insure we can detect changes.
*/
struct commstruct
{
	u_long	c_mem;		/* each bit represents 1/2mb	*/
	u_long	c_memmb;	/* number of megabytes of mem	*/
	u_short	*c_mbmemadr;	/* multibus mem address		*/
	u_short *c_mbmapadr;	/* multibus map address		*/
	u_short	c_mbspg;	/* multibus mem starting page	*/
	u_char	c_havefpa;	/* fpa flag			*/
	u_short	c_dcconfig;	/* dcr bits for monitor types	*/
	u_short	c_flags;	/* flag bits			*/
	int	(*c_getc)(),	/* getchar routine for console	*/
		(*c_putc)();	/* putchar routine for console	*/
	u_short	c_lflag;	/* tty flag bits		*/
	u_char	c_powerflag;	/* copy of what is in tod ram	*/
	u_char	c_bootflag;	/* copy of what is in tod ram	*/
	u_char	c_dcoptions;	/* dcr option bits		*/
	u_char	c_pridis;	/* primary display type		*/
	u_char	c_secdis;	/* secondary display type	*/
	u_char	c_screenx;	/* current cursor position	*/
	u_char	c_screeny;	/* current cursor position	*/
	u_char	c_nblines; 	/* #lines to clear after cursor */
	u_char	c_savenblines;	/* #lines to clear after cursor */
	int	c_chksum;	/* holds checksum for "static"	*/
				/*  portion of common structure	*/
	int	*c_nofault;	/* if set, calls supplied trap	*/
				/*   handler.			*/
	long	c_entrypt;	/* entry point of loaded/go pgm	*/
	long	c_gostk;	/* stack value for go cmd	*/
	int	c_argc;		/* argc				*/
	char	*c_argv[ 8 ];	/* argv pointers		*/
	char	c_argbuf[ 256 ];/* holds argument strings	*/
	/*
	** The c_magic through c_bootp fields were added in
	** PROM revision level 3.0.8.  The presence and validity
	** of the new fields can be determined by checking c_magic.
	** The intent is to provide support for diskless workstations
	** later without issuing proms again.  Probably a hopeless
	** cause, but it's worth a try.
	*/
	u_long	c_magic;	/* magic to indicate new format	*/ 
	u_char	c_iaddr[ 4 ];	/* my internet addr (host order)*/
	u_char	c_siaddr[ 4 ];	/* boot server ip addr (host order)*/
	u_char	c_giaddr[ 4 ];	/* gateway ip addr (host order)	*/
	u_char	c_bootp[ 64 ];	/* opaque data from BOOTP	*/
};

#define	_commdat	((struct commstruct *)SRAM_BASE)
#define	argc	(_commdat->c_argc)
#define	argv	(_commdat->c_argv)
#define	argbuf	(_commdat->c_argbuf)

#define	COMMON_MAGIC	0x6241986	/* correct value for c_magic	*/

/*
** The various flag bits defined
*/
#define	TTY_DUMB	0x1	/* if on: console == duart 0 port B	*/
				/* else graphics tty, screen == GE;	*/
				/*      keyboard == duart 0 port A	*/
#define	GL1_PRESENT	0x2
#define	GL2_PRESENT	0x4
#define	DC_HIGH		0x200

# define SETGL1		(_commdat->c_flags |= GL1_PRESENT)
# define SETGL2		(_commdat->c_flags |= GL2_PRESENT)
# define ISGL1		(_commdat->c_flags & GL1_PRESENT)
# define ISGL2		(_commdat->c_flags & GL2_PRESENT)
# define CLEARGL	(_commdat->c_flags &= ~(GL1_PRESENT|GL2_PRESENT))
