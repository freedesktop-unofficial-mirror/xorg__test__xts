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
>># File: xts5/Xlib11/VisibilityNotify.m
>># 
>># Description:
>># 	Tests for VisibilityNotify()
>># 
>># Modifications:
>># $Log: vsbltyntfy.m,v $
>># Revision 1.2  2005-11-03 08:42:31  jmichael
>># clean up all vsw5 paths to use xts5 instead.
>>#
>># Revision 1.1.1.2  2005/04/15 14:05:18  anderson
>># Reimport of the base with the legal name in the copyright fixed.
>>#
>># Revision 8.0  1998/12/23 23:31:25  mar
>># Branch point for Release 5.0.2
>>#
>># Revision 7.0  1998/10/30 22:51:06  mar
>># Branch point for Release 5.0.2b1
>>#
>># Revision 6.0  1998/03/02 05:23:05  tbr
>># Branch point for Release 5.0.1
>>#
>># Revision 5.0  1998/01/26 03:19:37  tbr
>># Branch point for Release 5.0.1b1
>>#
>># Revision 4.0  1995/12/15 09:02:05  tbr
>># Branch point for Release 5.0.0
>>#
>># Revision 3.1  1995/12/15  00:59:15  andy
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
>>TITLE VisibilityNotify Xlib11
>>EXTERN
#define	EVENT		VisibilityNotify
#define	MASK		VisibilityChangeMask
>>ASSERTION Good A
The server does not generate xname events on windows
whose class is specified as
.S InputOnly .
>>STRATEGY
Create class InputOnly window.
Select for VisibilityNotify events.
Attempt to generate VisibilityNotify event on this window.
Verify that no events were delivered.
>>CODE
Display	*display = Dsp;
Window	w;
int	count;

/* Create class InputOnly window. */
	w = iponlywin(display);
/* Select for VisibilityNotify events. */
	XSelectInput(display, w, MASK);
/* Attempt to generate VisibilityNotify event on this window. */
	XSync(display, True);
	XMapWindow(display, w);
	XSync(display, False);
/* Verify that no events were delivered. */
	count = XPending(display);
	if (count > 0) {
		report("Received %d events, expected %d", count, 0);
		FAIL;
	}
	else
		CHECK;
	CHECKPASS(1);
>>#NOTEd >>ASSERTION
>>#NOTEd When a window's visibility state changes,
>>#NOTEd then ARTICLE xname event is generated.
>>ASSERTION Good A
>>#NOTE
>>#NOTE Possible hierarchy event types: UnmapNotify, MapNotify, ConfigureNotify,
>>#NOTE GravityNotify, and CirculateNotify.
>>#NOTE
When a xname event is generated by a hierarchy change,
then the xname event is delivered after
any hierarchy event.
>>STRATEGY
Create client.
Build and create window hierarchy.
Create window large enough to be obscure each top-level
window in a \"standard\" window hierarchy.
Select for VisibilityNotify events on all hierarchy windows.
Select for UnmapNotify events on event window.
Generate VisibilityNotify and UnmapNotify events.
Initialize for expected events.
Harvest events from event queue.
Verify that expected events were delivered.
Verify that all VisibilityNotify events are delivered after all
UnmapNotify events.
>>CODE
Display	*display;
Winh	*eventw;
XEvent	event;
Winhg	winhg;
int	status;

#ifdef	OTHERMASK
#undef	OTHERMASK
#endif
#define	OTHERMASK	StructureNotifyMask
#ifdef	OTHEREVENT
#undef	OTHEREVENT
#endif
#define	OTHEREVENT	UnmapNotify

/* Create client. */
	/*
	 * Can not use Dsp because we are selecting on root window.
	 * We could instead de-select on root window prior to returning,
	 * but this is actually easier.
	 */
	display = opendisplay();
	if (display == (Display *) NULL) {
		delete("Could not open display.");
		return;
	}
	else
		CHECK;
/* Build and create window hierarchy. */
	if (winh(display, 2, WINH_MAP)) {
		report("Could not build window hierarchy");
		return;
	}
	else
		CHECK;
