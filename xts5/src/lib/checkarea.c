/*
Copyright (c) 2005 X.Org Foundation L.L.C.
Copyright (c) Open Text SA and/or Open Text ULC

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
/*
*
* Copyright Applied Testing and Technology Inc. 1995
* All rights reserved
*
* Project: VSW5
*
* File:	xts5/src/lib/checkarea.c
*
* Description:
*	Pixel area support routines
*
* Modifications:
* $Log: checkarea.c,v $
* Revision 1.2  2005-11-03 08:42:01  jmichael
* clean up all vsw5 paths to use xts5 instead.
*
* Revision 1.1.1.2  2005/04/15 14:05:09  anderson
* Reimport of the base with the legal name in the copyright fixed.
*
* Revision 8.0  1998/12/23 23:24:26  mar
* Branch point for Release 5.0.2
*
* Revision 7.0  1998/10/30 22:42:37  mar
* Branch point for Release 5.0.2b1
*
* Revision 6.0  1998/03/02 05:16:51  tbr
* Branch point for Release 5.0.1
*
* Revision 5.0  1998/01/26 03:13:24  tbr
* Branch point for Release 5.0.1b1
*
* Revision 4.1  1996/01/25 01:57:14  andy
* Portability improvements from DEPLOY tools
*
* Revision 4.0  1995/12/15  08:41:52  tbr
* Branch point for Release 5.0.0
*
* Revision 3.1  1995/12/15  00:38:59  andy
* Prepare for GA Release
*
*/

/*
Portions of this software are based on Xlib and X Protocol Test Suite.
We have used this material under the terms of its copyright, which grants
free use, subject to the conditions below.  Note however that those
portions of this software that are based on the original Test Suite have
been significantly revised and that all such revisions are copyright (c)
1995 Applied Testing and Technology, Inc.  Insomuch as the proprietary
revisions cannot be separated from the freely copyable material, the net
result is that use of this software is governed by the ApTest copyright.

Copyright (c) 1990, 1991  X Consortium

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
X CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Except as contained in this notice, the name of the X Consortium shall not be
used in advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization from the X Consortium.

Copyright 1990, 1991 by UniSoft Group Limited.

Permission to use, copy, modify, distribute, and sell this software and
its documentation for any purpose is hereby granted without fee,
provided that the above copyright notice appear in all copies and that
both that copyright notice and this permission notice appear in
supporting documentation, and that the name of UniSoft not be
used in advertising or publicity pertaining to distribution of the
software without specific, written prior permission.  UniSoft
makes no representations about the suitability of this software for any
purpose.  It is provided "as is" without express or implied warranty.
*/

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include	<stdlib.h>
#include	<stdio.h>
#include	<unistd.h>
#include	"xtest.h"
#include	"X11/Xlib.h"
#include	"X11/Xutil.h"
#include	"xtestlib.h"
#include	"pixval.h"

static	void	doerr();
static	void	dorgnerr(XImage *im, Region rgn, unsigned long inpix, unsigned long outpix, int flags);

#define	inarea(ap, x, y)	\
(\
	(x >= ap->x && x < ap->x+ap->width && y >= ap->y && y < ap->y+ap->height)\
	? True: False\
)

/*
 * Check that each pixel within the specified area is set to
 * inpix and that each pixel outside the area is set to outpix.
 * If flags are CHECK_IN only the inside is checked.
 * If flags are CHECK_OUT only the outside is checked.
 * flags of 0 or CHECK_ALL check both.
 * If ap is NULL then the whole window is checked.  (See also checkclear)
 * (See also checkregion)
 */
