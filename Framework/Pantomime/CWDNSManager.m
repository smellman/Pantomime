/*
**  CWDNSManager.m
**
**  Copyright (c) 2004-2007
**
**  Author: Ludovic Marcotte <ludovic@Sophos.ca>
**
**  This library is free software; you can redistribute it and/or
**  modify it under the terms of the GNU Lesser General Public
**  License as published by the Free Software Foundation; either
**  version 2.1 of the License, or (at your option) any later version.
**  
**  This library is distributed in the hope that it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
**  Lesser General Public License for more details.
**  
**  You should have received a copy of the GNU Lesser General Public
**  License along with this library; if not, write to the Free Software
**  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/

#include <Pantomime/CWDNSManager.h>

#include <Pantomime/CWConstants.h>
#ifdef __MINGW32__
#include <winsock2.h>
#else
#include <netdb.h>
#endif
#include <unistd.h>

static CWDNSManager *singleInstance = nil;

//
//
//
@implementation CWDNSManager

- (id) init
{
  self = [super init];

  _cache = [[NSMutableDictionary alloc] init];

  return self;
}


//
//
//
- (void) dealloc
{
  RELEASE(_cache);
  [super dealloc];
}


//
//
//
- (NSArray *) addressesForName: (NSString *) theName
{
  id o;

  o = [_cache objectForKey: theName];

  if (!o)
    {
      struct hostent *host_info;

        host_info = gethostbyname([theName cStringUsingEncoding: NSUTF8StringEncoding]);
      
      if (host_info)
	{
	  int i;

	  o = [NSMutableArray array];
	  
	  for (i = 0;; i++)
	    {
	      if (host_info->h_addr_list[i] == NULL)
		{
		  break;
		}
	      else
		{
		  [o addObject: [NSData dataWithBytes: host_info->h_addr_list[i]  length: host_info->h_length]];
		}
	    }
	  
	  // We only cache if we have at least one address for the DNS name.
	  if ([o count])
	    {
	      [_cache setObject: o  forKey: theName];
	    }
	}
      else
	{
	  o = nil;
	}
    }
  
  return o;
}


//
//
//
+ (id) singleInstance
{
  if (!singleInstance)
    {
      singleInstance = [[CWDNSManager alloc] init];
    }

  return singleInstance;
}

@end