/* Create window large enough to obscure each top-level */
/* window in a "standard" window hierarchy. */
	winhg.area.x = 0;
	winhg.area.y = 0;
	winhg.area.width = DisplayWidth(display, DefaultScreen(display));
	winhg.area.height = DisplayHeight(display, DefaultScreen(display));
	winhg.border_width = 0;
	eventw = winh_adopt(display, (Winh *) NULL, 0L, (XSetWindowAttributes *) NULL, &winhg, WINH_NOMASK);
	if (eventw == (Winh *) NULL) {
		report("Could not create event window");
		return;
	}
	else
		CHECK;
	if (winh_create(display, eventw, WINH_MAP))
		return;
	else
		CHECK;
/* Select for VisibilityNotify events on all hierarchy windows. */
	if (winh_selectinput(display, (Winh *)NULL, MASK))
		return;
	else
		CHECK;
/* Select for UnmapNotify events on event window. */
	if (winh_selectinput(display, eventw, OTHERMASK))
		return;
	else
		CHECK;
/* Select for no events on root windows. */
	if (winh_selectinput(display, guardian, NoEventMask))
		return;
	else
		CHECK;
	if (guardian->nextsibling &&
	    winh_selectinput(display, guardian->nextsibling, NoEventMask))
		return;
	else
		CHECK;
/* Generate VisibilityNotify and UnmapNotify events. */
	XSync(display, True);
	XUnmapWindow(display, eventw->window);
	XSync(display, False);
/* Initialize for expected events. */
	event.xany.type = OTHEREVENT;
	event.xany.window = eventw->window;
	if (winh_plant(eventw, &event, OTHERMASK, WINH_NOMASK))
		return;
	else
		CHECK;
	event.xany.type = EVENT;
	event.xany.window = WINH_BAD;
	if (winh_plant((Winh *)NULL, &event, MASK, WINH_NOMASK))
		return;
	else
		CHECK;
/* Harvest events from event queue. */
	if (winh_harvest(display, (Winh *) NULL)) {
		report("Could not harvest events");
		return;
	}
	else
		CHECK;
/* Verify that expected events were delivered. */
	status = winh_weed((Winh *) NULL, -1, WINH_WEED_IDENTITY);
	if (status < 0)
		return;
	else if (status > 0) {
		report("Event delivery was not as expected");
		FAIL;
	}
	else
		CHECK;
/* Verify that all VisibilityNotify events are delivered after all */
/* UnmapNotify events. */
	status = winh_ordercheck(OTHEREVENT, EVENT);
	if (status == -1)
		return;
	else if (status)
		FAIL;
	else
		CHECK;

	CHECKPASS(13);
>>ASSERTION Good A
When a xname event is generated,
then the xname event is delivered before any
.S Expose
events on that window.
>>STRATEGY
Create client.
Build and create window hierarchy.
Select for VisibilityNotify and Expose events on all windows.
Generate VisibilityNotify and Expose events.
Initialize for expected events.
Harvest events from event queue.
Ignore Expose events.
Verify that expected events were delivered.
Verify that VisibilityNotify events are delivered before
Expose events.
>>CODE
Display	*display;
Winh	*eventw;
XEvent	event;
int	status;
Winhe	*winhe, *winhe2;

#ifdef	OTHERMASK
#undef	OTHERMASK
#endif
#define	OTHERMASK	ExposureMask
#ifdef	OTHEREVENT
#undef	OTHEREVENT
#endif
#define	OTHEREVENT	Expose

/* Create client. */
	/*
	 * Can not use Dsp because we are selecting on root window.
	 * We could instead de-select on root window prior to returning,
	 * but this is actually easier.
	 */
	display = opendisplay();
	if (display == (Display *) NULL) {
		delete("Could not open display.");
		return;
	}
	else
		CHECK;
/* Build and create window hierarchy. */
	if (winh(display, 2, WINH_MAP)) {
		report("Could not build window hierarchy");
		return;
	}
	else
		CHECK;
/* Select for VisibilityNotify and Expose events on all windows. */
	if (winh_selectinput(display, (Winh *)NULL, MASK|OTHERMASK))
		return;
	else
		CHECK;
/* Select for no events on root windows. */
	if (winh_selectinput(display, guardian, NoEventMask))
		return;
	else
		CHECK;
	if (guardian->nextsibling &&
	    winh_selectinput(display, guardian->nextsibling, NoEventMask))
		return;
	else
		CHECK;
