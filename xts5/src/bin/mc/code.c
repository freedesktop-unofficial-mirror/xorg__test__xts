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
* All Rights Reserved.
*
* Project: VSW5
*
* File: src/bin/mc/code.c
*
* Description:
*       .m file processing routines for mc utilities
*
* Modifications:
* $Log: code.c,v $
* Revision 1.2  2005-04-21 09:40:42  ajosey
* resync to VSW5.1.5
*
* Revision 8.1  1999/11/24 16:57:12  vsx
* removed commented-out code in mcend()
*
* Revision 8.0  1998/12/23 23:24:10  mar
* Branch point for Release 5.0.2
*
* Revision 7.0  1998/10/30 22:42:21  mar
* Branch point for Release 5.0.2b1
*
* Revision 6.0  1998/03/02 05:16:37  tbr
* Branch point for Release 5.0.1
*
* Revision 5.0  1998/01/26 03:13:09  tbr
* Branch point for Release 5.0.1b1
*
* Revision 4.0  1995/12/15 08:41:10  tbr
* Branch point for Release 5.0.0
*
* Revision 3.2  1995/12/15  02:09:59  andy
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
*/

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include	<stdio.h>
#include	<string.h>
#include	<ctype.h>

#include	"mc.h"

#define	F_CODE		"mccode.tmc"
#define	F_STRATEGY	"mcstrategy.tmc"
#define	F_ASSERTION	"mcassert.tmc"
#define	F_STDEXTERN	"mcextern.mc"
#define	F_EXTERN	"mcextern.tmc"
#define	F_STDXPEXTERN	"mcxpext.mc"
#define	F_STDXTEXTERN	"mcxtext.mc"
#define	F_STDXCEXTERN	"mcxcmsext.mc"
#define	F_XPEXTERN	"mcxpext.tmc"
#define	F_STDINCLUDE 	"mcinclude.mc"
#define	F_INCLUDE	"mcinclude.tmc"
#define	F_STDXPINCLUDE	"mcxpinc.mc"
#define	F_STDXTINCLUDE	"mcxtinc.mc"
#define	F_STDXCINCLUDE	"mcxcinc.mc"
#define	F_XPINCLUDE	"mcxpinc.tmc"
#define	F_BANNER	"mcbanner.tmc"
#define	F_SYNOPSIS	"mcsynopsis.tmc"

static FILE	*FpCode;
static FILE	*FpExtern;
static FILE	*FpInclude;
static FILE	*FpBanner;
static FILE	*FpSynopsis;
static FILE	*FpStrategy;
static FILE	*FpAssertion;
#define	FpDefines FpExtern

extern	int 	Lineno;
extern	char	*Filename;
extern	int 	dflag;
extern	int 	lflag;
extern	int 	mflag;
extern	int 	pflag;
extern	int 	sflag;

extern	struct	settings	Settings;
extern	struct	state	State;

#define PRELEN	80

#define	MAXTP	1024
#define	MAXARGS	40

#define	NRSEPS	" \t\n\""

static	int 	Testnum;
static	char	*Ictype[MAXTP];
static	short	Icnum[MAXTP];
static	char	*ExpectError;
/* TEMP as we don't use it there is no way to set this at present */
static	int 	gbflag = 0;	/* Use Good/bad */

extern	char	*newline();

static	char	*validtypes[] = {
	"def",
	"Good",
	"Bad",
	(char*)0,
};

static char	*Arglines[MAXARGS];
static char	*Argnames[MAXARGS];
static char	*Arginit[MAXARGS];
static int 	Nargs;
static int 	NeedStatus;
static int 	NeedValue;
static int 	NeedTpcleanup;
static int 	Resyncline;

static void	setline();
static void	setoutline();
static void roffstrip();

/*ARGSUSED*/
void
mcstart(buf)
char	*buf;
{
	FpBanner = cretmpfile(F_BANNER, NULL);
	FpSynopsis = cretmpfile(F_SYNOPSIS, NULL);
	FpExtern = cretmpfile(F_EXTERN, NULL);
	FpInclude = cretmpfile(F_INCLUDE, NULL);
	FpCode = cretmpfile(F_CODE, NULL);
	FpStrategy = cretmpfile(F_STRATEGY, NULL);
	FpAssertion = (FILE *)-1;
	FpStrategy = (FILE *)-1;
	setoutline();
	fprintf(FpCode, "%sint 	tet_thistest;\n\n", (lflag)? "extern ": "");
}

