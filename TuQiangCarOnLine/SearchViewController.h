//
//  SearchViewController.h
//  NewGps2012
//
//  Created by TR on 13-2-4.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "DeviceList.h"

@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UITableView *searchDeviceTable;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) FMDatabase *DB;

@end
