//
//  MoreViewController.h
//  NewGps2012
//
//  Created by TR on 13-3-22.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) UITableView *moreTable;
@property (strong, nonatomic) NSArray *tableData;

@end