/*ARGSUSED*/
void
mcend(buf)
char	*buf;
{
	int i;

	/* Finish the copyright banner */
	fprintf(FpBanner, "*/\n");

	/* Finish the code section */
	fprintf(FpCode, "/* End of Test Cases */\n\n\n");

	setoutline();
	fprintf(FpCode, "%sstruct tet_testlist tet_testlist[] = {\n",
		(lflag)? "static ": "");

	/*
	 * List out the test function names.
	 */
	for (i = 1; i <= Testnum; i++) {
		if (!gbflag)
			fprintf(FpCode, "\t{ t%03d, %d },\n", Icnum[i], Icnum[i]);
		else
			fprintf(FpCode, "\t{ t%03d, %s },\n", Icnum[i], Ictype[i]);
	}
	fprintf(FpCode, "\t{ NULL, 0 }\n};\n\n");
	fprintf(FpCode, "%sint \tntests = sizeof(tet_testlist)/sizeof(struct tet_testlist)-1;\n\n",
		(lflag)?"static ": "");

	/*
	 * If this is for space saving format then output the linkinfo
	 * entry.
	 */
	if (lflag) {
		fprintf(FpCode, "struct linkinfo E%s = {\n", name12(State.name));
		fprintf(FpCode, "\t\"%s%s\",\n",
			(mflag)? "m": "",name10lc(State.name));
		fprintf(FpCode, "\t\"%s\",\n", State.name);
		fprintf(FpCode, "\t&ntests,\n");
		fprintf(FpCode, "\ttet_testlist,\n");
		if (Settings.startup)
			fprintf(FpCode, "\t%s,\n", Settings.startup);
		else
			fprintf(FpCode, "\t0,\n");

		if (Settings.cleanup)
			fprintf(FpCode, "\t%s,\n", Settings.cleanup);
		else
			fprintf(FpCode, "\t0,\n");
		fprintf(FpCode, "};\n\n");
	}

	/*
	 * Do the TET interface variables depending on whether this
	 * is a linked binary or not.
	 */
	if (lflag) {
		fprintf(FpCode, "extern void	(*tet_startup)();\n");
		fprintf(FpCode, "extern void	(*tet_cleanup)();\n");
	} else {
		if (State.xtoolkit != 0)
		{
			fprintf(FpCode, "void	(*tet_startup)() = %s;\n"
				, Settings.startup? Settings.startup: "NULL" );
			fprintf(FpCode, "void	(*tet_cleanup)() = %s;\n"
				, Settings.cleanup? Settings.cleanup: "NULL");
		} 
		else if (State.xcms != 0)
		{
			fprintf(FpCode, "void	(*tet_startup)() = %s;\n"
				, Settings.startup? Settings.startup: "r5_startup" );
			fprintf(FpCode, "void	(*tet_cleanup)() = %s;\n"
				, Settings.cleanup? Settings.cleanup: "r5_cleanup");
		} 
		else 
		{
			fprintf(FpCode, "void	(*tet_startup)() = %s;\n"
			 	, Settings.startup? Settings.startup: "startup");
			fprintf(FpCode, "void	(*tet_cleanup)() = %s;\n"
				, Settings.cleanup? Settings.cleanup: "cleanup");
		}
	}
	

	/*
	 * Output sub files in correct order.
	 */
	outfile(FpBanner);
	outfile(FpSynopsis);
	if (State.xtoolkit)
		outcopy(F_STDXTINCLUDE);
	else if (State.xcms)
		outcopy(F_STDXCINCLUDE);
	else
		outcopy(State.xproto? F_STDXPINCLUDE: F_STDINCLUDE);
	outfile(FpInclude);
	if (State.xtoolkit)
		outcopy(F_STDXTEXTERN);
	else if (State.xcms)
		outcopy(F_STDXCEXTERN);
	else
		outcopy(State.xproto? F_STDXPEXTERN: F_STDEXTERN);
	outfile(FpExtern);
	outfile(FpCode);
}

/*
 * Output the copyright messages
 */
void
mccopyright(fp, buf)
FILE	*fp;
char	*buf;
{
static	int 	firsttime = 1;
int i;

	while (newline(fp, buf) != NULL && !SECSTART(buf)) {
		i = 0;
		while ((buf[i] == ' ') || (buf[i] == '*') || (buf[i] == '/')) 
			i++;
		if (firsttime == 1) {
			fputs("/*\n", FpBanner);
			firsttime = 0;
		}
		if (strlen(&buf[i]) == 0)
			fputs("* \n", FpBanner);
		else {
			fputs("* ", FpBanner);
			fputs(&buf[i], FpBanner);
		}
	}
}