/* Generate VisibilityNotify and Expose events. */
	for (eventw = guardian->firstchild; eventw; eventw = eventw->nextsibling)
		XUnmapWindow(display, eventw->window);
	XSync(display, True);
	for (eventw = guardian->firstchild; eventw; eventw = eventw->nextsibling)
		XMapWindow(display, eventw->window);
	XSync(display, False);
/* Initialize for expected events. */
	event.xany.type = EVENT;
	event.xany.window = WINH_BAD;
	if (winh_plant((Winh *)NULL, &event, MASK, WINH_NOMASK))
		return;
	else
		CHECK;
/* Harvest events from event queue. */
	if (winh_harvest(display, (Winh *) NULL)) {
		report("Could not harvest events");
		return;
	}
	else
		CHECK;
/* Ignore Expose events. */
	if (winh_ignore_event((Winh *) NULL, OTHEREVENT, WINH_NOMASK)) {
		report("Could not mark %s events to be ignored",
			eventname(OTHEREVENT));
		return;
	}
	else
		CHECK;
/* Verify that expected events were delivered. */
	status = winh_weed((Winh *) NULL, -1, WINH_WEED_IDENTITY);
	if (status < 0)
		return;
	else if (status > 0) {
		report("Event delivery was not as expected");
		FAIL;
	}
	else
		CHECK;
/* Verify that VisibilityNotify events are delivered before */
/* Expose events. */
	status = 0;
	for (winhe = winh_qdel; winhe; winhe = winhe->next) {
		if (winhe->event->type == VisibilityNotify) {
			for (winhe2 = winh_qdel; winhe2 != winhe; winhe2 = winhe2->next) {
				if (winhe2->event->type == Expose &&
				    winhe2->event->xexpose.window ==
				    winhe->event->xvisibility.window) {
					report("Expose event delivered before Visibility event on window 0x%x", winhe->event->xvisibility.window);
					FAIL;
				}
			}
			if (!status) {
				CHECK;
				status = 1;
			}
			for (winhe2 = winhe->next; winhe2; winhe2 = winhe2->next) {
				if (winhe2->event->type == Expose &&
				    winhe2->event->xexpose.window ==
				    winhe->event->xvisibility.window)
					break;
			}
			if (!winhe2) {
				report("Expose event not delivered on window 0x%x", winhe->event->xvisibility.window);
				FAIL;
			}
		}
	}
	CHECKPASS(10);
>>ASSERTION Good A
When a xname event is generated,
then
all clients having set
.S VisibilityChangeMask
event mask bits on the event window are delivered
a xname event.
>>STRATEGY
Create clients client2 and client3.
Create window.
Select for VisibilityNotify events using VisibilityChangeMask.
Select for VisibilityNotify events using VisibilityChangeMask with client2.
Select for no events with client3.
Generate VisibilityNotify event.
Verify that a VisibilityNotify event was delivered.
Verify that event member fields are correctly set.
Verify that a VisibilityNotify event was delivered to client2.
Verify that event member fields are correctly set.
Verify that no events were delivered to client3.
>>CODE
Display	*display = Dsp;
Display	*client2;
Display	*client3;
Window	w;
int	count;
XEvent	event_return;
XVisibilityEvent good;

/* Create clients client2 and client3. */
	if ((client2 = opendisplay()) == (Display *) NULL) {
		delete("Couldn't create client2.");
		return;
	}
	else
		CHECK;
	if ((client3 = opendisplay()) == (Display *) NULL) {
		delete("Couldn't create client3.");
		return;
	}
	else
		CHECK;
/* Create window. */
	w = mkwin(display, (XVisualInfo *) NULL, (struct area *) NULL, False);
/* Select for VisibilityNotify events using VisibilityChangeMask. */
	XSelectInput(display, w, MASK);
/* Select for VisibilityNotify events using VisibilityChangeMask with client2. */
	XSelectInput(client2, w, MASK);
/* Select for no events with client3. */
	XSelectInput(client3, w, NoEventMask);
/* Generate VisibilityNotify event. */
	XSync(display, True);
	XSync(client2, True);
	XSync(client3, True);
	XMapWindow(display, w);
	XSync(display, False);
	XSync(client2, False);
	XSync(client3, False);
/* Verify that a VisibilityNotify event was delivered. */
	if (!XCheckTypedWindowEvent(display, w, EVENT, &event_return)) {
		report("Expected %s event, got none", eventname(EVENT));
		FAIL;
	}
	else
		CHECK;
