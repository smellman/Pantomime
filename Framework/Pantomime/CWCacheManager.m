/*
**  CWCacheManager.m
**
**  Copyright (c) 2004-2006
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

#include <Pantomime/CWCacheManager.h>
#include <Pantomime/CWConstants.h>

#include <Foundation/NSKeyedArchiver.h>
#include <Foundation/NSException.h>

@implementation CWCacheManager

- (id) initWithPath: (NSString *) thePath
{
  if ((self = [super init]))
    {
      _cache = [[NSMutableArray alloc] init];
      ASSIGN(_path, thePath);
    }
  
  return self;
}


//
//
//
- (void) dealloc
{
  RELEASE(_cache);
  RELEASE(_path);
  [super dealloc];
}


//
// NSCoding protocol
//
- (void) encodeWithCoder: (NSCoder *) theCoder
{
  // Do nothing.
}

- (id) initWithCoder: (NSCoder *) theCoder
{
  // Do nothing.
  return nil;
}


//
//
//
- (NSString *) path
{
  return _path;
}

- (void) setPath: (NSString *) thePath
{
  ASSIGN(_path, thePath);
}


//
//
//
- (void) invalidate
{
  //[_cache removeAllObjects];
}

//
//
//
- (BOOL) synchronize
{
  BOOL b;

  // We do NOT write empty cache files on disk.
  //if ([_cache count] == 0) return YES;

  NS_DURING
    {
      b = [NSKeyedArchiver archiveRootObject: self  toFile: _path];
    }
  NS_HANDLER
    {
      NSLog(@"Failed to synchronize the %@ cache - not written to disk.", _path);
      b = NO;
    }
  NS_ENDHANDLER
    
  return b;
}


#if 1
//
// For compatibility - will go away in pre4
//
- (NSMutableArray *) cache
{
  return _cache;
}
#endif

//
// For compatibility - will go away in pre4
//
- (void) setCache: (NSArray *) theCache
{
#if 1
  [_cache removeAllObjects];

  if (theCache)
    {
      [_cache addObjectsFromArray: theCache];
    }
#endif
}

@end
