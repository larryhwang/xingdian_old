//
//  GeoFenceAnnotationView.h
//  途强汽车在线
//
//  Created by apple on 14-5-13.
//  Copyright (c) 2014年 thinkrace. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface GeoFenceAnnotationView : MKAnnotationView

@property (nonatomic, copy)   NSString  *name;
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, copy)   NSString  *type;
@property (nonatomic, assign) NSInteger radius;
@property (nonatomic, assign) BOOL      showCallout;

@end
