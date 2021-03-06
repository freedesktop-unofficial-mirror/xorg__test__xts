Copyright (c) 2005 X.Org Foundation L.L.C.

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

Copyright (c) Applied Testing and Technology, Inc. 1995
All Rights Reserved.

>># Project: VSW5
>># 
>># File: xts5/Xlib9/XQueryTextExtents.m
>># 
>># Description:
>># 	Tests for XQueryTextExtents()
>># 
>># Modifications:
>># $Log: qrytxtextn.m,v $
>># Revision 1.2  2005-11-03 08:43:58  jmichael
>># clean up all vsw5 paths to use xts5 instead.
>>#
>># Revision 1.1.1.2  2005/04/15 14:05:39  anderson
>># Reimport of the base with the legal name in the copyright fixed.
>>#
>># Revision 8.0  1998/12/23 23:30:49  mar
>># Branch point for Release 5.0.2
>>#
>># Revision 7.0  1998/10/30 22:50:03  mar
>># Branch point for Release 5.0.2b1
>>#
>># Revision 6.0  1998/03/02 05:22:35  tbr
>># Branch point for Release 5.0.1
>>#
>># Revision 5.0  1998/01/26 03:19:07  tbr
>># Branch point for Release 5.0.1b1
>>#
>># Revision 4.0  1995/12/15 09:00:15  tbr
>># Branch point for Release 5.0.0
>>#
>># Revision 3.1  1995/12/15  00:55:38  andy
>># Prepare for GA Release
>>#
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
>>TITLE XQueryTextExtents Xlib9
>># NB.  This is int in Xlib.h, and return value is not mentioned in spec.
Status

Display	*display = Dsp;
XID 	font_ID;
char	*string;
int 	nchars;
int 	*direction_return = &direction;
int 	*font_ascent_return = &font_ascent;
int 	*font_descent_return = &font_descent;
XCharStruct	*overall_return = &overall;
>>SET startup fontstartup
>>SET cleanup fontcleanup
>>EXTERN
static	int 	direction;
static	int 	font_ascent;
static	int 	font_descent;
static	XCharStruct	overall;
>>ASSERTION Good A
>># Improved the wording a bit from that approved ....
>># When the font with font_ID
>># .A font_ID
When the
.A font_ID
argument
is a valid GContext resource,
then a call to xname returns the bounding box of the specified 8-bit
character string,
.A string ,
as rendered in
the font in the corresponding GC's
.M font
field.
>>STRATEGY
Make a string consisting of all characters from 0 to 255
Create drawable
Create gc usable with the drawable.
For each VSW5 font
  Load font
  Set font into gc.
  Call XQueryTextExtents.
  Verify by direct calculation from the metrics.
>>CODE
extern	struct	fontinfo	fontinfo[];
extern	int 	nfontinfo;
int 	i;
char	buf[256];
int 	good_direction;
int 	good_font_ascent;
int 	good_font_descent;
XCharStruct	good_overall;
Drawable	d;
GC		gc;
Font	font;

	for (i = 0; i < 256; i++)
		buf[i] = i;
	string = buf;
	nchars  = 256;

	d = defdraw(display, VI_WIN_PIX);
	gc = makegc(display, d);
	if (isdeleted())
		return;

	for (i = 0; i < nfontinfo; i++) {
		font = XLoadFont(display, fontinfo[i].name);
		XSetFont(display, gc, font);

		font_ID = XGContextFromGC(gc);
		XCALL;

		txtextents(fontinfo[i].fontstruct, (unsigned char *)string,
			nchars, &good_direction, &good_font_ascent, &good_font_descent,
			&good_overall);

		/*
		 * Don't check this because not well enough defined.
		 * Just check that it is one of the allowed values.
		 */
		if (direction != FontLeftToRight && direction != FontRightToLeft) {
			report("Font %s - Direction was %d", fontinfo[i].name);
			FAIL;
		} else
			CHECK;

		if (good_font_ascent != font_ascent) {
			report("Font %s: font ascent was %d, expecting %d",
				fontinfo[i].name, font_ascent, good_font_ascent);
			FAIL;
		} else
			CHECK;
		if (good_font_descent != font_descent) {
			report("Font %s: font descent was %d, expecting %d",
				fontinfo[i].name, font_descent, good_font_descent);
			FAIL;
		} else
			CHECK;
		if (good_overall.lbearing != overall.lbearing) {
			report("Font %s: lbearing was %d, expecting %d",
				fontinfo[i].name, overall.lbearing, good_overall.lbearing);
			FAIL;
		} else
			CHECK;
		if (good_overall.rbearing != overall.rbearing) {
			report("Font %s: rbearing was %d, expecting %d",
				fontinfo[i].name, overall.rbearing, good_overall.rbearing);
			FAIL;
		} else
			CHECK;
		if (good_overall.ascent != overall.ascent) {
			report("Font %s: ascent was %d, expecting %d",
				fontinfo[i].name, overall.ascent, good_overall.ascent);
			FAIL;
		} else
			CHECK;
		if (good_overall.descent != overall.descent) {
			report("Font %s: descent was %d, expecting %d",
				fontinfo[i].name, overall.descent, good_overall.descent);
			FAIL;
		} else
			CHECK;
		if (good_overall.width != overall.width) {
			report("Font %s: width was %d, expecting %d",
				fontinfo[i].name, overall.width, good_overall.width);
			FAIL;
		} else
			CHECK;
	}
	CHECKPASS(8*nfontinfo);
