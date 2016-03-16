//
//  NSString+RemoveEndZero.m
//  途强
//
//  Created by TR on 13-8-20.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "NSString+RemoveEndZero.h"

@implementation NSString (RemoveEndZero)

- (NSString *)stringByRemoveEndZero
{
    NSMutableString *primevalString = [self mutableCopy];
    
    while ([[primevalString substringFromIndex:primevalString.length-1] isEqualToString:@"0"]) {
        [primevalString deleteCharactersInRange:NSMakeRange(primevalString.length-1, 1)];
    }
    
    if ([[primevalString substringFromIndex:primevalString.length-1] isEqualToString:@"."]) {
        [primevalString deleteCharactersInRange:NSMakeRange(primevalString.length-1, 1)];
    }
    
    return primevalString;
}

@end
