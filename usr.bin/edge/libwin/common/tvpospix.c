/*
 * Transform a position in text coordinates to a pixel offset to the lower
 * left hand corner of the character.
 *
 * Written by: Kipp Hickman
 *
 * $Source: /d2/3.7/src/usr.bin/edge/libwin/common/RCS/tvpospix.c,v $
 * $Revision: 1.1 $
 * $Date: 89/03/27 17:48:12 $
 */

#include "tf.h"

/*
 * Find which pixel we are at on a given line
 */
long
tv_coltopix(tv, tl, column)
	register textview *tv;
	register textline *tl;
{
	register struct textfont *tfont;
	register long col;
	register int charcode;
	register int i;

	if (column > tl->tl_len)
		return (-1);

	col = 0;
	if (tl->tl_looks & LOOKS_SAME) {
		register unsigned char *cp;
		register long *widthtab;

		tfont = &tv->tv_fontinfo[(tl->tl_looks & LOOKS_FONT)
				>> LOOKS_FONTSHIFT];
		if (!tfont->valid)
			tv_getfontdata(tfont);
		widthtab = tfont->widthtab;
		cp = tl->tl_cdata;
		for (i = column; --i >= 0; ) {
			charcode = *cp++;
			if (charcode == '\t')
				col = tv_tabcol(tv, col);
			else
				col += widthtab[charcode];
		}
	} else {
		register long *lp;
		long l;

		lp = tl->tl_ldata;
		for (i = column; --i >= 0; ) {
			l = *lp++;
			charcode = l & LOOKS_INDEX;
			tfont = &tv->tv_fontinfo[(l & LOOKS_FONT)
					>> LOOKS_FONTSHIFT];
			if (!tfont->valid)
				tv_getfontdata(tfont);
			if (charcode == '\t')
				col = tv_tabcol(tv, col);
			else
				col += tfont->widthtab[charcode];
		}
	}
	return (tv->tv_leftpix + col);
}

int
tvpostopix(tv, row, col, xpix, ypix)
	textview *tv;
	long row, col;
	long *xpix, *ypix;
{
	textline *tl;
	textframe *tf;
	long y;
	int i;
	long spot;

	*xpix = -1;
	*ypix = -1;
	tf = tv->tv_tf;

	/* fix toprow, if its messed up */
	if (tv->tv_toprow >= tf->tf_rows)
		tv->tv_toprow = tf->tf_rows - 1;

	/* find line containing top row */
	y = tv->tv_ysize;
	tl = tf_findline(tf, tv->tv_toprow, 0);
	spot = tv->tv_toprow;
	while (tl) {
		if (!tl->tl_height)
			tv_findheight(tv, tl);
		y -= tl->tl_height;
		if (spot == row) {
			/*
			 * Found the right row, now find the right
			 * column.
			 */
			*ypix = y;
			*xpix = tv_coltopix(tv, tl, col);
			return (1);
		}
		tl = tl->tl_next;
		spot++;
	}
	return (0);
}
