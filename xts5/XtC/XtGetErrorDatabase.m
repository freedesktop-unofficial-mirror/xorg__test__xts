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

Copyright (c) Applied Testing and Technology, Inc. 1993, 1994, 1995
Copyright (c) 88open Consortium, Ltd. 1990, 1991, 1992, 1993
All Rights Reserved.

>># 
>># Project: VSW5
>># 
>># File: xts/XtC/XtGetErrorDatabase.m
>># 
>># Description:
>>#	Tests for XtGetErrorDatabase()
>># 
>># Modifications:
>># $Log: tgterrdbs.m,v $
>># Revision 1.1  2005-02-12 14:38:24  anderson
>># Initial revision
>>#
>># Revision 8.0  1998/12/23 23:38:26  mar
>># Branch point for Release 5.0.2
>>#
>># Revision 7.0  1998/10/30 23:01:29  mar
>># Branch point for Release 5.0.2b1
>>#
>># Revision 6.0  1998/03/02 05:29:28  tbr
>># Branch point for Release 5.0.1
>>#
>># Revision 5.0  1998/01/26 03:26:02  tbr
>># Branch point for Release 5.0.1b1
>>#
>># Revision 4.0  1995/12/15 09:22:25  tbr
>># Branch point for Release 5.0.0
>>#
>># Revision 3.1  1995/12/15  02:18:58  andy
>># Prepare for GA Release
>>#
>>EXTERN
#include <X11/IntrinsicP.h>
#include <X11/ConstrainP.h>
#include <X11/CoreP.h>

#define ER_SIZE	512

XtAppContext app_ctext;
Widget topLevel, panedw, boxw1, boxw2;
Widget labelw, rowcolw, click_quit;
>>TITLE XtGetErrorDatabase XtC
XrmDatabase *
tGetErrorDatabase()
>>ASSERTION Good A
A call to 
XrmDatabase *XtGetErrorDatabase()
shall return the address of the global error 
database for the calling process.
>>CODE
XrmDatabase *database, file_database, db_return;
char file_name[1024];
char buffer[ER_SIZE];
char *contents = "testString.error:Testing XtErrorMsg\n";
char *ErrorString = "Testing XtErrorMsg";
pid_t pid2;

	FORK(pid2);
	avs_xt_hier("Tgterrdbs1", "XtGetErrorDatabase");
	tet_infoline("PREP: Create windows for widgets and map them");
	XtRealizeWidget(topLevel);
	tet_infoline("PREP: Get the file name to dump error message");
	strcpy(file_name, "/tmp/");
	strcat(file_name, "outfile");
	tet_infoline("PREP: Create error database.");
	XrmInitialize();
	db_return = XrmGetStringDatabase(contents);
	(void)XrmPutFileDatabase(db_return,file_name);
	file_database = XrmGetFileDatabase(file_name);
	tet_infoline("PREP: Obtain the error database.");
	database = XtGetErrorDatabase();
	if (database == NULL) {
	 	sprintf(ebuf, "ERROR: Expected database to be non-NULL.");
		tet_infoline(ebuf);
		tet_result(TET_FAIL);
	}
	tet_infoline("PREP: Merge original database with new database");
	XrmMergeDatabases(file_database, database);
	tet_infoline("PREP: Get message for testString.error");
	XtGetErrorDatabaseText(
		"testString", "error", "AppError",
		"ERROR: Unable find database Text ", buffer,
		 ER_SIZE);
	sprintf(ebuf, "TEST: Check message was %s", ErrorString);
	tet_infoline(ebuf);
	check_str(ErrorString, buffer, "Error String");
	tet_infoline("CLEANUP: Unlink database file");
	unlink(file_name);
	LKROF(pid2, AVSXTTIMEOUT-2);
	unlink(file_name);
	tet_result(TET_PASS);
