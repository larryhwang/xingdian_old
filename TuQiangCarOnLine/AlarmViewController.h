//
//  AlarmViewController.h
//  NewGps2012
//
//  Created by TR on 13-2-20.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "WebService.h"

@interface AlarmViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, WebServiceProtocol>

@property (strong, nonatomic) FMDatabase *DB;
@property (strong, nonatomic) UITableView *alarmTable;
@property (strong, nonatomic) NSMutableArray *alarmsForDevice;
@property (strong, nonatomic) NSArray *alarmTypes;
@property (assign, nonatomic) NSInteger deviceID;
@property (assign, nonatomic) NSInteger pageNumber;
@property (assign, nonatomic) BOOL isLoadingMore;// 正在加载更多
@property (assign, nonatomic) BOOL isRefresh;

@property (strong, nonatomic) NSString *pushID;
@property (assign, nonatomic) BOOL isPresent;

@end
