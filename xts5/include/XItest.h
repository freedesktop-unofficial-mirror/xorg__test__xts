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
* Copyright (c) Applied Testing and Technology, Inc. 1995
* Copyright 1992 by Hewlett-Packard.
* All Rights Reserved.
*
* Project: VSW5
*
* File: xts5/include/XITest.h
*
* Description:
*	Defines used by the X Input Device tests
*
* Modifications:
* $Log: XItest.h,v $
* Revision 1.2  2005-11-03 08:42:00  jmichael
* clean up all vsw5 paths to use xts5 instead.
*
* Revision 1.1.1.2  2005/04/15 14:05:07  anderson
* Reimport of the base with the legal name in the copyright fixed.
*
* Revision 8.0  1998/12/23 23:23:28  mar
* Branch point for Release 5.0.2
*
* Revision 7.0  1998/10/30 22:41:33  mar
* Branch point for Release 5.0.2b1
*
* Revision 6.0  1998/03/02 05:15:59  tbr
* Branch point for Release 5.0.1
*
* Revision 5.0  1998/01/26 03:12:30  tbr
* Branch point for Release 5.0.1b1
*
* Revision 4.0  1995/12/15 08:38:24  tbr
* Branch point for Release 5.0.0
*
* Revision 3.2  1995/12/15  00:37:49  andy
* Prepare for GA Release
*
*/

#define	KeyMask		(1 << 0)
#define	BtnMask		(1 << 1)
#define	ValMask		(1 << 2)
#define	AnyMask		(1 << 3)
#define	KFeedMask	(1 << 4)
#define	PFeedMask	(1 << 5)
#define	IFeedMask	(1 << 6)
#define	SFeedMask	(1 << 7)
#define	BFeedMask	(1 << 8)
#define	LFeedMask	(1 << 9)
#define	NKeysMask	(1 << 10)
#define	NBtnsMask	(1 << 11)
#define	ModMask		(1 << 12)
#define	NFeedMask	(1 << 13)
#define	NValsMask	(1 << 14)
#define	DCtlMask	(1 << 15)
#define	DModMask	(1 << 16)
#define	DValMask	(1 << 17)
#define	FCtlMask	(1 << 18)
#define	FocusMask	(1 << 19)
#define	NDvCtlMask	(1 << 20)

typedef struct _ExtDeviceInfo
    {
    XDevice *Key;
    XDevice *Button;
    XDevice *Valuator;
    XDevice *Any;
    XDevice *KbdFeed;
    XDevice *PtrFeed;
    XDevice *IntFeed;
    XDevice *StrFeed;
    XDevice *BelFeed;
    XDevice *LedFeed;
    XDevice *NoKeys;
    XDevice *NoButtons;
    XDevice *Mod;
    XDevice *NoFeedback;
    XDevice *NoValuators;
    XDevice *DvCtl;
    XDevice *DvMod;
    XDevice *DvVal;
    XDevice *Focus;
    XDevice *NDvCtl;
    } ExtDeviceInfo;

