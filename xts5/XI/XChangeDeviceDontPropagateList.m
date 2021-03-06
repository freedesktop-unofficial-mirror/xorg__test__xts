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
>># File: xts5/XI/chngdvcdnt/chngdvcdnt.m
>># 
>># Description:
>># 	Tests for XChangeDeviceDontPropagateList()
>># 
>># Modifications:
>># $Log: chgprop.m,v $
>># Revision 1.2  2005-11-03 08:42:04  jmichael
>># clean up all vsw5 paths to use xts5 instead.
>>#
>># Revision 1.1.1.2  2005/04/15 14:05:13  anderson
>># Reimport of the base with the legal name in the copyright fixed.
>>#
>># Revision 8.0  1998/12/23 23:31:53  mar
>># Branch point for Release 5.0.2
>>#
>># Revision 7.0  1998/10/30 22:51:59  mar
>># Branch point for Release 5.0.2b1
>>#
>># Revision 6.0  1998/03/02 05:23:29  tbr
>># Branch point for Release 5.0.1
>>#
>># Revision 5.0  1998/01/26 03:20:01  tbr
>># Branch point for Release 5.0.1b1
>>#
>># Revision 4.0  1995/12/15 09:03:25  tbr
>># Branch point for Release 5.0.0
>>#
>># Revision 3.1  1995/12/15  01:01:15  andy
>># Prepare for GA Release
>>#
/*
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

Copyright 1993 by the Hewlett-Packard Company.

Copyright 1990, 1991 UniSoft Group Limited.

Permission to use, copy, modify, distribute, and sell this software and
its documentation for any purpose is hereby granted without fee,
provided that the above copyright notice appear in all copies and that
both that copyright notice and this permission notice appear in
supporting documentation, and that the names of HP, and UniSoft not be
used in advertising or publicity pertaining to distribution of the
software without specific, written prior permission.  HP, and UniSoft
make no representations about the suitability of this software for any
purpose.  It is provided "as is" without express or implied warranty.
*/
>>TITLE XChangeDeviceDontPropagateList XI
int

Display	*display = Dsp;
Window	win;
int	count;
XEventClass *events;
int	mode;
>>EXTERN

extern XEventClass classes[];

>>ASSERTION Good B 3
A successful call to xname can add to the DontPropagateList for the specified
window.
>>STRATEGY
Call xname to add to the list of events whose propagation is suppressed.
>>CODE
int 	ret;

	if (!Setup_Extension_DeviceInfo(KeyMask))
	    {
	    untested("%s: No input extension devices.\n", TestName);
	    return;
	    }

	win = defwin(display);
	SelectExtensionEvents(display,win);
	mode = AddToList;
	events = classes;
	count = 2;
	ret = XCALL;
	if (geterr() == Success)
		CHECK;
	else
		FAIL;
	CHECKPASS(1);
>>ASSERTION Good B 3
A successful call to xname can delete from the DontPropagateList for the 
specified window.
>>STRATEGY
Call xname to delete from the list of events whose propagation is suppressed.
Call when the list has elements to be deleted, as well as when the list is
empty.
>>CODE
int 	ret;

	if (!Setup_Extension_DeviceInfo(KeyMask))
	    {
	    untested("%s: No input extension devices.\n", TestName);
	    return;
	    }
	win = defwin(display);
	mode = DeleteFromList;
	events = classes;
	count = 2;
	ret = XCALL;
	if (geterr() == Success)
		CHECK;
	else
		FAIL;
	CHECKPASS(1);

	SelectExtensionEvents(display,win);
	mode = AddToList;
	ret = XCALL;
	if (geterr() == Success)
		CHECK;
	else
		FAIL;
	CHECKPASS(2);

	mode = DeleteFromList;
	ret = XCALL;
	if (geterr() == Success)
		CHECK;
	else
		FAIL;
	CHECKPASS(3);

>>ASSERTION Good B 3
A successful call to xname changes the propagate mask for all clients.
>>STRATEGY
Get the original propagate list.
Call xname to add to the list of events whose propagation is suppressed.
Verify the list is changed.
Get the propagate list for another client.
Verify it is the same.
>>CODE
int 	ret, count;
XEventClass *list;
Display	*client1, *save;

	if (!Setup_Extension_DeviceInfo(KeyMask))
	    {
	    untested("%s: No input extension devices.\n", TestName);
	    return;
	    }
