//
//  POIAnnotation.m
//  几米位置在线
//
//  Created by apple on 14-8-26.
//  Copyright (c) 2014年 thinkrace. All rights reserved.
//

#import "POIAnnotation.h"

@implementation POIAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate
{
    if (self = [super init]) {
        _coordinate = aCoordinate;
    }
    return self;
}

@end
