/*
Copyright (c) 2005 X.Org Foundation LLC

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
* Copyright (c) Applied Testing and Technology, Inc. 1995
* All Rights Reserved.
*
* Project: VSW5
*
* File: src/bin/mc/ma.c
*
* Description:
*       ma utilitie routines
*
* Modifications:
* $Log: ma.c,v $
* Revision 1.1  2005-02-12 14:37:14  anderson
* Initial revision
*
* Revision 8.0  1998/12/23 23:24:13  mar
* Branch point for Release 5.0.2
*
* Revision 7.0  1998/10/30 22:42:24  mar
* Branch point for Release 5.0.2b1
*
* Revision 6.0  1998/03/02 05:16:40  tbr
* Branch point for Release 5.0.1
*
* Revision 5.0  1998/01/26 03:13:12  tbr
* Branch point for Release 5.0.1b1
*
* Revision 4.0  1995/12/15 08:41:17  tbr
* Branch point for Release 5.0.0
*
* Revision 3.1  1995/12/15  00:38:01  andy
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

#include	"stdio.h"
#include	"string.h"

char	*strtok();

#include	"mc.h"

extern	struct	state	State;
extern	int 	hflag;
extern	int 	sflag;

#define	F_BANNER	"mabanner.tmc"
#define	F_STDHEADER	"maheader.mc"
#define	F_HEADER	"maheader.tmc"
#define	F_TEXT		"matext.tmc"

static	FILE	*FpBanner;
static	FILE	*FpHeader;
static	FILE	*FpText;

void
macopyright(fp, buf)
FILE	*fp;
char	*buf;
{
static	int 	firsttime = 1;

	while (newline(fp, buf) != NULL && !SECSTART(buf)) {
		if (strncmp(buf, " */", 3) == 0)
			strcpy(buf, "* \n");
		if (firsttime) {
			fputs("'\\\" ", FpBanner);
			fputs(buf, FpBanner);
		}
	}
	firsttime = 0;
}

void
maheader(fp, buf)
FILE	*fp;
char	*buf;
{
	fprintf(FpText, ".TH %s %s\n", State.name, State.chap);
	skip(fp, buf);
}

void
maassertion(fp, buf)
FILE	*fp;
char	*buf;
{
	fprintf(FpText, ".TI ");
	if (State.category != CAT_NONE)
		fprintf(FpText, "%c ", (char)State.category);
	fprintf(FpText, "\\\" %s-%d\n",
		State.name, State.assertion);
	echon(fp, buf, FpText);
	if (State.category == CAT_B || State.category == CAT_D) {
		fprintf(FpText, ".br\n");
		fprintf(FpText, "Reason for omission: %s\n", State.reason);
	}
}

void
madefassertion(fp, buf)
FILE	*fp;
char	*buf;
{
	fprintf(FpText, ".TI def \\\" %s-%d\n", State.name, State.assertion);
	echon(fp, buf, FpText);
}

/* Hooks */
/*ARGSUSED*/
void
mastart(buf)
char	*buf;
{
	FpBanner = cretmpfile(F_BANNER, NULL);
	FpText = cretmpfile(F_TEXT, NULL);
}

/*ARGSUSED*/
void
maend(buf)
char	*buf;
{
	fputs("'\\\"\n", FpBanner);
	outfile(FpBanner);
	if (hflag) {
		if (sflag) {
			FpHeader = cretmpfile(F_HEADER, NULL);
			fprintf(FpHeader, ".so head.t\n");
			outfile(FpHeader);
		} else {
			outcopy(F_STDHEADER);
		}
	}
	outfile(FpText);
}

void
macomment(buf)
char	*buf;
{
extern	int 	pflag;

	if (pflag) {
		fputs(".NS\n", FpText);
		fputs(buf, FpText);
		fputs(".NE\n", FpText);
	}
}
