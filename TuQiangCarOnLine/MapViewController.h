//
//  MapViewController.h
//  NewGps2012
//
//  Created by TR on 13-3-22.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FMDatabase.h"
#import "DeviceList.h"
#import "MBProgressHUD.h"

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) MKMapView      *LocMapView;
@property (strong, nonatomic) NSMutableArray *deviceArray;
@property (strong, nonatomic) NSMutableArray *humanLocLatLngArray;
@property (strong, nonatomic) FMDatabase     *DB;
@property (strong, nonatomic) MBProgressHUD  *hud;
@property (nonatomic        ) NSInteger      currentShowBubbleIndex;

@end
