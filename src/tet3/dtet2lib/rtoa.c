/*
 *      SCCS:  @(#)rtoa.c	1.7 (98/08/28) 
 *
 *	UniSoft Ltd., London, England
 *
 * (C) Copyright 1992 X/Open Company Limited
 *
 * All rights reserved.  No part of this source code may be reproduced,
 * stored in a retrieval system, or transmitted, in any form or by any
 * means, electronic, mechanical, photocopying, recording or otherwise,
 * except as stated in the end-user licence agreement, without the prior
 * permission of the copyright owners.
 *
 * X/Open and the 'X' symbol are trademarks of X/Open Company Limited in
 * the UK and other countries.
 */

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

/************************************************************************

SCCS:   	@(#)rtoa.c	1.7 98/08/28 TETware release 3.3
NAME:		rtoa.c
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	April 1992

DESCRIPTION:
	function to return printable representation of a remote client/server
	identifier
	(this is not the same as a DTET API remoteid)

MODIFICATIONS:

	Andrew Dingwall, UniSoft Ltd., July 1998
	Only compile code in this file when building Distributed TETware.
	Added support for shared API libraries.

	Aaron Plattner, April 2010
	Fixed warnings when compiled with GCC's -Wall option.

************************************************************************/

#ifndef TET_LITE	/* -START-LITE-CUT- */

#include <stdio.h>
#include <sys/types.h>
#include "dtmac.h"
#include "dtmsg.h"
#include "ptab.h"
#include "ltoa.h"
#include "dtetlib.h"

#define RBUFSZ		(sizeof fmt + ((LNUMSZ - 2) * 2) + (20 - 5))

/*
**	tet_r2a() - return printable representation of remote process id
*/

TET_IMPORT char *tet_r2a(rp)
struct remid *rp;
{
	static char fmt[] = "(sysid = %d, pid = %ld: %.20s)";
	static char buf[NLBUF][RBUFSZ];
	static int count;
	register char *p;

	if (++count >= NLBUF)
		count = 0;
	p = buf[count];

	sprintf(p, fmt, rp->re_sysid, rp->re_pid,
		tet_ptptype(rp->re_ptype));
	return(p);
}

#else		/* -END-LITE-CUT- */

int tet_rtoa_c_not_used;

#endif		/* -LITE-CUT-LINE- */

