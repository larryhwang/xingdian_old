//
//  DeviceList.h
//  NewGps2012
//
//  Created by TR on 13-2-1.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Device : NSObject

@property (nonatomic, assign) int deviceID;
@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, assign) int groupID;
@property (nonatomic, strong) NSString *licencePlate;
@property (nonatomic, assign) int status;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, assign) int acc;
@property (nonatomic, assign) int power;
@property (nonatomic, assign) int isShowAcc;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *course;

@end


@interface DeviceGroup : NSObject

@property (nonatomic, assign) int groupID;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSMutableArray *devicesByGroup;// 分组下的设备列表（多个Device实例）
@property (nonatomic, assign) BOOL isUnfolded;
@property (nonatomic, strong) NSMutableArray *indexPaths;

- (void)setUnfoldState:(BOOL)s;

@end

