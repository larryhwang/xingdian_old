//
//  ViewController.m
//  NewGps2012
//
//  Created by TR on 13-1-28.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "ViewController.h"
#import "WebServiceParameter.h"
#import "SBJson.h"
#import "TabbarViewController.h"
#import "UIImage+Scale.h"
#import "registerViewController.h"

#import "APService.h"

#define LoginButtonOriginY (iPhone5 ? 44 : 0)
#define WebServiceTag_Login         1
#define WebServiceTag_GetDeviceList 2
#define WebServiceTag_GetGroup      3

@interface ViewController ()
@property (strong, nonatomic) UIImageView *background;
@property (assign, nonatomic) BOOL isBackground;
@property (strong, nonatomic) NSString *userName1;
@property (strong, nonatomic) NSString *password1;
@end

@implementation ViewController

#pragma mark - initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isBackground = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //背景颜色
    self.view.backgroundColor = [UIColor colorWithRed:181/255.0 green:218/255.0 blue:255/255.0 alpha:1.0];
    //为view 添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDismiss)];
    tap.cancelsTouchesInView = NO;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    //添加logo图标
    UIImageView *logo = [[UIImageView alloc] init];
    if (BYT_ISIPHONE5) {
        logo.frame = CGRectMake((VIEW_WIDTH-200)/2,50,200,200*145/280);//...
    }else{
        if (BYT_IOS7) {
            logo.frame = CGRectMake((VIEW_WIDTH-200)/2,20,200,200*145/280);
        }else{
            logo.frame = CGRectMake((VIEW_WIDTH-200)/2,20,200,200*145/280);
        }
    }
    logo.image = [UIImage imageNamed:@"logo.png"];
    [self.view addSubview:logo];

    UIImageView *userNameTextBG = [[UIImageView alloc] init];
    userNameTextBG.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    userNameTextBG.layer.cornerRadius = 5;
    
//    if (BYT_ISIPHONE5) {
        userNameTextBG.frame = CGRectMake(20, logo.frame.origin.y+logo.frame.size.height+60, VIEW_WIDTH-40, 40);
//    } else {
//        userNameTextBG.frame = CGRectMake(20, 115, 280, 40);
//    }
    userNameTextBG.userInteractionEnabled = YES;
    [self.view addSubview:userNameTextBG];
    
    //账号文本框
    self.userNameText = [[UITextField alloc] initWithFrame:CGRectMake(50, 0, 220, 40)];
    self.userNameText.backgroundColor = [UIColor clearColor];
    self.userNameText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.userNameText.delegate = self;
    [userNameTextBG addSubview:_userNameText];
    
    //人头像
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
    [button1 setBackgroundImage:[UIImage imageNamed:@"man"] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(button1Click:) forControlEvents:UIControlEventTouchUpInside];
    [userNameTextBG addSubview:button1];
    
    
    UIImageView *passwordTextBG = [[UIImageView alloc]init];
    passwordTextBG.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    passwordTextBG.layer.cornerRadius = 5;
//    if (BYT_ISIPHONE5) {
        passwordTextBG.frame = CGRectMake(20, userNameTextBG.frame.size.height+userNameTextBG.frame.origin.y+10, VIEW_WIDTH-40 , 40);