/* Verify that event member fields are correctly set. */
	good = event_return.xvisibility;
	good.type = EVENT;
	good.window = w;
	good.state = VisibilityUnobscured;
	if (checkevent((XEvent *) &good, &event_return)) {
		report("Unexpected values in delivered event");
		FAIL;
	}
	else
		CHECK;
/* Verify that a VisibilityNotify event was delivered to client2. */
	if (!XCheckTypedWindowEvent(client2, w, EVENT, &event_return)) {
		report("Expected %s event, got none", eventname(EVENT));
		FAIL;
	}
	else
		CHECK;
/* Verify that event member fields are correctly set. */
	good = event_return.xvisibility;
	good.type = EVENT;
	good.window = w;
	good.state = VisibilityUnobscured;
	if (checkevent((XEvent *) &good, &event_return)) {
		report("Unexpected values in delivered event for client2");
		FAIL;
	}
	else
		CHECK;
/* Verify that no events were delivered to client3. */
	count = XPending(client3);
	if (count != 0) {
		report("Got %d events, expected %d for client3", count, 0);
		FAIL;
		return;
	}
	else
		CHECK;
	
	CHECKPASS(7);
>>ASSERTION def
>>#NOTE	Tested for in previous assertion.
When a xname event is generated,
then
clients not having set
.S VisibilityChangeMask
event mask bits on the event window are not delivered
a xname event.
>>#NOTEs >>ASSERTION
>>#NOTEs When ARTICLE xname event is delivered,
>>#NOTEs then
>>#NOTEs .M type
>>#NOTEs is set to
>>#NOTEs xname.
>>#NOTEs >>ASSERTION
>>#NOTEs >>#NOTE The method of expansion is not clear.
>>#NOTEs When ARTICLE xname event is delivered,
>>#NOTEs then
>>#NOTEs .M serial
>>#NOTEs is set
>>#NOTEs from the serial number reported in the protocol
>>#NOTEs but expanded from the 16-bit least-significant bits
>>#NOTEs to a full 32-bit value.
>>#NOTEm >>ASSERTION
>>#NOTEm When ARTICLE xname event is delivered
>>#NOTEm and the event came from a
>>#NOTEm .S SendEvent
>>#NOTEm protocol request,
>>#NOTEm then
>>#NOTEm .M send_event
>>#NOTEm is set to
>>#NOTEm .S True .
>>#NOTEs >>ASSERTION
>>#NOTEs When ARTICLE xname event is delivered
>>#NOTEs and the event was not generated by a
>>#NOTEs .S SendEvent
>>#NOTEs protocol request,
>>#NOTEs then
>>#NOTEs .M send_event
>>#NOTEs is set to
>>#NOTEs .S False .
>>#NOTEs >>ASSERTION
>>#NOTEs When ARTICLE xname event is delivered,
>>#NOTEs then
>>#NOTEs .M display
>>#NOTEs is set to
>>#NOTEs a pointer to the display on which the event was read.
>>ASSERTION def
>>#NOTE	Tested for in previous assertions.
When a xname event is delivered,
then
.M window
is set to the window
whose visibility state changes.
>>ASSERTION Good A
When a xname event is delivered
and
.M window
changes state from
partially obscured,
fully obscured,
or not viewable to viewable and completely unobscured,
then
.M state
is set to
.S VisibilityUnobscured .
>>STRATEGY
Create window.
Select for VisibilityNotify events on window.
Generate VisibilityNotify event.
Verify that a VisibilityNotify event was delivered.
Verify that event member fields are correctly set.
Verify that no other events were delivered.
Fully obscure window.
Generate VisibilityNotify event.
Verify that a VisibilityNotify event was delivered.
Verify that event member fields are correctly set.
Verify that no other events were delivered.
Partially obscure window.
Generate VisibilityNotify event.
Verify that a VisibilityNotify event was delivered.
Verify that event member fields are correctly set.
Verify that no other events were delivered.
>>CODE
Display	*display = Dsp;
Window	w, w2;
struct area	area;
XEvent	event_return;
XVisibilityEvent	good;
int	count;

	/*
	 * test ordering:
	 *
	 *	not viewable		-> viewable and completely unobscured
	 *	fully obscured		-> viewable and completely unobscured
	 *	partially obscured	-> viewable and completely unobscured
	 */
