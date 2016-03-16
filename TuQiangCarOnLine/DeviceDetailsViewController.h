//
//  DeviceDetailsViewController.h
//  NewGps2012
//
//  Created by TR on 13-2-19.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "WebService.h"
#import "DeviceDetail.h"
#import "MBProgressHUD.h"

@interface DeviceDetailsViewController : UIViewController <WebServiceProtocol, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) FMDatabase *DB;
@property (strong, nonatomic) DeviceDetail *theDeviceDetail;
@property (assign, nonatomic) int deviceID;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) UITableView *detailTable;

@end
