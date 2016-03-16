//
//  POIAnnotation.h
//  几米位置在线
//
//  Created by apple on 14-8-26.
//  Copyright (c) 2014年 thinkrace. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

typedef NS_ENUM(NSInteger, POIType) {
	POITypeSource,
	POITypeDestination
};

@interface POIAnnotation : NSObject <MKAnnotation>

@property (assign, nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (assign) POIType type;

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate;

@end
