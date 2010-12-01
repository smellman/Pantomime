/*
 **  StdMapIntWrappar.h
 **
 **  Copyright (c) 2010
 **
 **  Author: Taro Matsuzawa <tmatsuzawa@kbmj.com>
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

#ifndef _Pantomime_H_StdMapIntWrapper
#define _Pantomime_H_StdMapIntWrapper

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#include <map>
@interface StdMapIntWrapper : NSObject {
@private
    std::map<int, int> *wrapper_map;
}
#else
@interface StdMapIntWrapper : NSObject {
@private
    void *wrapper_map;
}
#endif

- (int) valueForKey:(int)aKey;
- (void) setValue:(int)aValue forKey:(int)aKey;
- (void) removeValueForKey:(int)aKey;

@end

#endif // _Pantomime_H_StdMapIntWrapper