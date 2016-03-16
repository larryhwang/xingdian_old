//
//  CustomAnnotation.h
//  NewGps2012
//
//  Created by TR on 13-2-18.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CustomAnnotation : NSObject <MKAnnotation>

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *annotationID;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (copy, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *carIcon;
@property (nonatomic) BOOL showCallout;
@property (nonatomic) NSInteger deviceIndex;
@property (copy, nonatomic) NSString *course;
@property (copy, nonatomic) NSString *imageName;

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate;

@end