/*
 * A header request has been found.
 */
void
mcheader(fp, buf)
FILE	*fp;
char	*buf;
{
char	*arg;
char	*cp;
int 	i;
static	int 	oncethrough;


	if ((State.xtoolkit == 0) && (State.xcms == 0))
	{
		Settings.tpstartup = "tpstartup";
		Settings.tpcleanup = "tpcleanup";
	}

	/*
	 * If we have already seen a header, then just return on the
	 * assumption that the name is not changing.  Otherwise
	 * it is probably an error.
	 */
	if (oncethrough) {
		skip(fp, buf);
		return;
	}
	oncethrough = 1;

	setoutline();
	fprintf(FpExtern, "\n#define T_%s\t1\n", State.name);
	fprintf(FpExtern, "%schar    *TestName = \"%s\";\n\n",
			(lflag)? "static ": "", State.name);

	Nargs = 0;

	while (newline(fp, buf) && !SECSTART(buf)) {

		Arglines[Nargs] = mcstrdup(buf);
		/*
		 * The type of the function must be first, followed by
		 * the arguments in the correct order.
		 */
		if (Nargs == 0) {
			if (strncmp(buf, "Status", strlen("Status")) == 0)
				NeedStatus = 1;
			if (strncmp(buf, "int", strlen("int")) == 0)
				NeedValue = 1;
		} else if (Nargs == 1) {
			; /* call */
		} else {
			arg = mcstrdup(buf);

			/*
			 * Separate out any initialisation part of the declaration.
			 */
			cp = strchr(arg, '=');
			if (cp) {
				*cp = '\0';
				cp++;
				while (isspace(*cp))
					cp++;

				Arginit[Nargs] = mcstrdup(cp);
			}

			/*
			 * This gets the last word in the declaration.  This is often
			 * the name of the parameter being declared.
			 */
			for (cp = strtok(arg, ARGSEP); cp; cp = strtok((char*)0, ARGSEP)) {
				Argnames[Nargs] = cp;
			}

			/*
			 * If the first argument is a Display type then save the 
			 * arg name for use in startcall() etc.
			 */
			if (Nargs == 2 && strncmp(Arglines[Nargs], "Display", 7) == 0) {
				Settings.display = Argnames[Nargs];
			}
		}
		Nargs++;
	}

	defargnames();

	/*
	 * If this is a test for a function then declare the argument variables
	 * here.
	 */
	if (Nargs > 2)
		fprintf(FpExtern, "/*\n * Arguments to the %s %s\n */\n",
			State.name, (mflag)? "macro": "function");
	for (i = 2; i < Nargs; i++) {
		fprintf(FpExtern, "static ");
		for (cp = Arglines[i]; *cp; cp++) {
			if ((*cp == ' ' && cp[1] == '=') || *cp == '=') {
				fprintf(FpExtern, ";\n");
				break;
			}
			fputc(*cp, FpExtern);
		}
	}
	if (Nargs > 2)
		fprintf(FpExtern, "\n\n");

	if (NeedStatus)
		fprintf(FpExtern, "static int 	StatusReturn;\n");
	if (NeedValue)
		fprintf(FpExtern, "static int 	ValueReturn;\n");
	if (NeedStatus || NeedValue)
		fprintf(FpExtern, "\n");

	if (Nargs > 2) {
		fprintf(FpCode, "/*\n * Called at the beginning of each test purpose to reset the\n * arguments to their initial values\n */\n");
		fprintf(FpCode, "static void\nsetargs()\n{\n");

		for (i = 2; i < Nargs; i++) {
			if (Arginit[i])
				fprintf(FpCode, "\t%s = %s", Argnames[i], Arginit[i]);
			else
				fprintf(FpCode, "\t%s = 0;\n", Argnames[i]);
		}
		fprintf(FpCode, "}\n\n");
	}

	/*
	 * Put out the routine to call that initialises the default values
	 * for the server resources for testing error funtcions.
	 */
	if (Nargs) {
		fprintf(FpCode, "/*\n * Set the arguments to default values for error tests\n */\n");
		fprintf(FpCode, "static void\nseterrdef()\n{\n");
	}

	for (i = 2; i < Nargs; i++) {
	static char *errdeftypes[] = {
		"Atom",
		"Colormap",
		"Cursor",
		"Drawable",
		"Font",
		"GC",
		"Pixmap",
		"Window",
		(char*)0,
		};
	char	**cp;

		if (Arginit[i])
			continue;

		for (cp = errdeftypes; *cp; cp++) {
			if (strncmp(Arglines[i], *cp, strlen(*cp)) == 0)
				fprintf(FpCode, "\t%s = Errdef%s;\n", Argnames[i], *cp);
		}
	}
	if (Nargs)
		fprintf(FpCode, "}\n\n");

	/*
	 * If this is testing a particular function then put out a
	 * synopsis in the header.
	 */
	if (Nargs > 1) {
		fprintf(FpSynopsis, "/*\n * SYNOPSIS:\n");
		fprintf(FpSynopsis, " *   %s", Arglines[0]); /* return type */
		fprintf(FpSynopsis, " *   %s(", State.name);
		for (i = 2; i < Nargs; i++) {
			fprintf(FpSynopsis, "%s%s", Argnames[i], (i == Nargs-1)? "": ", ");
		}
		fprintf(FpSynopsis, ")\n");
		for (i = 2; i < Nargs; i++) {
			fprintf(FpSynopsis, " *   ");
			for (cp = Arglines[i]; *cp; cp++) {
				if ((*cp == ' ' && cp[1] == '=') || *cp == '=') {
					fprintf(FpSynopsis, ";\n");
					break;
				}
				fputc(*cp, FpSynopsis);
			}
		}
		fprintf(FpSynopsis, " */\n\n");
	}
}