Status
checkarea(disp, d, ap, inpix, outpix, flags)
Display	*disp;
Drawable d;
register struct	area	*ap;
unsigned long 	inpix;
unsigned long 	outpix;
int 	flags;
{
register int 	x, y;
XImage	*im;
int 	xorig;
int 	yorig;
unsigned int 	width;
unsigned int 	height;
register unsigned long	pix;
struct	area area;
int 	inloopflag = 0;

	if (flags == 0)
		flags = CHECK_ALL;
	if ((flags & CHECK_ALL) == 0) {
		report("assert error in checkarea()");
		printf("assert error in checkarea()\n");
		exit(1);
	}

	getsize(disp, d, &width, &height);

	/*
	 * If a NULL ap has been given then look at the whole window.
	 */
	if (ap == (struct area *)0) {
		ap = &area;
		ap->x = 0;
		ap->y = 0;
		ap->width = width;
		ap->height = height;
		flags &= ~CHECK_OUT;
	}

	im = XGetImage(disp, d, 0, 0, width, height, AllPlanes, ZPixmap);
	if (im == (XImage*)0) {
		delete("XGetImage failed");
		return(False);
	}

	/*
	 * If we are only checking inside then only examine that part.
	 */
	if ((flags & CHECK_ALL) == CHECK_IN) {
		xorig = ap->x;
		yorig = ap->y;
		width = ap->width;
		height = ap->height;
	} else {
		xorig = 0;
		yorig = 0;
	}

	for (y = yorig; y < yorig+height; y++) {
		for (x = xorig; x < xorig+width; x++) {
			inloopflag = 1;
			pix = XGetPixel(im, x, y);
			if (inarea(ap, x, y)) {
				if (pix != inpix && (flags & CHECK_IN)) {
					if (!(flags & CHECK_DIFFER))
						doerr(im, ap, inpix, outpix, flags);
					XDestroyImage(im);
					return(False);
				}
			} else {
				if (pix != outpix && (flags & CHECK_OUT)) {
					if (!(flags & CHECK_DIFFER))
						doerr(im, ap, inpix, outpix, flags);
					XDestroyImage(im);
					return(False);
				}
			}
		}
	}

	/* This is to chatch bugs */
	if (inloopflag == 0) {
		delete("No pixels checked in checkarea - internal error");
		XDestroyImage(im);
		return(False);
	}
	XDestroyImage(im);
	return(True);
}

/*
 * Check that the whole window or pixmap is clear (set to pixel value W_BG)
 */
Status
checkclear(disp, d)
Display	*disp;
Drawable	d;
{
	return(checkarea(disp, d, (struct area *)0, W_BG, W_BG, CHECK_IN));
}

/*
 * Same as checkarea, except it takes a 'Region' instead of an 'area'
 */
Status
checkregion(Display *disp, Drawable d, Region rgn,
            unsigned long inpix, unsigned long outpix, int flags)
{
int 	x, y;
XImage	*im;
int 	xorig;
int 	yorig;
unsigned int 	width;
unsigned int 	height;
unsigned long	pix;
int 	inloopflag = 0;

	if (flags == 0)
		flags = CHECK_ALL;
	if ((flags & CHECK_ALL) == 0) {
		report("assert error in checkregion()");
		printf("assert error in checkregion()\n");
		exit(1);
	}

	getsize(disp, d, &width, &height);

	/*
	 * If a NULL region has been given then error out
	 */
	if (rgn == NULL) {
		report("assert error in checkregion()");
		printf("assert error in checkregion()\n");
		exit(1);
	}

	im = XGetImage(disp, d, 0, 0, width, height, AllPlanes, ZPixmap);
	if (im == (XImage*)0) {
		delete("XGetImage failed");
		return(False);
	}

	/*
	 * If we are only checking inside then only examine that part.
	 */
	if ((flags & CHECK_ALL) == CHECK_IN) {
		XRectangle rect;
		XClipBox(rgn, &rect);
		xorig = rect.x;
		yorig = rect.y;
		width = rect.width;
		height = rect.height;
	} else {
		xorig = 0;
		yorig = 0;
	}

	for (y = yorig; y < yorig+height; y++) {
		for (x = xorig; x < xorig+width; x++) {
			inloopflag = 1;
			pix = XGetPixel(im, x, y);
			if (XPointInRegion(rgn, x, y)) {
				if (pix != inpix && (flags & CHECK_IN)) {
					if (!(flags & CHECK_DIFFER))
						dorgnerr(im, rgn, inpix, outpix, flags);
					XDestroyImage(im);
					return(False);
				}
			} else {
				if (pix != outpix && (flags & CHECK_OUT)) {
					if (!(flags & CHECK_DIFFER))
						dorgnerr(im, rgn, inpix, outpix, flags);
					XDestroyImage(im);
					return(False);
				}
			}
		}
	}

	/* This is to catch bugs */
	if (inloopflag == 0) {
		delete("No pixels checked in checkregion - internal error");
		XDestroyImage(im);
		return(False);
	}
	XDestroyImage(im);
	return(True);
}

