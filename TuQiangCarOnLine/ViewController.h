//
//  ViewController.h
//  NewGps2012
//
//  Created by TR on 13-1-28.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "WebService.h"
#import "MBProgressHUD.h"

@interface ViewController : UIViewController <UITabBarDelegate, UITextFieldDelegate, WebServiceProtocol, UIGestureRecognizerDelegate>

@property (strong, nonatomic) FMDatabase *DB;
@property (strong, nonatomic) UITextField *userNameText;
@property (strong, nonatomic) UITextField *passwordText;
@property (strong, nonatomic) UIButton *checkBoxButton;
@property (strong, nonatomic) UIButton *autoLoginButton;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) NSString *userName;// 用户名登录时的登录名
@property (strong, nonatomic) NSString *userPassword;// 用户名登录密码
@property (assign, nonatomic) BOOL isRemember;// 用户名登录是否记住用户名和密码
@property (assign, nonatomic) BOOL isAutoLogin;// 是否自动登录
@property (strong, nonatomic) NSString *returnID;// 登录请求返回的userID


@end