#define	STRPRECMP(s1, s2) (strncmp(s1, s2, strlen(s2)))
/*
 * Put out defines for argnames of various types.  This is for use
 * by included tests that need to reference arguments of various
 * types.
 */
defargnames()
{
int 	i;
int 	atom = 0;
int 	colormap = 0;
int 	cursor = 0;
int 	display = 0;
int 	drawable = 0;
int 	font = 0;
int 	gc = 0;
int 	pixmap = 0;
int 	window = 0;
int 	image = 0;

	if (Nargs > 2)
		fprintf(FpDefines, "/*\n * Defines for different argument types\n */\n");

	for (i = 2; i < Nargs; i++) {

		/*
		 * TEMP, while I think about it.
		 * Forget lines with a '*' unless they are for display or image.
		 */
		if (strchr(Arglines[i], '*')
			&& STRPRECMP(Arglines[i], "Display") != 0
			&& STRPRECMP(Arglines[i], "XImage") != 0)
			continue;

		if (STRPRECMP(Arglines[i], "Atom") == 0) {
			if (atom == 0)
				fprintf(FpDefines, "#define A_ATOM %s\n", Argnames[i]);
			atom++;
			defargtype("A_ATOM", atom);
		} else if (STRPRECMP(Arglines[i], "Colormap") == 0) {
			if (colormap == 0)
				fprintf(FpDefines, "#define A_COLORMAP %s\n", Argnames[i]);
			colormap++;
			defargtype("A_COLORMAP", colormap);
		} else if (STRPRECMP(Arglines[i], "Cursor") == 0) {
			if (cursor == 0)
				fprintf(FpDefines, "#define A_CURSOR %s\n", Argnames[i]);
			cursor++;
			defargtype("A_CURSOR", cursor);
		} else if (STRPRECMP(Arglines[i], "Display") == 0) {
			if (display++ > 0) {
				err("Too many display args\n");
				errexit();
			}
			defargtype("A_DISPLAY", display);
			fprintf(FpDefines, "#define A_DISPLAY %s\n", Argnames[i]);
		} else if (STRPRECMP(Arglines[i], "Drawable") == 0) {
			if (drawable > 0)
				fprintf(FpDefines, "#define A_DRAWABLE%d %s\n",
					drawable+1, Argnames[i]);
			else
				fprintf(FpDefines, "#define A_DRAWABLE %s\n", Argnames[i]);
			drawable++;
			defargtype("A_DRAWABLE", drawable);
		} else if (STRPRECMP(Arglines[i], "Font") == 0) {
			if (font == 0)
				fprintf(FpDefines, "#define A_FONT %s\n", Argnames[i]);
			font++;
			defargtype("A_FONT", font);
		} else if (STRPRECMP(Arglines[i], "GC") == 0) {
			if (gc == 0)
				fprintf(FpDefines, "#define A_GC %s\n", Argnames[i]);
			gc++;
			defargtype("A_GC", gc);
		} else if (STRPRECMP(Arglines[i], "XImage") == 0) {
			/*
			 * At present all the files that have an image have A_IMAGE
			 * defined in the file, this is wrong.  Just record that we
			 * have an arg and leave.
			 */
			image++;
			defargtype("A_IMAGE", image);
		} else if (STRPRECMP(Arglines[i], "Pixmap") == 0) {
			if (pixmap == 0)
				fprintf(FpDefines, "#define A_PIXMAP %s\n", Argnames[i]);
			else
				fprintf(FpDefines, "#define A_PIXMAP%d %s\n", pixmap+1, Argnames[i]);
			if (drawable > 0)
				fprintf(FpDefines, "#define A_DRAWABLE%d %s\n",
					drawable+1, Argnames[i]);
			else
				fprintf(FpDefines, "#define A_DRAWABLE %s\n", Argnames[i]);
			drawable++;
			defargtype("A_DRAWABLE", drawable);
			pixmap++;
			defargtype("A_PIXMAP", pixmap);
		} else if (STRPRECMP(Arglines[i], "Window") == 0) {
			if (window == 0)
				fprintf(FpDefines, "#define A_WINDOW %s\n", Argnames[i]);
			else
				fprintf(FpDefines, "#define A_WINDOW%d %s\n", window+1, Argnames[i]);
			if (drawable > 0)
				fprintf(FpDefines, "#define A_DRAWABLE%d %s\n",
					drawable+1, Argnames[i]);
			else
				fprintf(FpDefines, "#define A_DRAWABLE %s\n", Argnames[i]);
			drawable++;
			defargtype("A_DRAWABLE", drawable);
			window++;
			defargtype("A_WINDOW", window);
		}
	}
	fprintf(FpDefines, "\n\n");
}

