//
//  AllAlarmsViewController.h
//  NewGps2012
//
//  Created by TR on 13-3-22.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "WebService.h"

@interface AllAlarmsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, WebServiceProtocol>

@property (strong, nonatomic) UITableView *alarmsTable;
@property (strong, nonatomic) FMDatabase *DB;
@property (strong, nonatomic) NSMutableArray *alarmsArray;
@property (strong, nonatomic) NSArray *alarmTypes;
@property (strong, nonatomic) NSString *keyID;// AllAlarms表keyID字段值，用于区分两种登录方式显示的报警信息
@property (assign, nonatomic) NSInteger pageNumber;
@property (assign, nonatomic) BOOL isLoadingMore;
@property (assign, nonatomic) BOOL isRefresh;

@end