//    } else {
//        passwordTextBG.frame = CGRectMake(20, 160, 280, 40);
//    }
    passwordTextBG.userInteractionEnabled = YES;
    [self.view addSubview:passwordTextBG];

    //密码文本框
    self.passwordText = [[UITextField alloc] initWithFrame:CGRectMake(_userNameText.frame.origin.x, 0, 220, 40)];
    self.passwordText.backgroundColor = [UIColor clearColor];
    self.passwordText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.passwordText.secureTextEntry = YES;
    self.passwordText.delegate = self;
    [passwordTextBG addSubview:_passwordText];
    
    //密码锁
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(button1.frame.origin.x, 10, 20, 20)];
    [button2 setBackgroundImage:[UIImage imageNamed:@"pas"] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(button2Click:) forControlEvents:UIControlEventTouchUpInside];
    [passwordTextBG addSubview:button2];
    
    //登录按钮
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    if (BYT_ISIPHONE5) {
        loginButton.frame = CGRectMake((VIEW_WIDTH-240)/2, passwordTextBG.frame.origin.y+passwordTextBG.frame.size.height+20, 240, 50);
//    }else{
//        loginButton.frame = CGRectMake((VIEW_WIDTH-240)/2, 215, 240, 50);
//    }
    loginButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
   // [loginButton setBackgroundImage:[UIImage imageNamed:@"3.png"] forState:UIControlStateNormal];
    loginButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:163/255.0 blue:243/255.0 alpha:1];
    loginButton.layer.cornerRadius = loginButton.frame.size.height/2;
    loginButton.layer.masksToBounds = YES;
    
    
    [loginButton setTitle:MyLocal(@"登录") forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
   [self.view addSubview:loginButton];
//    
//    //记住密码 复选框
//    self.checkBoxButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    if (BYT_ISIPHONE5) {
//        self.checkBoxButton.frame = CGRectMake(10, 300, 34,35);
//    }else{
//        self.checkBoxButton.frame = CGRectMake(10, 270, 34,35);
//    }
//    [_checkBoxButton addTarget:self action:@selector(checkBoxAction) forControlEvents:UIControlEventTouchUpInside];
//    [_checkBoxButton setImage:[UIImage imageNamed:@"disagree.png"] forState:UIControlStateNormal];
//    [_checkBoxButton setImage:[UIImage imageNamed:@"agree.png"] forState:UIControlStateSelected];
//    [self.view addSubview:_checkBoxButton];
//    
//    UILabel *checkBoxLabel = [[UILabel alloc] init];
//    if (BYT_ISIPHONE5) {
//        checkBoxLabel.frame = CGRectMake(45, 300, 120, 35);
//    }else{
//        checkBoxLabel.frame = CGRectMake(45, 270, 120, 35);
//    }
//    checkBoxLabel.backgroundColor = [UIColor clearColor];
//    checkBoxLabel.text = MyLocal(@"记住密码");
//    checkBoxLabel.font = [UIFont systemFontOfSize:16.0f];
//    checkBoxLabel.textColor = [UIColor colorWithRed:214/255.0f green:143/255.0f blue:69/255.0f alpha:1.0f];
//    [self.view addSubview:checkBoxLabel];
//    
// //   自动登录 复选框
//    self.autoLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    if (BYT_ISIPHONE5) {
//        self.autoLoginButton.frame = CGRectMake(115, 300, 34, 35);
//    }else{
//        self.autoLoginButton.frame = CGRectMake(115, 270, 34, 35);
//    }
//    [_autoLoginButton addTarget:self action:@selector(autoLogin) forControlEvents:UIControlEventTouchUpInside];
//    [_autoLoginButton setImage:[UIImage imageNamed:@"disagree.png"] forState:UIControlStateNormal];
//    [_autoLoginButton setImage:[UIImage imageNamed:@"agree.png"] forState:UIControlStateSelected];
//    [self.view addSubview:_autoLoginButton];
    
//    UILabel *autoLoginLabel = [[UILabel alloc] init];
//    if (BYT_ISIPHONE5) {
//        autoLoginLabel.frame = CGRectMake(150,300, 120, 35);
//    }else{
//        autoLoginLabel.frame = CGRectMake(150,270, 120, 35);
//    }
//    autoLoginLabel.backgroundColor = [UIColor clearColor];
//    autoLoginLabel.text = MyLocal(@"自动登录");
//    autoLoginLabel.font = [UIFont systemFontOfSize:16.0f];
//    autoLoginLabel.textColor = [UIColor colorWithRed:214/255.0f green:143/255.0f blue:69/255.0f alpha:1.0f];
//    [self.view addSubview:autoLoginLabel];
    
   // 客户体验
    UIButton *tryButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    if (BYT_ISIPHONE5) {
        tryButton.frame = CGRectMake(20, loginButton.frame.size.height+loginButton.frame.origin.y+10, 90, 35);
//    }else{
//        tryButton.frame = CGRectMake(20, 270, 90, 35);
//    }
    tryButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [tryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    tryButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [tryButton setTitle:MyLocal(@"我要试用") forState:UIControlStateNormal];
    [tryButton addTarget:self action:@selector(tryButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tryButton];
    
    //新用户注册
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    if (BYT_ISIPHONE5) {
        registerButton.frame = CGRectMake(200, tryButton.frame.origin.y, 90, 35);
//    }else{
//        registerButton.frame = CGRectMake(200, 270, 90, 35);
//    }
    registerButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [registerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [registerButton setTitle:MyLocal(@"新用户注册") forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(registerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    registerButton.titleLabel.font = tryButton.titleLabel.font;
    [self.view addSubview:registerButton];
    
    //二维码
    UIImageView *planarCodeImageView = [[UIImageView alloc]init];
    if (BYT_ISIPHONE5) {
        planarCodeImageView.frame = CGRectMake(100, 340, 120, 120);
    }else{
        planarCodeImageView.frame = CGRectMake(100, 310, 120, 120);
    }
    planarCodeImageView.image = [UIImage imageNamed:@"planarcode"];
  //  [self.view addSubview:planarCodeImageView];
    
    UILabel *shareLabel = [[UILabel alloc] init];
    if (BYT_ISIPHONE5) {
        shareLabel.frame = CGRectMake(100,460, 120, 20);
    }else{
        shareLabel.frame = CGRectMake(100,430, 120, 20);
    }
    shareLabel.backgroundColor = [UIColor clearColor];
    shareLabel.text = MyLocal(@"扫扫分享");
    shareLabel.font = [UIFont systemFontOfSize:16.0f];
    shareLabel.textAlignment = NSTextAlignmentCenter;
    shareLabel.textColor = [UIColor colorWithRed:214/255.0f green:143/255.0f blue:69/255.0f alpha:1.0f];
    //[self.view addSubview:shareLabel];
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.color = [UIColor colorWithWhite:0.5 alpha:0.8];
    [self.view addSubview:_hud];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    return;
    self.isRemember = [USER_DEFAULT boolForKey:@"UserPassRemembered"];
    self.isAutoLogin = [USER_DEFAULT boolForKey:@"IsAutoLogin"];
    self.userName = [USER_DEFAULT stringForKey:@"UserName"];
    self.userPassword = [USER_DEFAULT stringForKey:@"UserPass"];
    
    if (_isRemember) {
        self.userNameText.text = _userName;
        self.passwordText.text = _userPassword;
    } else {
        self.userNameText.placeholder = MyLocal(@"账户名/车牌号/IMEI号");
        self.passwordText.placeholder = MyLocal(@"登录密码");
    }
    
    if ([self.userNameText.text isEqualToString:@""] || [self.passwordText.text isEqualToString:@""] || self.userNameText.text == nil || self.passwordText.text == nil)
    {
        
    }
    else {
        self.background = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT)];
        if (iPhone5) {
            _background.image = [UIImage imageNamed:@"Default-568h"];
        }else{
            _background.image = [UIImage imageNamed:@"Default"];
        }
        if (_isBackground) {
            [self.view addSubview:_background];
            _isBackground = NO;
        }
    }

//    [self loginAction];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [_background removeFromSuperview];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //获取Document文件夹下的数据库文件，没有则创建
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingPathComponent:@"user.db"];
    //获取数据库并打开
    self.DB  = [FMDatabase databaseWithPath:dbPath];
    if (![_DB open]) {
        [self showAlert:MyLocal(@"数据库打开失败") withTag:-1];
    }

    self.userNameText.text = [USER_DEFAULT objectForKey:@"UserName"];
    self.passwordText.text = [USER_DEFAULT objectForKey:@"UserPass"];
    if ([self.userNameText.text isEqualToString:@""] || [self.passwordText.text isEqualToString:@""] || self.userNameText.text == nil || self.passwordText.text == nil)
    {
        
    }
    else {
        _userName1 = _userNameText.text;
        _password1 = _passwordText.text;
        [self login];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)tryButtonClick:(UIButton*)button{
    _userName1 = @"0752FHJW";
    _password1 = @"123456";
    [self login];
}

-(void)registerButtonClick:(UIButton*)button{
    //注册新用户
    registerViewController *registerVC = [[registerViewController alloc]init];
    
    [self.navigationController pushViewController:registerVC animated:YES];

}


-(void)button1Click:(UIButton*)button{
    self.userNameText.text = nil;
}

-(void)button2Click:(UIButton*)button{
    self.passwordText.text = nil;
}

//- (void)checkAutoLogin
//{
//    BOOL lastLoginByIMEI = [USER_DEFAULT boolForKey:@"LastLoginByIMEI"];
//    if (!lastLoginByIMEI && _isAutoLogin) {
//        [self loginAction];
//    }
//}

#pragma mark - UITextfieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;// gestureRecognizer不接收UIButton上的点击事件
    }
    return YES;
}

#pragma mark - WebServiceProtocol

- (void)WebServiceGetCompleted:(id)theWebService
{
    if ([[theWebService webServiceResult] length] > 0) {        
//        SBJsonParser *parser = [[SBJsonParser alloc] init];
//        NSError *error = nil;
//        // 解析成json数据
//        id object = [parser objectWithString:[theWebService soapResults] error:&error];
        NSString *str = [theWebService soapResults];
        str = [str stringByReplacingOccurrencesOfString:@"	" withString:@""];
        id object = [str objectFromJSONString];
        if (object) {
            // 获得状态
            int state = [[object objectForKey:@"state"] intValue];
            if ([theWebService tag] == WebServiceTag_Login) {
                // 根据状态判断登录是否成功，0表示成功
                if (state == 0) {
                    //保存用户名和密码
                    [USER_DEFAULT setObject:_userNameText.text forKey:@"UserName"];
                    [USER_DEFAULT setObject:_passwordText.text forKey:@"UserPass"];
                    [USER_DEFAULT synchronize];
//                    if (_checkBoxButton.selected) {
                        [USER_DEFAULT setBool:YES forKey:@"UserPassRemembered"];
//                    } else {
//                        [USER_DEFAULT setBool:NO forKey:@"UserPassRemembered"];
//                    }
//                    if (_autoLoginButton.selected) {
                        [USER_DEFAULT setBool:YES forKey:@"IsAutoLogin"];
//                    } else {
//                        [USER_DEFAULT setBool:NO forKey:@"IsAutoLogin"];
//                    }

                    //获取登录类型
                    NSString *loginType = [object objectForKey:@"loginType"];
                    if ([loginType isEqualToString:@"0"]) {
//                        [APService setAlias:[object objectForKey:@"userID"] callbackSelector:nil object:nil];
//                        [APService setAlias:@"40967" callbackSelector:nil object:nil];
                        
                        [USER_DEFAULT setInteger:0 forKey:@"LoginType"];
                        [USER_DEFAULT setBool:NO forKey:@"LastLoginByIMEI"];
                        
                        object = [object objectForKey:@"userInfo"];
                        self.returnID = [object objectForKey:@"userID"];
                        [USER_DEFAULT setObject:self.returnID forKey:@"ReturnID"];
                        [APService setAlias:_returnID callbackSelector:nil object:nil];
                        NSString *timeZone = [object objectForKey:@"timeZone"];
                        [USER_DEFAULT setObject:timeZone forKey:@"TimeZone"];
                        
                        BOOL bo = [_DB executeUpdate:@"drop table Device"];
                        bo = [_DB executeUpdate:@"create table Device (deviceID integer primary key, deviceName text, groupID integer, licencePlate text, status integer, icon text, latitude text, longitude text, acc integer, power integer, isShowAcc integer, type text, course text)"];
                        
                        [_DB close];

                        TabbarViewController *home = [[TabbarViewController alloc] init];
                        home.hidesBottomBarWhenPushed = YES;
                        //登陆成功后的主页面界面跳转
                        [self presentViewController:home animated:YES completion:nil];
                        
                        if (_hud) {
                            [_hud hide:YES];
                        }
//                        [self getDeviceGroups];
                    }else if ([loginType isEqualToString:@"1"]){
                        
                        [USER_DEFAULT setInteger:1 forKey:@"LoginType"];
                        [USER_DEFAULT setBool:YES forKey:@"LastLoginByIMEI"];
                        
                        object = [object objectForKey:@"deviceInfo"];
                        self.returnID = [object objectForKey:@"deviceID"];
                        [USER_DEFAULT setObject:self.returnID forKey:@"ReturnID"];
                        [APService setAlias:_returnID callbackSelector:nil object:nil];
                        NSString *deviceName = [object objectForKey:@"deviceName"];
                        NSString *timeZone = [object objectForKey:@"timeZone"];
                        [USER_DEFAULT setObject:deviceName forKey:@"DeviceName"];
                        [USER_DEFAULT setObject:timeZone forKey:@"TimeZone"];
                        
                        BOOL bo = [_DB executeUpdate:@"drop table Device"];
                        bo = [_DB executeUpdate:@"create table Device (deviceID integer primary key, deviceName text, groupID integer, licencePlate text, status integer, icon text, latitude text, longitude text, acc integer, power integer, isShowAcc integer, type text, course text)"];
                        
                        [_DB close];
                        
                        TabbarViewController *home = [[TabbarViewController alloc] init];
                        home.hidesBottomBarWhenPushed = YES;
                        [self presentViewController:home animated:YES completion:nil];
                        
                        if (_hud) {
                            [_hud hide:YES];
                        }
//                        [self getDeviceList];
                    }
                }//end_登陆成功
                else {
                    if (_hud) {
                        [_hud hide:YES];
                    }
                    if (state == 2001) {
                        [self showAlert:MyLocal(@"登录错误") withTag:state];
                    }
                    [_background removeFromSuperview];
                    return;
                }
            } else if ([theWebService tag] == WebServiceTag_GetDeviceList) {
                BOOL bo;
                bo = [_DB executeUpdate:@"drop table Device"];
                bo = [_DB executeUpdate:@"create table Device (deviceID integer primary key, deviceName text, groupID integer, licencePlate text, status integer, icon text, latitude text, longitude text, acc integer, power integer, isShowAcc integer, type text, course text)"];
                
                if (state == 0) {
                    NSArray *allDevices = [object objectForKey:@"arr"];
                    for (id aDevice in allDevices) {
                        int deviceID = [[aDevice objectForKey:@"id"] intValue];
                        NSString *name = [aDevice objectForKey:@"name"];
                        int groupID = [[aDevice objectForKey:@"groupID"] intValue];
                        NSString *licencePlate = [aDevice objectForKey:@"car"];
                        int status = [[aDevice objectForKey:@"status"] intValue];
                        NSString *icon = [aDevice objectForKey:@"icon"];
                        NSString *latitude = [aDevice objectForKey:@"latitude"];
                        NSString *longitude = [aDevice objectForKey:@"longitude"];
                        int acc = [[aDevice objectForKey:@"acc"] intValue];
                        int power = [[aDevice objectForKey:@"isGT08"] intValue];
                        int isShowAcc = [[aDevice objectForKey:@"isShowAcc"] intValue];
                        NSString *type = [aDevice objectForKey:@"type"];
                        NSString *course = [aDevice objectForKey:@"course"];
                        
                        BOOL bo;
                        bo = [_DB executeUpdate:@"insert into Device (deviceID, deviceName, groupID, licencePlate, status, icon, latitude, longitude, acc, power, isShowAcc, type, course) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [NSNumber numberWithInt:deviceID], name, [NSNumber numberWithInt:groupID], licencePlate, [NSNumber numberWithInt:status], icon, latitude, longitude, [NSNumber numberWithInt:acc], [NSNumber numberWithInt:power], [NSNumber numberWithInt:isShowAcc], type, course];
                    }
                }
                
                if (_hud) {
                    [_hud hide:YES];
                }
                TabbarViewController *home = [[TabbarViewController alloc] init];
                home.hidesBottomBarWhenPushed = YES;
                [self presentViewController:home animated:YES completion:nil];
            } else if ([theWebService tag] == WebServiceTag_GetGroup) {
                BOOL bo = [_DB executeUpdate:@"drop table DeviceGroup"];
                bo = [_DB executeUpdate:@"create table DeviceGroup (groupID integer, groupName text)"];
                
                // 根据状态判断是否成功，0表示成功
                if (state == 0 || state == 2002) {
                    NSArray *allDevice = [object objectForKey:@"arr"];
                    for (id aDevice in allDevice) {
                        int groupID = [[aDevice objectForKey:@"id"] intValue];
                        NSString *name = [aDevice objectForKey:@"name"];
                        bo = [_DB executeUpdate:@"insert into DeviceGroup (groupID, groupName) values (?, ?)", [NSNumber numberWithInt:groupID], name];
                    }
                } else {
                    if (_hud) {
                        [_hud hide:YES];
                    }
                    
                    //[self showAlert:MyLocal(@"获取设备分组失败") withTag:state];
                }
                
                [self getDeviceList];
            }
        }
    }
}

- (void)WebServiceGetError:(id)theWebService type:(WebServiceFailureType)failureType
{
    if (_hud) {
        [_hud hide:YES];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"网络错误") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
    [alert show];
    [_background removeFromSuperview];
    switch (failureType) {
        case WebServiceTimeOut:
            NSLog(@"time out");
            break;
        case WebServiceInitFailed:
            NSLog(@"init failed");
            break;
        case WebServiceConnectFailed:
            NSLog(@"connection failed");
            break;
        default:
            break;
    }
}

#pragma mark - Target Action

- (void)keyboardDismiss
{
    [_userNameText resignFirstResponder];
    [_passwordText resignFirstResponder];
}

//- (void)checkBoxAction
//{
//    _checkBoxButton.selected = !_checkBoxButton.selected;
//    if (!_checkBoxButton.selected) {
//        _autoLoginButton.selected = NO;
//    }
//}

//- (void)autoLogin
//{
//    _autoLoginButton.selected = !_autoLoginButton.selected;
//    if (_autoLoginButton.selected) {
//        _checkBoxButton.selected = YES;
//    }
//}

- (void)loginAction
{    
    if (_userNameText.text.length == 0 || _passwordText.text.length == 0) {
        [self showAlert:MyLocal(@"登录错误") withTag:0];
    } else {
        if (_hud) {
            [_hud show:YES];
        }
        _userName1 = _userNameText.text;
        _password1 = _passwordText.text;
        [self login];
        
    }
}

#pragma mark - WebService Action

- (void)login
{
    WebService *webService = [WebService newWithWebServiceAction:@"Login2" andDelegate:self];
    webService.tag = WebServiceTag_Login;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"Name" andValue:_userName1];
    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"Pass" andValue:_password1];
    WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"LoginType" andValue:@"0"];
    WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"ParamList" andValue:@"1,1"]; //1推送   1 appid
    NSArray *parameter = @[loginParameter1, loginParameter2, loginParameter3, loginParameter4];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"Login2Result"];
}

