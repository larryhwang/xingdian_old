//
//  WebServiceParameter.m
//  NewGps2012
//
//  Created by TR on 13-1-28.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "WebServiceParameter.h"

@implementation WebServiceParameter
@synthesize key;
@synthesize value;

- (id)init
{
    return [self initWithKey:nil andValue:nil];
}

- (id)initWithKey:(NSString *)newKey andValue:(NSString *)newValue
{
    if (self = [super init]) {
        key = newKey;
        value = newValue;
    }
    return self;
}

+ (id)newWithKey:(NSString *)newKey andValue:(NSString *)newValue;
{
    return [[WebServiceParameter alloc] initWithKey:newKey andValue:newValue];
}

@end