/* Create window. */
	area.x = 1;
	area.y = 1;
	area.width = W_STDWIDTH;
	area.height = W_STDHEIGHT;
	w = mkwin(display, (XVisualInfo *) NULL, &area, False);
/* Select for VisibilityNotify events on window. */
	XSelectInput(display, w, MASK);
/* Generate VisibilityNotify event. */
	XSync(display, True);
	XMapWindow(display, w);
	XSync(display, False);
/* Verify that a VisibilityNotify event was delivered. */
	if (!XCheckTypedWindowEvent(display, w, EVENT, &event_return)) {
		report("Expected %s event, got none (not viewable test)", eventname(EVENT));
		FAIL;
	}
	else
		CHECK;
/* Verify that event member fields are correctly set. */
	good = event_return.xvisibility;
	good.type = EVENT;
	good.send_event = False;
	good.display = display;
	good.window = w;
	good.state = VisibilityUnobscured;
	if (checkevent((XEvent *) &good, &event_return)) {
		report("Unexpected values in delivered event (not viewable test)");
		FAIL;
	}
	else
		CHECK;
/* Verify that no other events were delivered. */
	count = XPending(display);
	if (count > 0) {
		report("Received %d events, expected %d (not viewable test)", count+1, 1);
		FAIL;
	}
	else
		CHECK;
/* Fully obscure window. */
	w2 = mkwin(display, (XVisualInfo *) NULL, &area, True);
/* Generate VisibilityNotify event. */
	XSync(display, True);
	XUnmapWindow(display, w2);
	XSync(display, False);
/* Verify that a VisibilityNotify event was delivered. */
	if (!XCheckTypedWindowEvent(display, w, EVENT, &event_return)) {
		report("Expected %s event, got none (fully obscured test)", eventname(EVENT));
		FAIL;
	}
	else
		CHECK;
/* Verify that event member fields are correctly set. */
	good = event_return.xvisibility;
	good.type = EVENT;
	good.send_event = False;
	good.display = display;
	good.window = w;
	good.state = VisibilityUnobscured;
	if (checkevent((XEvent *) &good, &event_return)) {
		report("Unexpected values in delivered event (fully obscured test)");
		FAIL;
	}
	else
		CHECK;
/* Verify that no other events were delivered. */
	count = XPending(display);
	if (count > 0) {
		report("Received %d events, expected %d (fully obscured test)", count+1, 1);
		FAIL;
	}
	else
		CHECK;
/* Partially obscure window. */
	area.x = 1;
	area.y = 1;
	area.width = W_STDWIDTH/2;
	area.height = W_STDHEIGHT/2;
	w2 = mkwin(display, (XVisualInfo *) NULL, &area, True);
/* Generate VisibilityNotify event. */
	XSync(display, True);
	XUnmapWindow(display, w2);
	XSync(display, False);
/* Verify that a VisibilityNotify event was delivered. */
	if (!XCheckTypedWindowEvent(display, w, EVENT, &event_return)) {
		report("Expected %s event, got none (partially obscured test)", eventname(EVENT));
		FAIL;
	}
	else
		CHECK;
/* Verify that event member fields are correctly set. */
	good = event_return.xvisibility;
	good.type = EVENT;
	good.send_event = False;
	good.display = display;
	good.window = w;
	good.state = VisibilityUnobscured;
	if (checkevent((XEvent *) &good, &event_return)) {
		report("Unexpected values in delivered event (partially obscured test)");
		FAIL;
	}
	else
		CHECK;
/* Verify that no other events were delivered. */
	count = XPending(display);
	if (count > 0) {
		report("Received %d events, expected %d (partially obscured test)", count+1, 1);
		FAIL;
	}
	else
		CHECK;
	
	CHECKPASS(9);
