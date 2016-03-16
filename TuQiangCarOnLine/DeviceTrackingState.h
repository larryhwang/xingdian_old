//
//  DeviceTrackingState.h
//  NewGps2012
//
//  Created by TR on 13-2-19.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceTrackingState : NSObject

@property (strong, nonatomic) NSString *deviceUtcDate;
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *speed;
@property (strong, nonatomic) NSString *course;
@property (strong, nonatomic) NSString *isStop;
@property (strong, nonatomic) NSString *distance;
@property (strong, nonatomic) NSString *icon;
@property (strong, nonatomic) NSString *acc;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *dataType;//定位方式
@property (strong, nonatomic) NSString *lastCommunication;
@property (strong, nonatomic) NSString *battery;
@property (strong, nonatomic) NSString *standingTime;
@property (nonatomic) BOOL showLocationType;// 是否显示定位方式
@property (nonatomic) BOOL showSpeed;// 是否显示速度
@property (nonatomic) BOOL showBattery;// 是否显示电量

@end
