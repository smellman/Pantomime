/*
**  CWPOP3CacheManager.m
**
**  Copyright (c) 2001-2007
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

#include <Pantomime/CWPOP3CacheManager.h>

#include <Pantomime/CWConstants.h>
#include <Pantomime/CWPOP3CacheObject.h>

#include <Foundation/NSKeyedArchiver.h>
#include <Foundation/NSException.h>
#include <Pantomime/io.h>

// LUDO
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSData.h>
#include <Foundation/NSFileManager.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <netinet/in.h>

static unsigned short version = 1;


//
//
//
@interface CWPOP3CacheManager (Private)
- (void) _convertOldCacheFromFile: (NSString *) theFile;
@end

@implementation CWPOP3CacheManager (Private)

- (void) _convertOldCacheFromFile: (NSString *) theFile
{
  id o;

  // 'o' will be decoded as a CWPOP3CacheManager instance.
  o = [NSKeyedUnarchiver unarchiveObjectWithFile: theFile];

  if (o)
    {
      CWPOP3CacheObject* aCacheObject;      
      cache_record r;
      int i;

      ftruncate(_fd, 0);
      [self synchronize];

      for (i = 0; i < [[o cache] count]; i++)
	{
	  aCacheObject = [[o cache] objectAtIndex: i];
	  r.date = [[aCacheObject date] timeIntervalSince1970];
	  r.pop3_uid = [aCacheObject UID];
	  [self writeRecord: &r];
	}

      [self synchronize];
    }
  else
    {
      NSLog(@"COULD NOT DECODE THE CACHE :(");
    }
}

@end


//
//
//
@implementation CWPOP3CacheManager

- (id) initWithPath: (NSString *) thePath
{
  NSDictionary *attributes;
  unsigned short int v;
  
  _table = [[NSMutableDictionary alloc] initWithCapacity:128];
  _count = 0;
  
  if ((_fd = open([thePath UTF8String], O_RDWR|O_CREAT, S_IRUSR|S_IWUSR)) < 0) 
    {
      NSLog(@"CANNOT CREATE OR OPEN THE CACHE!)");
      abort();
    }
  
  if (lseek(_fd, 0L, SEEK_SET) < 0)
    {
      NSLog(@"UNABLE TO LSEEK INITIAL");
      abort();
    }
  
    NSError *error = nil;
    attributes = [[NSFileManager defaultManager] attributesOfItemAtPath: thePath error: &error];

  // If the cache exists, lets parse it.
  if ([[attributes objectForKey: NSFileSize] intValue])
    {
      NSString *aUID;
      NSDate *aDate;

      unsigned short len;
      char *s;
      int i;

      v = read_unsigned_short(_fd);

      // HACK: We CONVERT all the previous cache.
      if (v != version)
	{
	  //NSLog(@"Converting the old cache format.");
	  [self _convertOldCacheFromFile: thePath];
	  return self;
	}      

      _count = read_unsigned_int(_fd);

      //NSLog(@"Init with count = %d  version = %d", _count, v);
  
      s = (char *)malloc(4096);
    
      for (i = 0; i < _count; i++)
	{
	  aDate = [NSDate dateWithTimeIntervalSince1970: read_unsigned_int(_fd)];
	  read_string(_fd, s, &len);	  

	  aUID = AUTORELEASE([[NSString alloc] initWithData: [NSData dataWithBytes: s  length: len]
					       encoding: NSASCIIStringEncoding]);
      [_table setObject:aDate forKey:aUID];
	}
      
      free(s);
    }
  else
    {
      [self synchronize];
    }

  return self;
}

//
//
//
- (void) dealloc
{
  //NSLog(@"CWPOP3CacheManager: -dealloc, _fd was = %d", _fd);
  
  //NSFreeMapTable(_table);
  [_table release];
  if (_fd >= 0) close(_fd);
  [super dealloc];
}

//
// NSCoding protocol
// For compatibility - will go away in pre4
//
#if 1
- (void) encodeWithCoder: (NSCoder *) theCoder
{
  [theCoder encodeObject: _cache];
}

- (id) initWithCoder: (NSCoder *) theCoder
{
  self = [super initWithPath: nil];

  //_table = NSCreateMapTable(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 128);
  _table = [[NSMutableDictionary alloc] initWithCoder:128];
  _fd = -1;

  [self setCache: [theCoder decodeObject]];

  return self;
}
#endif

//
//
//
- (NSDate *) dateForUID: (NSString *) theUID
{
//  return NSMapGet(_table, theUID);
  return [_table objectForKey:theUID];
}


//
//
//
- (BOOL) synchronize
{
  if (lseek(_fd, 0L, SEEK_SET) < 0)
    {
      NSLog(@"fseek failed");
      abort();
      return NO;
    }
  
  // We write our cache version, count and UID validity.
  write_unsigned_short(_fd, version);
  write_unsigned_int(_fd, _count);
 
  return (fsync(_fd) == 0);
}

//
//
//
- (void) writeRecord: (cache_record *) theRecord
{
  NSData *aData;

  // We do NOT write a record we already have in our cache.
  // Some POP3 servers, like popa3d, might return the same UID
  // for messages at different index but with the same content.
  // If that happens, we just don't write that value in our cache.
  if (NSMapGet(_table, theRecord->pop3_uid))
    {
     return;
   }

  if (lseek(_fd, 0L, SEEK_END) < 0)
    {
      NSLog(@"COULD NOT LSEEK TO END OF FILE");
      abort();
    }

  write_unsigned_int(_fd, theRecord->date);

  aData = [theRecord->pop3_uid dataUsingEncoding: NSASCIIStringEncoding];
  write_string(_fd, (unsigned char *)[aData bytes], [aData length]);
  
  
  NSMapInsert(_table, theRecord->pop3_uid, [NSDate dateWithTimeIntervalSince1970: theRecord->date]);
  _count++;
}

@end
