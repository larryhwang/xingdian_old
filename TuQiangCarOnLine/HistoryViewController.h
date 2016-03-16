//
//  HistoryViewController.h
//  NewGps2012
//
//  Created by TR on 13-3-13.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "WebService.h"
#import "CustomAnnotation.h"
#import "MBProgressHUD.h"

@interface HistoryViewController : UIViewController <WebServiceProtocol, MKMapViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) MKMapView *historyMap;// 地图实例
@property (strong, nonatomic) NSTimer *historyTimer;// 历史轨迹时间选择方式
@property (strong, nonatomic) NSMutableArray *historyStates;// 存储返回的轨迹点数据
@property (strong, nonatomic) NSString *lastDeviceUtcDate;// 上次记录的设备定位时间
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIButton *pauseButton;
@property (strong, nonatomic) UIButton *stopButton;
@property (strong, nonatomic) MBProgressHUD *hud;
@end
