//
//  HomeViewController.h
//  NewGps2012
//
//  Created by TR on 13-1-29.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomHeaderView.h"
#import "FMDatabase.h"
#import "WebService.h"
#import "MBProgressHUD.h"

@interface HomeViewController : UIViewController <CustomHeaderViewDelegate, UITableViewDataSource, UITableViewDelegate, WebServiceProtocol>

@property (strong, nonatomic) FMDatabase *DB;// 数据库实例
@property (strong, nonatomic) NSMutableArray *groups;// 每种设备分组ID及对应的分组名
@property (strong, nonatomic) NSMutableArray *allDevices;
@property (strong, nonatomic) NSMutableArray *onlineDevices;
@property (strong, nonatomic) NSMutableArray *offlineDevices;
@property (strong, nonatomic) NSMutableArray *allDeviceLists;// 所有分组设备列表，存储的是deviceGroup对象
@property (strong, nonatomic) NSMutableArray *onlineDeviceLists;// 所有在线分组设备列表
@property (strong, nonatomic) NSMutableArray *offlineDeviceLists;// 所有离线分组设备列表
@property (strong, nonatomic) UIButton *all;
@property (strong, nonatomic) UIButton *online;
@property (strong, nonatomic) UIButton *offline;
@property (strong, nonatomic) UIImageView *naviView;
@property (strong, nonatomic) UITableView *table;
@property (strong, nonatomic) NSMutableArray *tableDataLists;
@property (strong, nonatomic) MBProgressHUD *hud;

@end
