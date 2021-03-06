/*
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
*/
/*
*
* Copyright (c) 2001 The Open Group
* Copyright (c) Applied Testing and Technology, Inc. 1995
* All Rights Reserved.
*
* Project: VSW5
*
* File: xts5/include/Xstos.h
*
* Description:
*	Defines used by the X tests
*
* Modifications:
* $Log: Xstos.h,v $
* Revision 1.3  2005-11-03 08:42:00  jmichael
* clean up all vsw5 paths to use xts5 instead.
*
* Revision 1.2  2005/04/21 09:40:42  ajosey
* resync to VSW5.1.5
*
* Revision 8.2  2005/01/20 15:44:53  gwc
* Updated copyright notice
*
* Revision 8.1  2001/02/05 11:18:32  vsx
* include errno.h instead of declaring errno; delete unused code
*
* Revision 8.0  1998/12/23 23:23:30  mar
* Branch point for Release 5.0.2
*
* Revision 7.0  1998/10/30 22:41:35  mar
* Branch point for Release 5.0.2b1
*
* Revision 6.0  1998/03/02 05:16:00  tbr
* Branch point for Release 5.0.1
*
* Revision 5.0  1998/01/26 03:12:31  tbr
* Branch point for Release 5.0.1b1
*
* Revision 4.0  1995/12/15 08:38:29  tbr
* Branch point for Release 5.0.0
*
* Revision 3.2  1995/12/15  00:37:57  andy
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

Copyright 1988 by Sequent Computer Systems, Inc., Portland, Oregon       
                                                                         
                                                                         
                        All Rights Reserved                              
                                                                         
Permission to use, copy, modify, and distribute this software and its    
documentation for any purpose and without fee is hereby granted,         
provided that the above copyright notice appears in all copies and that  
both that copyright notice and this permission notice appear in          
supporting documentation, and that the name of Sequent not be used       
in advertising or publicity pertaining to distribution or use of the     
software without specific, written prior permission.                     
                                                                         
SEQUENT DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING 
ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL 
SEQUENT BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR  
ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,      
WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,   
ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS      
SOFTWARE.                                                                
*/

/* Header file for UNIX library for X Server tests. */

/*
 * System header files.
 */

#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <string.h>
#include <errno.h>


#define SearchString(string, char) strchr((string), (char))


/*
 * Note that some machines do not return a valid pointer for malloc(0), in
 * which case we provide an alternate under the control of the
 * define MALLOC_0_RETURNS_NULL.  This is necessary because some
 * Xst code expects malloc(0) to return a valid pointer to storage.
 */
#define EXTRA 16
#ifdef MALLOC_0_RETURNS_NULL

# define Xstmalloc(size) malloc(max((size)+EXTRA,1))
# define Xstrealloc(ptr, size) realloc((ptr), max((size)+EXTRA,1))
# define Xstcalloc(nelem, elsize) calloc(max((nelem)+EXTRA,1), (elsize))

#else

# define Xstmalloc(size) malloc((size)+EXTRA)
# define Xstrealloc(ptr, size) realloc((ptr), (size)+EXTRA)
# define Xstcalloc(nelem, elsize) calloc((nelem)+EXTRA, (elsize))

#endif
