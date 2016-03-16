//
//  ChangePwdViewController.h
//  NewGps2012
//
//  Created by TR on 13-4-16.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebService.h"

@interface ChangePwdViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate, WebServiceProtocol, UITableViewDataSource>
@property (strong, nonatomic) UITableView *changePwdTable;

@end