>>ASSERTION Good A
>># Improved the wording a bit from that approved ....
>># When the font with font_ID
>># .A font_ID
When the
.A font_ID
argument
is a valid Font resource,
then a call to xname returns the bounding box of the specified 8-bit
character string,
.A string ,
as rendered in
the font
with font ID
.A font_ID
and returns non-zero.
>>STRATEGY
Make a string consisting of all characters from 0 to 255
For each VSW5 font
  Load font.
  Call XQueryTextExtents.
  Verify by direct calculation from the metrics.
>>CODE
extern	struct	fontinfo	fontinfo[];
extern	int 	nfontinfo;
int 	i;
char	buf[256];
int 	good_direction;
int 	good_font_ascent;
int 	good_font_descent;
XCharStruct	good_overall;
Font	font;

	for (i = 0; i < 256; i++)
		buf[i] = i;
	string = buf;
	nchars  = 256;

	for (i = 0; i < nfontinfo; i++) {
		font = XLoadFont(display, fontinfo[i].name);
		if (isdeleted()) {
			delete("Could not load font '%s'", fontinfo[i].name);
			return;
		}

		font_ID = font;
		XCALL;

		txtextents(fontinfo[i].fontstruct, (unsigned char *)string,
			nchars, &good_direction, &good_font_ascent, &good_font_descent,
			&good_overall);

		/*
		 * Don't check this because not well enough defined.
		 * Just check that it is one of the allowed values.
		 */
		if (direction != FontLeftToRight && direction != FontRightToLeft) {
			report("Font %s - Direction was %d", fontinfo[i].name);
			FAIL;
		} else
			CHECK;

		if (good_font_ascent != font_ascent) {
			report("Font %s: font ascent was %d, expecting %d",
				fontinfo[i].name, font_ascent, good_font_ascent);
			FAIL;
		} else
			CHECK;
		if (good_font_descent != font_descent) {
			report("Font %s: font descent was %d, expecting %d",
				fontinfo[i].name, font_descent, good_font_descent);
			FAIL;
		} else
			CHECK;
		if (good_overall.lbearing != overall.lbearing) {
			report("Font %s: lbearing was %d, expecting %d",
				fontinfo[i].name, overall.lbearing, good_overall.lbearing);
			FAIL;
		} else
			CHECK;
		if (good_overall.rbearing != overall.rbearing) {
			report("Font %s: rbearing was %d, expecting %d",
				fontinfo[i].name, overall.rbearing, good_overall.rbearing);
			FAIL;
		} else
			CHECK;
		if (good_overall.ascent != overall.ascent) {
			report("Font %s: ascent was %d, expecting %d",
				fontinfo[i].name, overall.ascent, good_overall.ascent);
			FAIL;
		} else
			CHECK;
		if (good_overall.descent != overall.descent) {
			report("Font %s: descent was %d, expecting %d",
				fontinfo[i].name, overall.descent, good_overall.descent);
			FAIL;
		} else
			CHECK;
		if (good_overall.width != overall.width) {
			report("Font %s: width was %d, expecting %d",
				fontinfo[i].name, overall.width, good_overall.width);
			FAIL;
		} else
			CHECK;
	}
	CHECKPASS(8*nfontinfo);

>>ASSERTION def
The
.M ascent
field of
.A overall
is set to the maximum of the ascent metrics 
of all characters in the string.
>>ASSERTION def
The
.M descent
field of
.A overall
is set to the maximum of the descent metrics
of all characters in the string.
>>ASSERTION def
The
.M width
field of
.A overall
is set to the sum of the character-width metrics 
of all characters in the string.
>>ASSERTION def
The
.M lbearing
field of
.A overall
is set to the minimum L of all characters in the string, where for each
character L is the left-side-metric plus the sum of the character
widths of all preceding characters in the string.
>>ASSERTION def
The
.M rbearing
field of
.A overall
is set to the maximum R of all characters in the string, where for each
character R is the right-side-bearing metric plus the sum of the
character widths of all preceding characters in the string.
>>ASSERTION def
The font_ascent_return argument is set to the logical ascent of the font,
the font_descent_return argument is set to the logical descent of the font and
the direction_return argument is set to either FontLeftToRight
or FontRightToLeft.
>>ASSERTION def
When the font has no defined default character, then
undefined characters in the string are taken to have all zero metrics.
>>ASSERTION def
Characters with all zero metrics are ignored.
>>ASSERTION def
When the font has no defined default_char, then
the undefined characters in the string are also ignored.
>>ASSERTION Bad A
.ER BadFont bad-fontable
>>STRATEGY
Pass a bad font
Verify BadFont error occurs
Pass a bad gc
Verify BadFont error occurs
>>CODE BadFont

	string = "jfdkjfk";
	nchars = strlen(string);
	font_ID = badfont(display);

	XCALL;
	if (geterr() == BadFont)
		CHECK;
	else {
		report("No BadFont occurred with a bad font");
		FAIL;
	}

	font_ID = XGContextFromGC(badgc(display));	/* XXX */
	XCALL;
	if (geterr() == BadFont)
		CHECK;
	else {
		report("No BadFont occurred with a bad gc");
		FAIL;
	}
	CHECKPASS(2);

>>## This is not possible.
>>#>>ASSERTION Bad A
>>#.ER BadGC 
>># HISTORY kieron Completed	Reformat and tidy to ca pass
