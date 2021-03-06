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
>># File: xts5/Xlib13/XDisplayKeycodes.m
>># 
>># Description:
>># 	Tests for XDisplayKeycodes()
>># 
>># Modifications:
>># $Log: dsplykycds.m,v $
>># Revision 1.2  2005-11-03 08:42:39  jmichael
>># clean up all vsw5 paths to use xts5 instead.
>>#
>># Revision 1.1.1.2  2005/04/15 14:05:19  anderson
>># Reimport of the base with the legal name in the copyright fixed.
>>#
>># Revision 8.0  1998/12/23 23:33:35  mar
>># Branch point for Release 5.0.2
>>#
>># Revision 7.0  1998/10/30 22:55:11  mar
>># Branch point for Release 5.0.2b1
>>#
>># Revision 6.0  1998/03/02 05:24:59  tbr
>># Branch point for Release 5.0.1
>>#
>># Revision 5.0  1998/01/26 03:21:31  tbr
>># Branch point for Release 5.0.1b1
>>#
>># Revision 4.0  1995/12/15 09:08:12  tbr
>># Branch point for Release 5.0.0
>>#
>># Revision 3.1  1995/12/15  01:09:12  andy
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
>>TITLE XDisplayKeycodes Xlib13
void

Display	*display = Dsp;
int 	*min_keycodes_return = &Minkc;
int 	*max_keycodes_return = &Maxkc;
>>EXTERN

static	int 	Minkc;
static	int 	Maxkc;

>>ASSERTION Good A
A call to xname returns the minimum KeyCode value
supported by the specified display to
.A min_keycodes_return
and the maximum KeyCode value supported by the
specified display to
.A max_keycodes_return .
>>STRATEGY
Call xname.
Use min keycode with XGrabKey.
Verify that it gives no error.
Use min keycode minus one with XGrabKey.
Verify that it gives an error.
Use max keycode with XGrabKey.
Verify that it gives no error.
Use max keycode plus one with XGrabKey.
Verify that it gives an error.
>>CODE
Window	win;

	win = defwin(display);

	XCALL;
	trace("Min keycode=%d, max keycode = %d", Minkc, Maxkc);

	/*
	 * Grab key was chosen to test the validity of the keycodes
	 * on the basis that it does no damage to the current setup.
	 */
	CATCH_ERROR(display);
	XGrabKey(display, Minkc, 0, win, False, GrabModeAsync, GrabModeAsync);
	RESTORE_ERROR(display);
	if (GET_ERROR(display) == Success)
		CHECK;
	else {
		report("Minimum keycode value did not appear to be valid");
		report("A %s error occurred using the keycode with XGrabKey",
							errorname(geterr()));
		FAIL;
	}

	CATCH_ERROR(display);
	XGrabKey(display, Minkc-1, 0, win, False, GrabModeAsync, GrabModeAsync);
	RESTORE_ERROR(display);
	if (GET_ERROR(display) != Success) {
		CHECK;
		debug(1, "A %s error occurred using the keycode with XGrabKey",
							errorname(geterr()));
	} else {
		report("Minimum keycode value did not appear to be the lowest valid code");
		report("No error occurred using the keycode with XGrabKey");
		FAIL;
	}

	CATCH_ERROR(display);
	XGrabKey(display, Maxkc, 0, win, False, GrabModeAsync, GrabModeAsync);
	RESTORE_ERROR(display);
	if (GET_ERROR(display) == Success)
		CHECK;
	else {
		report("Maximum keycode value did not appear to be valid");
		report("A %s error occurred using the keycode with XGrabKey",
							errorname(geterr()));
		FAIL;
	}

	if (Maxkc < 255) {
		CATCH_ERROR(display);
		XGrabKey(display, Maxkc+1, 0, win, False, GrabModeAsync, GrabModeAsync);
		RESTORE_ERROR(display);
		if (GET_ERROR(display) != Success) {
			CHECK;
			debug(1, "A %s error occurred using the keycode with XGrabKey",
								errorname(geterr()));
		} else {
			report("Maximum keycode value did not appear to be the highest valid code");
			report("No error occurred using the keycode with XGrabKey");
			FAIL;
		}
	} else 
		CHECK;

	CHECKPASS(4);
>>ASSERTION Good A
A call to xname returns a
minimum KeyCode value greater than or equal to 8.
>>STRATEGY
Call xname.
Verify minimum KeyCode is greater than or equal to 8.
>>CODE

	XCALL;
	if (*min_keycodes_return >= 8)
		CHECK;
	else {
		report("Minimum keycode was not greater than or equal to 8, was %d",
			*min_keycodes_return);
		FAIL;
	}
	CHECKPASS(1);
>>ASSERTION Good A
A call to xname returns a
maximum KeyCode value less than or equal to 255.
>>STRATEGY
Call xname.
Verify maximum KeyCode is less than or equal to 255.
>>CODE

	XCALL;
	if (*max_keycodes_return <= 255)
		CHECK;
	else {
		report("Maximum keycode was not less than or equal to 255, was %d",
			*max_keycodes_return);
		FAIL;
	}
	CHECKPASS(1);
