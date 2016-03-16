//
//  GeoFenceAnnotation.h
//  途强汽车在线
//
//  Created by apple on 14-5-13.
//  Copyright (c) 2014年 thinkrace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface GeoFenceAnnotation : NSObject <MKAnnotation>

@property (assign, nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (copy, nonatomic) NSString *name;

@property (copy, nonatomic) NSString *type;

@property (copy, nonatomic) NSString *geoFenceID;

@property (copy, nonatomic) NSString *geoFenceNo;

@property (assign, nonatomic) NSInteger index;

@property (assign, nonatomic) NSInteger number;

@property (assign, nonatomic) NSInteger radius;

@property (assign, nonatomic) BOOL selected;

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate;

@end