/*
 * An assertion has been found. Place it as a comment in the source.
 */
void
mcassertion(fp, buf)
FILE	*fp;
char	*buf;
{
char	**cpp;

	if (FpAssertion != (FILE *) -1) {
		fclose(FpAssertion);
		unlink(F_ASSERTION);
	}
	FpAssertion = cretmpfile(F_ASSERTION, NULL);

	if (State.type == NULL) {
		err("Missing type\n");
		State.type = "Good";
	}
	if (State.category == CAT_NONE) {
		err("Missing category\n");
		State.category = CAT_A;
	}

	for (cpp = validtypes; *cpp; cpp++) {
		if (strcmp(State.type, *cpp) == 0)
			break;
	}
	if (*cpp == NULL) {
		err("Unrecognised assertion type");
		fprintf(stderr, " (%s)\n", State.type);
		errexit();
	}

	fprintf(FpAssertion, "Assertion %s-%d.(%c)\n", State.name,
		State.assertion, State.category);

	Testnum++;
	Ictype[Testnum] = mcstrdup(State.type);
	Icnum[Testnum] = State.assertion;

	assertfill(fp, buf, FpAssertion, "");

	if (State.category == CAT_B || State.category == CAT_D) {
		if (State.reason == NULL) {
			err("Missing or invalid reason code for assertion\n");
			State.reason = "No reason code supplied";
		}

		fprintf(FpAssertion, "\nReason for omission: %s\n", State.reason);
	}


}

/*
 * Write out the assertion, filling lines.
 */
assertfill(fp, buf, outfp, prefix)
FILE	*fp;
char	*buf;
FILE	*outfp;
char	*prefix;
{
register int 	assertpos;
register char	*tok;
int 	oldpos;
int 	inmacro;	/* inmacro is set to the 'depth' of the macro */
int 	needscrunch;
char	*endl;

	assertpos = 0;
	while (newline(fp, buf) != NULL && !SECSTART(buf)) {
		inmacro = 0;
		needscrunch = 0;
		endl = strchr(buf, '\n');
		for (tok = strtok(buf, NRSEPS); tok; tok = strtok((char*)0, NRSEPS)) {

			if (endl && tok > endl) {
				endl = strchr(tok+strlen(tok)+1, '\n');
				inmacro = 0;
				needscrunch = 0;
			}

			/*
			 * The .tL macro is used for simple tables.  We don't want
			 * to print them out though.
			 */
			if (strcmp(tok, ".tL") == 0) {
				break;	/* ie. skip this line altogether. */
#if 0
				fprintf(outfp, "\n%s", prefix);
				assertpos = 0;
				inmacro = 1;
#endif
			}
				
			/*
			 * Throw out nroff dot commands.
			 */
			if (*tok == '.' && (strlen(tok) == 2 || strlen(tok) == 3)) {
				inmacro = 1;
				if (strlen(tok) == 2) {
					switch (tok[1]) {
					case 'S': case 'F':
					case 'M': case 'A':
						needscrunch = 1;
						break;
					}
				}
				continue;
			}

			/*
			 * Strip off any nroffisms.
			 */
			roffstrip(tok, inmacro);

			oldpos = assertpos;
			/* Plus 1 for the space */
			assertpos += strlen(tok) + 1;
			if (assertpos > ASLENGTH && !joinpunct(*tok)) {
				assertpos = strlen(tok);
				fprintf(outfp, "\n%s", prefix);
			} else if (oldpos > 0 && needscrunch < 2 && !joinpunct(*tok))
				fputc(' ', outfp);
			fprintf(outfp, "%s", tok);
			if (needscrunch)
				needscrunch++;
		}
	}
	return(0);
}

