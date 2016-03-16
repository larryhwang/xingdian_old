//
//  FaultAnnotation.h
//  TuQiangCarOnLine
//
//  Created by apple on 15/8/5.
//  Copyright (c) 2015年 thinkrace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface FaultAnnotation : NSObject<MKAnnotation>
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic,strong) UIImage *image;
@end