/* Create client1. */
	if ((client1 = opendisplay()) == NULL)
		return;

	win = defwin(display);
	list = XGetDeviceDontPropagateList (display, win, &count);
	if (count !=0 || list != NULL)
	    {
	    report("%s: Count was %d (should be 0), list was %x (should be NULL)",TestName,count,list);
	    FAIL;
	    }
	else 
	    CHECK;
	mode = AddToList;
	events = classes;
	count = 2;
	save = display;
	display = client1;
	ret = XCALL;
	if (geterr() == Success)
		CHECK;
	else
		FAIL;

	list = XGetDeviceDontPropagateList (save, win, &count);
	if (count !=2 || list == NULL)
	    {
	    report("%s: Count was %d (should be 2), list was NULL (shouldn't be)",TestName,count,list);
	    FAIL;
	    }
	else if ((*list != classes[0] && *list != classes[1]) ||
	    (*(list+1) != classes[0] && *(list+1)!= classes[1]))
	    {
	    report("%s: returned list (%x %x) didn't match sent (%x %x)",TestName,*list,*(list+1),classes[0],classes[1]);
	    FAIL;
	    }
	else
	    CHECK;

	CHECKPASS(3);

>>ASSERTION Good B 3
The termination of the client that changed the propagate list for
a window does not affect that list.
>>STRATEGY
Get the original propagate list.
Call xname to add to the list of events whose propagation is suppressed.
Terminate the client and see if the propagate list has changed.
>>CODE
int 	ret, count;
XEventClass *list;
Display	*client1, *save;

	if (!Setup_Extension_DeviceInfo(KeyMask))
	    {
	    untested("%s: No input extension devices.\n", TestName);
	    return;
	    }
/* Create client1. */
	if ((client1 = opendisplay()) == NULL)
		return;

	win = defwin(display);
	list = XGetDeviceDontPropagateList (display, win, &count);
	if (count !=0 || list != NULL)
	    {
	    report("%s: Count was %d (should be 0), list was %x (should be NULL)",TestName,count,list);
	    FAIL;
	    }
	else
	    CHECK;
	mode = AddToList;
	events = classes;
	count = 2;
	save = display;
	display = client1;
	ret = XCALL;
	XSync(display,0);
	if (geterr() == Success)
		CHECK;
	else
		FAIL;
	list = XGetDeviceDontPropagateList (save, win, &count);
	if (count !=2 || list == NULL)
	    {
	    report("%s: Count was %d (should be 2), list was NULL (shouldn't be)",TestName,count,list);
	    FAIL;
	    }
	else if ((*list != classes[0] && *list != classes[1]) ||
	    (*(list+1) != classes[0] && *(list+1)!= classes[1]))
	    {
	    report("%s: returned list (%x %x) didn't match sent (%x %x)",TestName,*list,*(list+1),classes[0],classes[1]);
	    FAIL;
	    }
	else
	    CHECK;

	display = save;
	CHECKPASS(3);

>>ASSERTION Bad B 3
A call to xname with an invalid window id will cause the server to return
a BadWindow error.
>>STRATEGY
Call xname with an invalid window id.  Verify that a BadWindow error is 
generated.
>>CODE BadWindow
int 	ret;

	if (!Setup_Extension_DeviceInfo(KeyMask))
	    {
	    untested("%s: No input extension devices.\n", TestName);
	    return;
	    }
	win = 0;
	mode = AddToList;
	events = classes;
	count = 2;
	ret = XCALL;
	if (geterr() != BadWindow)
		FAIL;
	else
		CHECK;
	CHECKPASS(1);

>>ASSERTION Bad B 3
A call to xname with an invalid mode will cause the server to return
a BadMode error.
>>STRATEGY
Call xname with an invalid window id.  Verify that a BadWindow error is 
generated.
>>CODE badmode
int 	ret, badmode;

	if (!Setup_Extension_DeviceInfo(KeyMask))
	    {
	    untested("%s: No input extension devices.\n", TestName);
	    return;
	    }

	BadMode (display, badmode);
	mode = -1;
	win = defwin(display);
	events = classes;
	count = 2;
	ret = XCALL;
	if (geterr() != badmode)
		FAIL;
	else
		CHECK;
	CHECKPASS(1);

>>ASSERTION Bad B 3
A call to xname with an invalid event class will cause the server to return
a BadClass error.
>>STRATEGY
Call xname with an invalid event class.  Verify that a BadClass error is 
generated.
>>CODE badclass
int 	ret, badclass;
XEventClass badclasses[2];

	if (!Setup_Extension_DeviceInfo(KeyMask))
	    {
	    untested("%s: No input extension devices.\n", TestName);
	    return;
	    }
	BadClass (display, badclass);
	badclasses[0] = -1;
	badclasses[1] = -1;
	mode = AddToList;
	win = defwin(display);
	events = badclasses;
	count = 2;
	ret = XCALL;
	XSync(display,0);
	if (geterr() != badclass)
		FAIL;
	else
		CHECK;

	mode = DeleteFromList;
	ret = XCALL;
	if (geterr() != badclass)
		FAIL;
	else
		CHECK;

	CHECKPASS(2);

