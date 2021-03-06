/*
 *      SCCS:  @(#)unmaperr.c	1.7 (96/11/04)
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

SCCS:   	@(#)unmaperr.c	1.7 96/11/04 TETware release 3.3
NAME:		unmaperr.c
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	May 1992

DESCRIPTION:
	function to convert DTET message reply code values to local errno
	values

MODIFICATIONS:
	Andrew Dingwall, UniSoft Ltd., January 1993
	Rewritten to use the errmap structure.

	Aaron Plattner, April 2010
	Fixed warnings when compiled with GCC's -Wall option.

************************************************************************/

#include <stdio.h>
#include "dtmac.h"
#include "error.h"
#include "dtetlib.h"
#include "errmap.h"


/*
**	tet_unmaperrno() - map DTET message reply code values to local errno
**		values
**
**	return 0 if there is no local errno equivalent
*/

int tet_unmaperrno(repcode)
register int repcode;
{
	register struct errmap *ep, *ee;

	for (ep = tet_errmap, ee = &tet_errmap[tet_Nerrmap]; ep < ee; ep++) {
		if (repcode == ep->em_repcode) {
			if (ep->em_errno >= 0)
				return(ep->em_errno);
			else {
				error(0, tet_ptrepcode(repcode),
					"has no equivalent local errno value");
				break;
			}
		}
	}

	return(0);
}