- (void)getDeviceList
{
    WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceList" andDelegate:self];
    webService.tag = WebServiceTag_GetDeviceList;
    WebServiceParameter *getDeviceParameter1 = [WebServiceParameter newWithKey:@"ID" andValue:_returnID];
    WebServiceParameter *getDeviceParameter2 = [WebServiceParameter newWithKey:@"PageNo" andValue:@"1"];
    WebServiceParameter *getDeviceParameter3 = [WebServiceParameter newWithKey:@"PageCount" andValue:@"99999"];
    WebServiceParameter *getDeviceParameter4 = [WebServiceParameter newWithKey:@"TypeID" andValue:[NSString stringWithFormat:@"%ld",(long)[USER_DEFAULT integerForKey:@"LoginType"]]];
    WebServiceParameter *getDeviceParameter5 = [WebServiceParameter newWithKey:@"IsAll" andValue:@"true"];
    WebServiceParameter *getDeviceParameter6 = [WebServiceParameter newWithKey:@"MapType" andValue:@"Google"];
    webService.webServiceParameter = @[getDeviceParameter1, getDeviceParameter2, getDeviceParameter3, getDeviceParameter4, getDeviceParameter5, getDeviceParameter6];
    [webService getWebServiceResult:@"GetDeviceListResult"];
}

