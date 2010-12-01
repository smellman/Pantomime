/*
 **  StdMapIntWrappar.mm
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

#import <Pantomime/StdMapIntWrapper.h>


@implementation StdMapIntWrapper

- (id) init 
{
    self = [super init];
    if (self) 
    {
        wrapper_map = new std::map<int, int>;
    }
    return self;
}

- (int) valueForKey:(int)aKey
{
    return (* wrapper_map)[aKey];
}

- (void) setValue:(int)aValue forKey:(int)aKey
{
    (* wrapper_map)[aKey] = aValue;
}

- (void) removeValueForKey:(int)aKey
{
    std::map<int, int>::iterator it;
    it = (* wrapper_map).find(aKey);
    if (it != (* wrapper_map).end())
    {
        (* wrapper_map).erase(it);
    }
}

- (void) dealloc
{
    wrapper_map = NULL;
    [super dealloc];
}

@end