/*
 * Strip nroff backslash constructions from the token.
 */
static void
roffstrip(intok, macro)
char	*intok;
int 	macro;
{
char	*pos;
char	*tok;

	while (macro-- >= 0) {
		tok = intok;
		for (pos = tok; *pos; pos++) {
			if (*pos == '\\') {
				pos++;
				switch (*pos) {
				case 'f':
					if (pos[1] == '(')
						pos += 4;
					else
						pos += 2;
					break;
				}
			}
			*tok++ = *pos;
		}
		*tok = '\0';
	}
}

/*
 * If the arg is punctuation that should be attatched to the preceeding
 * word then return 1, else 0.
 */
joinpunct(c)
int 	c;
{
	if (strchr("!)+}]?/,.", c))
		return 1;
	else
		return 0;
}

void
mcstrategy(fp, buf)
FILE	*fp;
char	*buf;
{
/*APTEST - place strategy in journal*/
	if (FpStrategy != (FILE *) -1) {
		fclose(FpStrategy);
		unlink(F_STRATEGY);
	}
	FpStrategy = cretmpfile(F_STRATEGY, NULL);
	while (newline(fp, buf) != NULL && !SECSTART(buf)) {
		fprintf(FpStrategy, "%s", buf);
	}
	return;

}

void
mccode(fp, buf)
FILE	*fp;
register char	*buf;
{
int 	indecs = 1;

	/*
	 * Get the expected error type.
	 */
	(void)strtok(buf, SEPS);
	ExpectError = mcstrdup(strtok((char*)0, SEPS));
	/* This (the event bit) may go away since it is not used */
	if (ExpectError == NULL || strcmp(ExpectError, "event") == 0)
		ExpectError = "Success";

	funcstart();
	while (newline(fp, buf) != NULL && !SECSTART(buf)) {
		/*
		 * As a temporary measure we assume that a blank line
		 * signals the end of the declarations.
		 */
		if (indecs && (*buf == '\0' || *buf == '\n')) {
			indecs = 0;
			setoutline();
			if (State.xtoolkit != 0)
				fprintf(FpCode, "pid_t	pid;\n");
			else if (State.xcms == 0)
				fprintf(FpCode, "int 	pass = 0, fail = 0;\n");
			fprintf(FpCode, "\n 	report_purpose(%d);\n\n", State.assertion);
			(void)fseek(FpAssertion, 0 , SEEK_SET);
			while (newline(FpAssertion, buf) != NULL && !SECSTART(buf)) {
					/*strip newlines*/
					if (buf[strlen(buf)-1] == '\n')
						buf[strlen(buf)-1] = 0;
				fprintf(FpCode, "	report_assertion(\"%s\");\n", buf);
			}
			buf[0] = 0;

			if ((State.xtoolkit == 0) && (State.xcms == 0))
			{
				(void)fseek(FpStrategy, 0 , SEEK_SET);
				(void)fprintf(FpCode, "\n");
				while (newline(FpStrategy, buf) != NULL && !SECSTART(buf)) {
					/*strip newlines*/
					if (buf[strlen(buf)-1] == '\n')
						buf[strlen(buf)-1] = 0;
					fprintf(FpCode, "	report_strategy(\"%s\");\n", buf);
				}
				buf[0] = 0;
			}

			if ((Settings.tpstartup != NULL) && (strlen(Settings.tpstartup) != 0))
				fprintf(FpCode, "\n	%s();\n", Settings.tpstartup);
			if ((State.xtoolkit == 0) && (State.xcms == 0))
			{
				if (Nargs > 2)
					fprintf(FpCode, "	setargs();\n");
			}
			if (Settings.beginfunc)
				fprintf(FpCode, "	%s();\n", Settings.beginfunc);
			if (State.xtoolkit != 0) 
			{
				fprintf(FpCode, "	FORK(pid);\n");
				fprintf(FpCode, "	initconfig();\n\n");
			}
			NeedTpcleanup = 1;
			Resyncline = 1;
		}
		setline(FpCode);

		/*
		 * Check for the special symbol XCALL which signals that
		 * the call setup and cleanup procedure should be output.
		 */
		if (strinstr(buf, XCALLSYM) != NULL) {
			doxcall(FpCode, buf);
		} else {
			fputs(buf, FpCode);
		}

	}
	setoutline();
	funcend();
}