- (void)getDeviceGroups
{
    WebService *webService = [WebService newWithWebServiceAction:@"GetGroupByUserID" andDelegate:self];
    webService.tag = WebServiceTag_GetGroup;
    WebServiceParameter *getGroupParameter = [WebServiceParameter newWithKey:@"UserID" andValue:_returnID];
    webService.webServiceParameter = @[getGroupParameter];
    [webService getWebServiceResult:@"GetGroupByUserIDResult"];
}

#pragma mark - Database

- (BOOL)isTableExist:(NSString *)tableName
{
    FMResultSet *resultSet = [self.DB executeQuery:@"select count(*) as 'count' from sqlite_master where type = 'table' and name = %@", tableName];
    while ([resultSet next]) {
        NSInteger count = [resultSet intForColumn:@"count"];
        if (count == 0) {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Alert

- (void)showAlert:(NSString *)title withTag:(NSInteger)type
{
    NSString *debugInfo;
    switch (type) {
        case 0:
            debugInfo = [NSString stringWithFormat:MyLocal(@"登录名或密码为空")];
            break;
        case 1001:
            debugInfo = [NSString stringWithFormat:MyLocal(@"参数不对")];
            break;
        case 1002:
            debugInfo = [NSString stringWithFormat:MyLocal(@"程序报错，异常。可能参数错误等")];
            break;
        case 2001:
            debugInfo = [NSString stringWithFormat:MyLocal(@"登录名或密码错误")];
            break;
        case 2002:
            debugInfo = [NSString stringWithFormat:MyLocal(@"没有任何查询结果")];
            break;
        case 3001:
            debugInfo = [NSString stringWithFormat:MyLocal(@"网络连接异常，请稍后再试")];
            break;
        default:
            break;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:debugInfo delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil];
	[alertView show];
    [_background removeFromSuperview];
}

@end
