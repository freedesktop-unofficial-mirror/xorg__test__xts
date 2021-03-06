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
>># File: xts5/Xlib11/SelectionNotify.m
>># 
>># Description:
>># 	Tests for SelectionNotify()
>># 
>># Modifications:
>># $Log: slctnntfy.m,v $
>># Revision 1.2  2005-11-03 08:42:31  jmichael
>># clean up all vsw5 paths to use xts5 instead.
>>#
>># Revision 1.1.1.2  2005/04/15 14:05:18  anderson
>># Reimport of the base with the legal name in the copyright fixed.
>>#
>># Revision 8.0  1998/12/23 23:31:23  mar
>># Branch point for Release 5.0.2
>>#
>># Revision 7.0  1998/10/30 22:51:03  mar
>># Branch point for Release 5.0.2b1
>>#
>># Revision 6.0  1998/03/02 05:23:03  tbr
>># Branch point for Release 5.0.1
>>#
>># Revision 5.0  1998/01/26 03:19:36  tbr
>># Branch point for Release 5.0.1b1
>>#
>># Revision 4.0  1995/12/15 09:02:00  tbr
>># Branch point for Release 5.0.0
>>#
>># Revision 3.1  1995/12/15  00:59:08  andy
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
>>TITLE SelectionNotify Xlib11
>>ASSERTION Good A
There are no assertions in sections 8.1-8.4 for xname events.
Assertions will be submitted from section 4 which will cover
xname event assertions.
>>STRATEGY
Put out a message explaining that there are no specific assertions for
xname events in sections 8.1-8.4, and that delivery of xname events will
be covered in section 4.
>>CODE

	report("There are no specific assertions for %s events in sections 8.1-8.4.", TestName);
	report("Delivery of %s events will be covered in section 4.", TestName);
	tet_result(TET_NOTINUSE);

>>#NOTEm >>ASSERTION
>>#NOTEm When a
>>#NOTEm .S ConvertSelection
>>#NOTEm protocol request is generated
>>#NOTEm and there is no owner for the selection,
>>#NOTEm then ARTICLE xname event is generated.
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
>>#NOTEs >>ASSERTION
>>#NOTEs >>#NOTE
>>#NOTEs >>#NOTE These members should correspond the values specified
>>#NOTEs >>#NOTE in the call to XConvertSelection.
>>#NOTEs >>#NOTE
>>#NOTEs When a
>>#NOTEs .S ConvertSelection
>>#NOTEs protocol request is generated
>>#NOTEs and there is no owner for the selection,
>>#NOTEs then
>>#NOTEs .M requestor
>>#NOTEs is set to
>>#NOTEs the window associated with the requestor of the selection.
>>#NOTEs >>ASSERTION
>>#NOTEs When a
>>#NOTEs .S ConvertSelection
>>#NOTEs protocol request is generated
>>#NOTEs and there is no owner for the selection,
>>#NOTEs then
>>#NOTEs .M selection
>>#NOTEs is set to
>>#NOTEs the atom that indicates the selection.
>>#NOTEs >>ASSERTION
>>#NOTEs When a
>>#NOTEs .S ConvertSelection
>>#NOTEs protocol request is generated
>>#NOTEs and there is no owner for the selection,
>>#NOTEs then
>>#NOTEs .M target
>>#NOTEs is set to
>>#NOTEs the atom that indicates the converted type.
>>#NOTEs >>ASSERTION
>>#NOTEs When a
>>#NOTEs .S ConvertSelection
>>#NOTEs protocol request is generated
>>#NOTEs and there is no owner for the selection,
>>#NOTEs then
>>#NOTEs .M property
>>#NOTEs is set to
>>#NOTEs .S None .
>>#NOTEs >>ASSERTION
>>#NOTEs When a
>>#NOTEs .S ConvertSelection
>>#NOTEs protocol request is generated
>>#NOTEs and there is no owner for the selection,
>>#NOTEs then
>>#NOTEs .M time
>>#NOTEs is set to
>>#NOTEs the time the conversion took place and can be a timestamp or
>>#NOTEs .S CurrentTime .
