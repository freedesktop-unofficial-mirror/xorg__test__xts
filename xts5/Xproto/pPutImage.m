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

Copyright (c) 1999 The Open Group
Copyright (c) Applied Testing and Technology, Inc. 1995
All Rights Reserved.

>># Project: VSW5
>># 
>># File: xts5/Xproto/pPutImage.m
>># 
>># Description:
>># 	Tests for PutImage
>># 
>># Modifications:
>># $Log: ptimg.m,v $
>># Revision 1.3  2005-11-03 08:44:16  jmichael
>># clean up all vsw5 paths to use xts5 instead.
>>#
>># Revision 1.2  2005/04/21 09:40:42  ajosey
>># resync to VSW5.1.5
>>#
>># Revision 8.2  2005/01/21 12:08:31  gwc
>># Updated copyright notice
>>#
>># Revision 8.1  1999/12/03 11:33:31  vsx
>># TSD4W.00165: in TOO_LONG test don't try to allocate image buffer when Big-Requests are enabled
>>#
>># Revision 8.0  1998/12/23 23:32:57  mar
>># Branch point for Release 5.0.2
>>#
>># Revision 7.0  1998/10/30 22:53:59  mar
>># Branch point for Release 5.0.2b1
>>#
>># Revision 6.0  1998/03/02 05:24:25  tbr
>># Branch point for Release 5.0.1
>>#
>># Revision 5.0  1998/01/26 03:20:57  tbr
>># Branch point for Release 5.0.1b1
>>#
>># Revision 4.0  1995/12/18 02:41:19  tbr
>># Branch point for release 5.0.0.
>>#
>># Revision 3.2  1995/12/18  02:40:30  tbr
>># changed bcopy to wbcopy
>>#
>># Revision 3.1  1995/12/15  01:06:04  andy
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

Copyright 1989 by Sequent Computer Systems, Inc., Portland, Oregon

			All Rights Reserved

Permission to use, copy, modify, and distribute this software and its
documentation for any purpose and without fee is hereby granted,
provided that the above copyright notice appears in all copies and that
both that copyright notice and this permission notice appear in
supporting documentation, and that the name of Sequent not be used
in advertising or publicity pertaining to distribution or use of the
software without specific, written prior permission.

SEQUENT DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING
ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS; IN NO EVENT SHALL
SEQUENT BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR
ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS
SOFTWARE.
*/
>>TITLE PutImage Xproto
>>SET startup protostartup
>>SET cleanup protocleanup
>>EXTERN
/* Touch test for PutImage request */

#include "Xstlib.h"

#define CLIENT 0
static TestType test_type = SETUP;
Window win;
xPolyRectangleReq *prr;
xGetImageReq *req;
xGetImageReply *rep;
xPutImageReq *pir;

