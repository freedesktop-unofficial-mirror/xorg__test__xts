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
>># File: xts5/Xlib10/XKillClient.m
>># 
>># Description:
>># 	Tests for XKillClient()
>># 
>># Modifications:
>># $Log: kllclnt.m,v $
>># Revision 1.2  2005-11-03 08:42:18  jmichael
>># clean up all vsw5 paths to use xts5 instead.
>>#
>># Revision 1.1.1.2  2005/04/15 14:05:15  anderson
>># Reimport of the base with the legal name in the copyright fixed.
>>#
>># Revision 8.0  1998/12/23 23:30:59  mar
>># Branch point for Release 5.0.2
>>#
>># Revision 7.0  1998/10/30 22:50:20  mar
>># Branch point for Release 5.0.2b1
>>#
>># Revision 6.0  1998/03/02 05:22:43  tbr
>># Branch point for Release 5.0.1
>>#
>># Revision 5.0  1998/01/26 03:19:15  tbr
>># Branch point for Release 5.0.1b1
>>#
>># Revision 4.0  1995/12/15 09:00:39  tbr
>># Branch point for Release 5.0.0
>>#
>># Revision 3.1  1995/12/15  00:56:35  andy
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
>>TITLE XKillClient Xlib10
void

Display	*display = Dsp;
XID 	resource;
>>ASSERTION Good A
A call to xname forces a close-down of the client
that created the specified
.A resource .
>>STRATEGY
Create a client client1.
Create several resources using client1.
Call xname with one of these resources.
Verify that all client1's resources are destroyed and infer that client1 was
destroyed.
>>CODE
Display	*client1;
Window	win;
Pixmap	pix;
Colormap	cm;
unsigned int 	width, height;

/* We must disable resource registration here to prevent attempted
   deallocation of closed connections and deleted resources. */
	regdisable(); 
	client1 = opendisplay();
	if (client1 == 0) {
		delete("Could not open display");
		regenable();
		return;
	}

	win = defwin(client1);
	pix = XCreatePixmap(client1, DRW(display), 2, 3,
		DefaultDepth(client1, DefaultScreen(client1)));
	cm = makecolmap(client1, DefaultVisual(client1, DefaultScreen(client1)), AllocNone);

	regenable();

	XSync(client1, False);
	if (isdeleted())
		return;

	resource = (XID) cm;
	XCALL;

	CATCH_ERROR(Dsp);
	getsize(Dsp, win, &width, &height);
	if (GET_ERROR(Dsp) == BadDrawable)
		CHECK;
	else {
		report("Window was not destroyed");
		FAIL;
	}

	reseterr();
	getsize(Dsp, pix, &width, &height);
	if (GET_ERROR(Dsp) == BadDrawable)
		CHECK;
	else {
		report("Pixmap was not destroyed");
		FAIL;
	}
	RESTORE_ERROR(Dsp);

	CHECKPASS(2);
>>ASSERTION Good A
When the client that created the resource has already terminated in
either
.S RetainPermanent
or
.S RetainTemporary
mode, then all the resources of that client
are destroyed.
>>STRATEGY
Create a connection, client1.
Create resources for client1.
Set close-down mode to RetainPermanent.
Close client1 connection with XCloseDisplay.
Check client1 resources still exist.
Call xname with one of the client1 resources.
Verify that all client1 resources are destroyed.
>>EXTERN

#define	N_RES	4	

>>CODE
Display	*client1;
Window	w[N_RES];
XWindowAttributes	atts;
int 	i;

/* We must disable resource registration here to prevent attempted
   deallocation of closed connections and deleted resources. */
	regdisable(); 

	client1 = opendisplay();
	if (client1 == 0) {
		delete("Could not open display");
		regenable();
		return;
	}

	w[0] = defwin(client1);
	w[1] = defwin(client1);
	w[2] = defwin(client1);
	w[3] = defwin(client1);
	regenable();

	XSetCloseDownMode(client1, RetainPermanent);
	XCloseDisplay(client1);

	CATCH_ERROR(Dsp);
	for (i = 0; i < N_RES; i++) {
		if (XGetWindowAttributes(Dsp, w[i], &atts) == False) {
			delete("RetainPermanent windows were destroyed");
			return;
		}
	}
	RESTORE_ERROR(Dsp);

	resource = w[2];
	XCALL;

	CATCH_ERROR(Dsp);
	for (i = 0; i < N_RES; i++) {
		if (XGetWindowAttributes(Dsp, w[i], &atts) == True) {
			report("RetainPermanent window was not destroyed");
			FAIL;
		} else
			CHECK;
	}
	RESTORE_ERROR(Dsp);

	CHECKPASS(N_RES);

>>ASSERTION Good A
When a
.A resource
of
.S AllTemporary
is specified, then the resources of all clients that have terminated in
.S RetainTemporary
mode are destroyed.
>>STRATEGY
Open connection client1.
Open connextion client2.
Make resources for both clients.
Set close-down mode of RetainTemporary for both.
Close both clients with XCloseDisplay.
Call xname with ID AllTemporary.
Verify that all clients 1 and 2 resources are destroyed.
>>CODE
XWindowAttributes	atts;
Display	*client1;
Display	*client2;
Window	w1;
Window	w2;

/* We must disable resource registration here to prevent attempted
   deallocation of closed connections and deleted resources. */
	regdisable(); 

	if ((client1 = opendisplay()) == NULL) {
		delete("Could not open display");
		regenable();
		return;
	}
	if ((client2 = opendisplay()) == NULL) {
		delete("Could not open display");
		regenable();
		return;
	}

	w1 = defwin(client1);
	w2 = defwin(client2);

	regenable();

	XSetCloseDownMode(client1, RetainTemporary);
	XSetCloseDownMode(client2, RetainTemporary);

	XCloseDisplay(client1);
	XCloseDisplay(client2);

	resource = AllTemporary;
	XCALL;

	CATCH_ERROR(Dsp);
	if (XGetWindowAttributes(Dsp, w1, &atts) == True) {
		report("RetainTemporary window was not destroyed");
		FAIL;
	} else
		CHECK;
	if (XGetWindowAttributes(Dsp, w2, &atts) == True) {
		report("RetainTemporary window was not destroyed");
		FAIL;
	} else
		CHECK;
	RESTORE_ERROR(Dsp);

	CHECKPASS(2);
>>ASSERTION Bad A
When the specified
.A resource
is not valid, then a
.S BadValue
error occurs.
>>STRATEGY
Get bad id using badwin().
Call xname with this value.
Verify that a BadValue error occurs.
>>CODE BadValue

	resource = badwin(Dsp);
	XCALL;

	if (geterr() == BadValue)
		PASS;
