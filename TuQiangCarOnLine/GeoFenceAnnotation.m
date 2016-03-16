//
//  GeoFenceAnnotation.m
//  途强汽车在线
//
//  Created by apple on 14-5-13.
//  Copyright (c) 2014年 thinkrace. All rights reserved.
//

#import "GeoFenceAnnotation.h"

@implementation GeoFenceAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate
{
    if (self = [super init]) {
        _coordinate = aCoordinate;
    }
    return self;
}

@end