/*
 * Make up an error file by faking a known good image.
 */
static void
doerr(im, ap, inpix, outpix, flags)
XImage	*im;
struct	area	*ap;
unsigned long	inpix;
unsigned long	outpix;
int 	flags;
{
XImage	*good;
XImage	*bad;
int 	x, y;
char	name[32];
extern	int 	Errnum;

	flags &= CHECK_ALL;

	/*
	 * Make copies of the image, because we are going to scribble into them.
	 */
	good = XSubImage(im, 0, 0, im->width, im->height);
	bad = XSubImage(im, 0, 0, im->width, im->height);

	for (y = 0; y < im->height; y++) {
		for (x = 0; x < im->width; x++) {
			/*
			 * For parts of the image that we are not interested in
			 * then we set both good and bad to W_BG.
			 * Otherwise build up a good image.
			 */
			if (inarea(ap, x, y)) {
				if (flags & CHECK_IN) {
					XPutPixel(good, x, y, inpix);
				} else {
					XPutPixel(good, x, y, W_BG);
					XPutPixel(bad, x, y, W_BG);
				}
			} else {
				if (flags & CHECK_OUT) {
					XPutPixel(good, x, y, outpix);
				} else {
					XPutPixel(good, x, y, W_BG);
					XPutPixel(bad, x, y, W_BG);
				}
			}
		}
	}
	report("Pixel mismatch in image");

	/* Making up an error file should be a subroutine.. */
	sprintf(name, "Err%04d.err", Errnum++);
	report("See file %s for details", name);
	unlink(outfile(name));
	dumpimage(bad, name, (struct area *)0);
	dumpimage(good, name, (struct area *)0);

	XDestroyImage(good);
	XDestroyImage(bad);
}

/*
 * Make up an error file by faking a known good image.
 */
static void
dorgnerr(XImage *im, Region rgn, unsigned long inpix, unsigned long outpix, int flags)
{
XImage	*good;
XImage	*bad;
int 	x, y;
char	name[32];
extern	int 	Errnum;

	flags &= CHECK_ALL;

	/*
	 * Make copies of the image, because we are going to scribble into them.
	 */
	good = XSubImage(im, 0, 0, im->width, im->height);
	bad = XSubImage(im, 0, 0, im->width, im->height);

	for (y = 0; y < im->height; y++) {
		for (x = 0; x < im->width; x++) {
			/*
			 * For parts of the image that we are not interested in
			 * then we set both good and bad to W_BG.
			 * Otherwise build up a good image.
			 */
			if (XPointInRegion(rgn, x, y)) {
				if (flags & CHECK_IN) {
					XPutPixel(good, x, y, inpix);
				} else {
					XPutPixel(good, x, y, W_BG);
					XPutPixel(bad, x, y, W_BG);
				}
			} else {
				if (flags & CHECK_OUT) {
					XPutPixel(good, x, y, outpix);
				} else {
					XPutPixel(good, x, y, W_BG);
					XPutPixel(bad, x, y, W_BG);
				}
			}
		}
	}
	report("Pixel mismatch in image");

	/* Making up an error file should be a subroutine.. */
	sprintf(name, "Err%04d.err", Errnum++);
	report("See file %s for details", name);
	unlink(name);
	dumpimage(bad, name, (struct area *)0);
	dumpimage(good, name, (struct area *)0);

	XDestroyImage(good);
	XDestroyImage(bad);
}