>>ASSERTION Good A
When a xname event is delivered
and
.M window
changes state from
viewable and completely unobscured or
not viewable to viewable and partially obscured,
then
.M state
is set to
.S VisibilityPartiallyObscured .
>>STRATEGY
Create window.
Create partially obscuring window.
Select for VisibilityNotify events on window.
Generate VisibilityNotify event.
Verify that a VisibilityNotify event was delivered.
Verify that event member fields are correctly set.
Verify that no other events were delivered.
Unobscure window.
Generate VisibilityNotify event.
Verify that a VisibilityNotify event was delivered.
Verify that event member fields are correctly set.
Verify that no other events were delivered.
>>CODE
Display	*display = Dsp;
Window	w, wpo;
struct area	area;
XEvent	event_return;
XVisibilityEvent	good;
int	count;

	/*
	 * test ordering:
	 *
	 *	not viewable
	 *		-> viewable and partially obscured
	 *	viewable & completely unobscured
	 *		-> viewable & partially unobscured
	 */
/* Create window. */
	area.x = 1;
	area.y = 1;
	area.width = W_STDWIDTH;
	area.height = W_STDHEIGHT;
	w = mkwin(display, (XVisualInfo *) NULL, &area, False);
/* Create partially obscuring window. */
	area.x += W_STDWIDTH/2;
	area.y += W_STDHEIGHT/2;
	wpo = mkwin(display, (XVisualInfo *) NULL, &area, True);
/* Select for VisibilityNotify events on window. */
	XSelectInput(display, w, MASK);
/* Generate VisibilityNotify event. */
	XSync(display, True);
	XMapWindow(display, w);
	XSync(display, False);
/* Verify that a VisibilityNotify event was delivered. */
	if (!XCheckTypedWindowEvent(display, w, EVENT, &event_return)) {
		report("Expected %s event, got none (not viewable test)", eventname(EVENT));
		FAIL;
	}
	else
		CHECK;
/* Verify that event member fields are correctly set. */
	good = event_return.xvisibility;
	good.type = EVENT;
	good.send_event = False;
	good.display = display;
	good.window = w;
	good.state = VisibilityPartiallyObscured;
	if (checkevent((XEvent *) &good, &event_return)) {
		report("Unexpected values in delivered event (not viewable test)");
		FAIL;
	}
	else
		CHECK;
/* Verify that no other events were delivered. */
	count = XPending(display);
	if (count > 0) {
		report("Received %d events, expected %d (not viewable test)", count+1, 1);
		FAIL;
	}
	else
		CHECK;
/* Unobscure window. */
	XUnmapWindow(display, wpo);
/* Generate VisibilityNotify event. */
	XSync(display, True);
	XMapWindow(display, wpo);
	XSync(display, False);
/* Verify that a VisibilityNotify event was delivered. */
	if (!XCheckTypedWindowEvent(display, w, EVENT, &event_return)) {
		report("Expected %s event, got none (viewable & completely unobscured test)", eventname(EVENT));
		FAIL;
	}
	else
		CHECK;
/* Verify that event member fields are correctly set. */
	good = event_return.xvisibility;
	good.type = EVENT;
	good.send_event = False;
	good.display = display;
	good.window = w;
	good.state = VisibilityPartiallyObscured;
	if (checkevent((XEvent *) &good, &event_return)) {
		report("Unexpected values in delivered event (viewable & completely unobscured test)");
		FAIL;
	}
	else
		CHECK;
/* Verify that no other events were delivered. */
	count = XPending(display);
	if (count > 0) {
		report("Received %d events, expected %d (viewable & completely unobscured test)", count+1, 1);
		FAIL;
	}
	else
		CHECK;
	
	CHECKPASS(6);
>>ASSERTION Good A
When a xname event is delivered
and
.M window
changes state from
viewable and completely unobscured,
viewable and partially obscured,
or not viewable to viewable and fully obscured,
then
.M state
is set to
.S VisibilityFullyObscured .
>>STRATEGY
Create window.
Create completely obscuring window.
Create partially obscuring window.
Select for VisibilityNotify events on window.
Generate VisibilityNotify event.
Verify that a VisibilityNotify event was delivered.
Verify that event member fields are correctly set.
Verify that no other events were delivered.
Unobscure window.
Generate VisibilityNotify event.
Verify that a VisibilityNotify event was delivered.
Verify that event member fields are correctly set.
Verify that no other events were delivered.
Partially obscure window.
Generate VisibilityNotify event.
Verify that a VisibilityNotify event was delivered.
Verify that event member fields are correctly set.
Verify that no other events were delivered.
>>CODE
Display	*display = Dsp;
Window	w, wfo, wpo;
struct area	area;
XEvent	event_return;
XVisibilityEvent	good;
int	count;

	/*
	 * test ordering:
	 *
	 *	not viewable ->
	 *		-> viewable and fully obscured
	 *	viewable and completely unobscured
	 *		-> viewable and fully obscured
	 *	viewable and partially obscured
	 *		-> viewable and fully obscured
	 */