void
mcexterncode(fp, buf)
FILE	*fp;
char	*buf;
{
	ExpectError = "Success";
	Resyncline = 1;
	while (newline(fp, buf) != NULL && !SECSTART(buf)) {
		setline(FpExtern);
		/*
		 * Check for the special symbol XCALL which signals that
		 * the call setup and cleanup procedure should be output.
		 */
		if (strinstr(buf, XCALLSYM) != NULL) {
			doxcall(FpExtern, buf);
		} else {
			fputs(buf, FpExtern);
		}
	}

	fputc('\n', FpExtern);

}

funcstart()
{

	fprintf(FpCode, "%svoid t%03d(){\n\n", (dflag)?"" : "static ",  State.assertion);
	NeedTpcleanup = 0;
	Resyncline = 1;
}

funcend()
{
	if (NeedTpcleanup && Settings.endfunc)
		fprintf(FpCode, "\t%s();\n", Settings.endfunc);
	if (NeedTpcleanup) 
	{
		if (State.xtoolkit != 0) 
			fprintf(FpCode, "\n	LKROF(pid, AVSXTTIMEOUT*xt_tomultiple);\n");
		if ((Settings.tpcleanup != NULL) && (strlen(Settings.tpcleanup) != 0))
			fprintf(FpCode, "\t%s();\n", Settings.tpcleanup);
		if ((State.xtoolkit == 0) && (State.xcms == 0))
			fprintf(FpCode, "\tpfcount(pass, fail);\n");
	}
/*
	}
*/
	fprintf(FpCode, "}\n\n");
}