static
void
tester()
{
	unsigned char *from;
	unsigned char *to;
	unsigned int len;

	Create_Client(CLIENT);

	win = Create_Default_Window(CLIENT);
	Create_Default_GContext(CLIENT);
	Map_Window(CLIENT, win);

	prr = (xPolyRectangleReq *) Make_Req(CLIENT, X_PolyRectangle);
	Send_Req(CLIENT, (xReq *) prr);
	Log_Trace("client %d sent pixmap PolyRectangle request\n", CLIENT);
	Expect_Nothing(CLIENT);
	Free_Req(req);

	req = (xGetImageReq *) Make_Req(CLIENT, X_GetImage);
	Send_Req(CLIENT, (xReq *) req);
	Log_Trace("client %d sent default GetImage request\n", CLIENT);

	if ((rep = (xGetImageReply *) Expect_Reply(CLIENT, X_GetImage)) == NULL) {
		Log_Del("client %d failed to receive GetImage reply\n", CLIENT);
		Exit();
	}  else  {
		Log_Trace("client %d received GetImage reply\n", CLIENT);
		/* do any reply checking here */
	}
	Expect_Nothing(CLIENT);

	win = Create_Default_Window(CLIENT);
	Map_Window(CLIENT, win);

	Set_Test_Type(CLIENT, test_type);
	pir = (xPutImageReq *) Make_Req(CLIENT, X_PutImage);
	pir->dstX = 0;
	pir->dstY = 0;
	pir->width = req->width;
	pir->height = req->height;
	if (test_type != BAD_LENGTH) {
		switch (test_type) {
		case JUST_TOO_LONG:
			pir->length += 10; /* ensure we're well over
					w*h*depth_and_format_and_pad_stuff/4 */
			/* now fall through */
		default:
			pir->length += rep->length;
			break;
		case TOO_LONG:
			/* Send_Req() won't access any request data, so
			   no need to allocate it */
			pir->length = 0;
			break;
		}
		len = pir->length<<2;
		if (len != 0) {
			pir = (xPutImageReq *) Xstrealloc((char *) pir, len);
			if (pir == NULL) {
				Log_Del ("client %d could not reallocate %d bytes for request buffer\n", CLIENT, len);
				Exit ();
			}
			to = (unsigned char *) (pir+1);
			from = (unsigned char *) (rep+1);
			wbcopy(from, to, rep->length << 2);
		}
	}

	Send_Req(CLIENT, (xReq *) pir);
	Set_Test_Type(CLIENT, GOOD);
	switch(test_type) {
	case GOOD:
		Log_Trace("client %d sent default PutImage request\n", CLIENT);
		Expect_Nothing(CLIENT);
		Visual_Check();
		break;
	case BAD_LENGTH:
		Log_Trace("client %d sent PutImage request with bad length (%d)\n", CLIENT, pir->length);
		Expect_BadLength(CLIENT);
		Expect_Nothing(CLIENT);
		break;
	case TOO_LONG:
	case JUST_TOO_LONG:
		Log_Trace("client %d sent overlong PutImage request (%d)\n", CLIENT, pir->length);
		Expect_BadLength(CLIENT);
		Expect_Nothing(CLIENT);
		break;
	default:
		Log_Err("INTERNAL ERROR: test_type %d not one of GOOD(%d), BAD_LENGTH(%d), TOO_LONG(%d) or JUST_TOO_LONG(%d)\n",
			test_type, GOOD, BAD_LENGTH, TOO_LONG, JUST_TOO_LONG);
		Abort();
		/*NOTREACHED*/
		break;
	}
	Free_Req(req);
	Free_Reply(rep);
	Free_Req(pir);
	Exit_OK();
}
>>ASSERTION Good A
When a client sends a valid xname protocol request to the X server,
then the X server sends back a reply to the client
with the minimum required length.
>>STRATEGY
Call library function testfunc() to do the following:
Open a connection to the X server using native byte sex.
Send a valid xname protocol request to the X server.
Verify that the X server sends back a reply.
Open a connection to the X server using reversed byte sex.
Send a valid xname protocol request to the X server.
Verify that the X server sends back a reply.
>>CODE

	test_type = GOOD;

	/* Call a library function to exercise the test code */
	testfunc(tester);

>>ASSERTION Bad A
When a client sends an invalid xname protocol request to the X server,
in which the length field of the request is not the minimum length required to 
contain the request,
then the X server sends back a BadLength error to the client.
>>STRATEGY
Call library function testfunc() to do the following:
Open a connection to the X server using native byte sex.
Send an invalid xname protocol request to the X server with length 
  one less than the minimum length required to contain the request.
Verify that the X server sends back a BadLength error.
Open a connection to the X server using reversed byte sex.
Send an invalid xname protocol request to the X server with length 
  one less than the minimum length required to contain the request.
Verify that the X server sends back a BadLength error.

Open a connection to the X server using native byte sex.
Send an invalid xname protocol request to the X server with length 
  greater than the minimum length required to contain the request.
Verify that the X server sends back a BadLength error.
Open a connection to the X server using reversed byte sex.
Send an invalid xname protocol request to the X server with length 
  greater than the minimum length required to contain the request.
Verify that the X server sends back a BadLength error.
>>CODE

	test_type = BAD_LENGTH; /* < minimum */

	/* Call a library function to exercise the test code */
	testfunc(tester);

	test_type = JUST_TOO_LONG; /* > minimum */

	/* Call a library function to exercise the test code */
	testfunc(tester);

>>ASSERTION Bad B 1
When a client sends an invalid xname protocol request to the X server,
in which the length field of the request exceeds the maximum length accepted
by the X server,
then the X server sends back a BadLength error to the client.
>>STRATEGY
Call library function testfunc() to do the following:
Open a connection to the X server using native byte sex.
Send an invalid xname protocol request to the X server with length 
  one greater than the maximum length accepted by the server.
Verify that the X server sends back a BadLength error.
Open a connection to the X server using reversed byte sex.
Send an invalid xname protocol request to the X server with length 
  one greater than the maximum length accepted by the server.
Verify that the X server sends back a BadLength error.
>>CODE

	test_type = TOO_LONG;

	/* Call a library function to exercise the test code */
	testfunc(tester);