/* Create window. */
	area.x = 1;
	area.y = 1;
	area.width = W_STDWIDTH;
	area.height = W_STDHEIGHT;
	w = mkwin(display, (XVisualInfo *) NULL, &area, False);
/* Create completely obscuring window. */
	wfo = mkwin(display, (XVisualInfo *) NULL, &area, True);
/* Create partially obscuring window. */
	area.x += W_STDWIDTH/2;
	area.y += W_STDHEIGHT/2;
	wpo = mkwin(display, (XVisualInfo *) NULL, &area, False);
/* Select for VisibilityNotify events on window. */
	XSelectInput(display, w, MASK);
/* Generate VisibilityNotify event. */
	XSync(display, True);
	XMapWindow(display, w);
	XSync(display, False);
/* Verify that a VisibilityNotify event was delivered. */
	if (!XCheckTypedWindowEvent(display, w, EVENT, &event_return)) {
		report("Expected %s event, got none (not viewable test)", eventname(EVENT));
		FAIL;
	}
	else
		CHECK;
/* Verify that event member fields are correctly set. */
	good = event_return.xvisibility;
	good.type = EVENT;
	good.send_event = False;
	good.display = display;
	good.window = w;
	good.state = VisibilityFullyObscured;
	if (checkevent((XEvent *) &good, &event_return)) {
		report("Unexpected values in delivered event (not viewable test)");
		FAIL;
	}
	else
		CHECK;
/* Verify that no other events were delivered. */
	count = XPending(display);
	if (count > 0) {
		report("Received %d events, expected %d (not viewable test)", count+1, 1);
		FAIL;
	}
	else
		CHECK;
/* Unobscure window. */
	XUnmapWindow(display, wfo);
/* Generate VisibilityNotify event. */
	XSync(display, True);
	XMapWindow(display, wfo);
	XSync(display, False);
/* Verify that a VisibilityNotify event was delivered. */
	if (!XCheckTypedWindowEvent(display, w, EVENT, &event_return)) {
		report("Expected %s event, got none (viewable and completely unobscured test)", eventname(EVENT));
		FAIL;
	}
	else
		CHECK;
/* Verify that event member fields are correctly set. */
	good = event_return.xvisibility;
	good.type = EVENT;
	good.send_event = False;
	good.display = display;
	good.window = w;
	good.state = VisibilityFullyObscured;
	if (checkevent((XEvent *) &good, &event_return)) {
		report("Unexpected values in delivered event (viewable and completely unobscured test)");
		FAIL;
	}
	else
		CHECK;
/* Verify that no other events were delivered. */
	count = XPending(display);
	if (count > 0) {
		report("Received %d events, expected %d (viewable and completely unobscured test)", count+1, 1);
		FAIL;
	}
	else
		CHECK;
/* Partially obscure window. */
	XUnmapWindow(display, wfo);
	XMapWindow(display, wpo);
/* Generate VisibilityNotify event. */
	XSync(display, True);
	XMapWindow(display, wfo);
	XSync(display, False);
/* Verify that a VisibilityNotify event was delivered. */
	if (!XCheckTypedWindowEvent(display, w, EVENT, &event_return)) {
		report("Expected %s event, got none (viewable and partially obscured test)", eventname(EVENT));
		FAIL;
	}
	else
		CHECK;
/* Verify that event member fields are correctly set. */
	good = event_return.xvisibility;
	good.type = EVENT;
	good.send_event = False;
	good.display = display;
	good.window = w;
	good.state = VisibilityFullyObscured;
	if (checkevent((XEvent *) &good, &event_return)) {
		report("Unexpected values in delivered event (viewable and partially obscured test)");
		FAIL;
	}
	else
		CHECK;
/* Verify that no other events were delivered. */
	count = XPending(display);
	if (count > 0) {
		report("Received %d events, expected %d (viewable and partially obscured test)", count+1, 1);
		FAIL;
	}
	else
		CHECK;
	
	CHECKPASS(9);
