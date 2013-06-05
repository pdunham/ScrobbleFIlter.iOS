//
//  NSArray+Shuffle.m
//  ScrobbleFIlter
//
//  Created by Phillip Dunham on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSArray+Shuffle.h"

@implementation NSArray (Shuffle)

- (NSArray*) shuffle {
    // create temporary mutable array
    NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[self count]];
    for (id anObject in self) {
        NSUInteger randomPos = arc4random()%([tmpArray count]+1);
        [tmpArray insertObject:anObject atIndex:randomPos]; 
    }
    return [NSArray arrayWithArray:tmpArray];  // non-mutable autoreleased copy
}

@end
