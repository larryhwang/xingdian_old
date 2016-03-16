//
//  NavigationViewController.h
//  几米位置在线
//
//  Created by apple on 14-8-26.
//  Copyright (c) 2014年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface NavigationViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) MKMapItem *source;
@property (strong, nonatomic) MKMapItem *destination;

@end
