//
//  TrackingViewController.h
//  NewGps2012
//
//  Created by TR on 13-2-19.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "WebService.h"
#import "CustomAnnotation.h"

@interface TrackingViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, WebServiceProtocol>

@property (nonatomic, strong) MKMapView *trackingMapView;
@property (assign, nonatomic) BOOL isShowHumanLocation;// 显示的是否是当前位置
@property (nonatomic, strong) CustomAnnotation *pinAnnotation;// 用来展示自定义的AnnotaionView
@property (nonatomic, strong) NSMutableArray *trackingStates;
@property (nonatomic, strong) NSMutableArray *locations;// 运动轨迹所需的地址信息
@property (nonatomic, strong) NSString *icon;// 显示的车子图标
@property (nonatomic, strong) UILabel *address;


@end