doxcall(fp, buf)
FILE	*fp;
char	*buf;
{
char	prefix[PRELEN];
register char	*pp;
register char	*cp;
register int 	i;
int 	insertstat = 0;
int 	insertval = 0;

	setoutline();
	pp = prefix;
	for (cp = buf; isspace(*cp); cp++)
		*pp++ = *cp;

	*pp++ = '\0';
	if (ExpectError == NULL)
		ExpectError = "Success";

	fputs(prefix, fp);
	if (Settings.display)
		fprintf(fp, "startcall(%s);\n", Settings.display);
	else
		fputs("startcall(Dsp);\n", fp);
	fprintf(fp, "%sif (isdeleted())\n%s\treturn;\n",
		prefix, prefix);

	setline(fp);
	/*
	 * Substitute the string XCALL with the call to the function
	 */
	cp = strinstr(cp, XCALLSYM);
	*cp = '\0';
	fputs(buf, fp);

	/*
	 * If there is no equals sign before the XCALL then we insert our
	 * own status checking.  If there is one then it is assumed that
	 * you are doing your own checking, so mc stays out the way.
	 */
	if (NeedStatus && strchr(buf, '=') == NULL) {
		insertstat = 1;
		fputs("StatusReturn = ", fp);
	}
	/* Also check for casts (to void) for return values */
	if (NeedValue && strchr(buf, '=') == NULL && strchr(buf, '(') == NULL) {
		insertval = 1;
		fputs("ValueReturn = ", fp);
	}
	fprintf(fp, "%s(", State.name);
	for (i = 2; i < Nargs; i++) {
		fprintf(fp, "%s%s", Argnames[i], (i == Nargs-1)? "": ", ");
	}
	fprintf(fp, ")");
	cp += strlen(XCALLSYM);
	fputs(cp, fp);

	setoutline();

	if (Settings.needgcflush)
		fprintf(fp, "%sgcflush(A_DISPLAY, A_GC);\n", prefix);
	if (Settings.display)
		fprintf(fp, "%sendcall(%s);\n", prefix, Settings.display);
	else
		fprintf(fp, "%sendcall(Dsp);\n", prefix);

	/*
	 * If we are generating code to check for the Status return, then
	 * check for true or false depending on whether the test was declared
	 * to be 'Good' or 'Bad'.  If failreturn is set then return
	 * on failure.  Also need to use tpcleanup if returning.
	 */
	if (insertstat) {
		fprintf(fp, "%sif (StatusReturn %s 0) {\n", prefix,
			(strcmp(Ictype[Testnum], "Good") == 0)? "==": "!=");
		fprintf(fp, "%s\treport(\"Status returned was %%d\", StatusReturn);\n",
			prefix);
		fprintf(fp, "%s\tFAIL;\n", prefix);
		if (Settings.failreturn) {
			if (NeedTpcleanup && Settings.endfunc)
				fprintf(fp, "%s\t%s();\n", prefix, Settings.endfunc);
			if (NeedTpcleanup)
				fprintf(fp, "%s\t%s();\n", prefix, Settings.tpcleanup);
			fprintf(fp, "%s\treturn;\n", prefix);
		}
		fprintf(fp, "%s}\n", prefix);
	}

	/* As above, but for a value return */
	if (insertval && Settings.valreturn && *Settings.valreturn) {
		fprintf(fp, "%sif (ValueReturn != %s) {\n", prefix,
			Settings.valreturn);
		fprintf(fp,
		  "%s\treport(\"Returned value was %%d, expecting %s\", ValueReturn);\n"
		  , prefix, Settings.valreturn);
		fprintf(fp, "%s\tFAIL;\n", prefix);
		if (Settings.failreturn) {
			if (NeedTpcleanup && Settings.endfunc)
				fprintf(fp, "%s\t%s();\n", prefix, Settings.endfunc);
			if (NeedTpcleanup)
				fprintf(fp, "%s\t%s();\n", prefix, Settings.tpcleanup);
			fprintf(fp, "%s\treturn;\n", prefix);
		}
		fprintf(fp, "%s}\n", prefix);
	}

	/*
	 * If wanted check the error status.
	 */
	if (Settings.noerrcheck == 0) {
		fprintf(fp, "%sif (geterr() != %s) {\n", prefix, ExpectError);
		fprintf(fp, "%s\treport(\"Got %%s, Expecting %s\", errorname(geterr()));\n", prefix, ExpectError);
		fprintf(fp, "%s\tFAIL;\n", prefix);
		if (Settings.failreturn) {
			if (NeedTpcleanup && Settings.endfunc)
				fprintf(fp, "%s\t%s();\n", prefix, Settings.endfunc);
			if (NeedTpcleanup)
				fprintf(fp, "%s\t%s();\n", prefix, Settings.tpcleanup);
			fprintf(fp, "%s\treturn;\n", prefix);
		}
		fprintf(fp, "%s}\n", prefix);
	}

	/* These settings only apply for one xcall */
	Settings.noerrcheck = 0;
}


void
mcdefassertion(fp, buf)
FILE	*fp;
char	*buf;
{

	char buf2[MAXLINE];

	memset(buf2, 0, sizeof(buf2));
	mcassertion(fp, buf);
	funcstart();
	fprintf(FpCode, "\n 	report_purpose(%d);\n\n", State.assertion);

	(void)fseek(FpAssertion, 0 , SEEK_SET);
	while (newline(FpAssertion, buf2)) {
		if (buf2[strlen(buf2)-1] == '\n')
			buf2[strlen(buf2)-1] = 0;
		fprintf(FpCode, "	report_assertion(\"%s\");\n", buf2);
	}

	fprintf(FpCode, "\treport_assertion(\"The assertion is descriptive or is tested elsewhere.\");\n");
	fprintf(FpCode, "\ttet_result(TET_NOTINUSE);\n");
	funcend();
}

/*
 * Start and end included files.  Don't clutter up the output by
 * printing when temporary files are being included.
 */
void
mcincstart(buf)
char	*buf;
{
	if (strcmp(buf+strlen(buf)-4, ".tmc") != 0)
		fprintf(FpCode, "/* Including from file %s */\n", buf);
}

void
mcincend(buf)
char	*buf;
{
	if (strcmp(buf+strlen(buf)-4, ".tmc") != 0)
		fprintf(FpCode, "/* End of included file %s */\n\n", buf);
}

static void
setline(fp)
FILE	*fp;
{
static	int 	lastline;

	if (pflag) {
		if (Resyncline || lastline+1 != Lineno) {
			fprintf(fp, "#line %d \"%s\"\n",
				Lineno, Filename? Filename: "stdin");
			Resyncline = 0;
		}
		lastline = Lineno;
	}
}

static void
setoutline()
{
	if (pflag) {
		fprintf(FpCode, ">>G\n");
		Resyncline = 1;
	}
}
