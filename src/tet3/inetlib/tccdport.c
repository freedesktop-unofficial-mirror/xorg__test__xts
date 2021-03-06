/*
 *      SCCS:  @(#)tccdport.c	1.9 (98/09/01) 
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

SCCS:   	@(#)tccdport.c	1.9 98/09/01 TETware release 3.3
NAME:		tccdport.c
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	April 1992

DESCRIPTION:
	function to return TCCD's well-known port number

MODIFICATIONS:

	Andrew Dingwall, UniSoft Ltd., July 1998
	Changed u_short to unsigned short (u_short is not in UNIX98).

	Aaron Plattner, April 2010
	Fixed warnings when compiled with GCC's -Wall option.

************************************************************************/

#include <errno.h>
#include <sys/types.h>
#  include <netinet/in.h>
#  include <netdb.h>
#include "dtmac.h"
#include "error.h"
#include "time.h"
#include "dtmsg.h"
#include "ptab.h"
#include "inetlib_in.h"

#ifndef NOTRACE
#include "ltoa.h"
#endif

/*
**	tet_gettccdport() - return tccd port number in host byte order
**
**	return -1 on error
**	(so don't define the tccd port number as > 32767 on 16 bit machines!)
*/

int tet_gettccdport()
{
	static int port;
	register struct servent *sp;
	int err;

	if (port)
		return(port);

	CLEAR_SOCKET_ERRNO;
	if ((sp = getservbyname("tcc", "tcp")) == (struct servent *) 0) {
		err = SOCKET_ERRNO;
		error(err != ENOTTY ? err : 0,
			"tcc/tcp: unknown service", (char *) 0);
		port = -1;
	}
	else
		port = ntohs((unsigned short) sp->s_port);

	endservent();

	TRACE2(tet_Tio, 2, "tccd port = %s", tet_i2a(port));

	return(port);
}

