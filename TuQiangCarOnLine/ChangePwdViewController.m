//
//  ChangePwdViewController.m
//  NewGps2012
//
//  Created by TR on 13-4-16.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "ChangePwdViewController.h"
#import "MBProgressHUD.h"
#import "WebServiceParameter.h"
#import "SBJson.h"
#import "UIImage+Scale.h"

@interface ChangePwdViewController ()
@property (strong, nonatomic) UITextField *currentPwdText;
@property (strong, nonatomic) UITextField *changePwdText;
@property (strong, nonatomic) UITextField *confirmPwdText;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) NSArray *tipsArray;

@end

@implementation ChangePwdViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = MyLocal(@"修改密码");
        self.tipsArray = @[MyLocal(@"请输入旧密码"), MyLocal(@"请输入新密码"), MyLocal(@"重新输入新密码")];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    IOS7;
    
    self.view.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDismiss)];
    tap.cancelsTouchesInView = NO;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    // 返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 11, 21)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    if (BYT_IOS7) {
        self.changePwdTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT-44-20) style:UITableViewStyleGrouped];
    }else{
        self.changePwdTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT-44) style:UITableViewStyleGrouped];
    }
    [self.changePwdTable setBackgroundView:nil];
    [self.changePwdTable setBackgroundColor:[UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0]];
    self.changePwdTable.scrollEnabled = NO;
    self.changePwdTable.separatorColor = [UIColor grayColor];
    self.changePwdTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.changePwdTable.dataSource = self;
    //隐藏cell的线条
     _changePwdTable.separatorColor = [UIColor clearColor];
    
    [self.view addSubview:_changePwdTable];
    
    self.currentPwdText = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, 260, 44)];
    self.currentPwdText.backgroundColor = [UIColor clearColor];
    self.currentPwdText.secureTextEntry = YES;
    self.currentPwdText.placeholder = MyLocal(@"请输入旧密码");
    self.currentPwdText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.currentPwdText.font = [UIFont systemFontOfSize:20.0];
    self.currentPwdText.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.currentPwdText.delegate = self;
    
    self.changePwdText = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, 260, 44)];
    self.changePwdText.backgroundColor = [UIColor clearColor];
    self.changePwdText.placeholder = MyLocal(@"请输入新密码");
    self.changePwdText.secureTextEntry = YES;
    self.changePwdText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.changePwdText.font = [UIFont systemFontOfSize:20.0];
    self.changePwdText.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.changePwdText.delegate = self;
    
    self.confirmPwdText = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, 260, 44)];
    self.confirmPwdText.backgroundColor = [UIColor clearColor];
    self.confirmPwdText.secureTextEntry = YES;
    self.confirmPwdText.placeholder = MyLocal(@"重新输入新密码");
    self.confirmPwdText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.confirmPwdText.font = [UIFont systemFontOfSize:20.0];
    self.confirmPwdText.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.confirmPwdText.delegate = self;
    
    
    UIButton *changePwdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    changePwdBtn.frame = CGRectMake((VIEW_WIDTH-280)/2, 200, 280, 40);
    changePwdBtn.titleLabel.font = [UIFont systemFontOfSize:20.0];
    [changePwdBtn setBackgroundImage:[[UIImage imageNamed:@"3.png"] scaleToSize:CGSizeMake(280, 50)] forState:UIControlStateNormal];
    [changePwdBtn setTitle:MyLocal(@"修改密码") forState:UIControlStateNormal];
    [changePwdBtn addTarget:self action:@selector(changePwdAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changePwdBtn];
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.color = [UIColor colorWithWhite:0.5 alpha:0.8];
    self.hud.labelText = @"login...";
    [self.view addSubview:_hud];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - target Action

- (void)changePwdAction
{
    if (![_changePwdText.text isEqualToString:_confirmPwdText.text]) {
        UIAlertView *getError = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"两次输入新密码不一致") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil];
        [getError show];
        return;
    }
    
    if (_hud) {
        [_hud show:YES];
    }
    
    NSInteger loginType = [USER_DEFAULT integerForKey:@"LoginType"];
    if (loginType == 0) {
        [self changePassword];
    }else{
        [self changeDevicePassword];
    }
    

}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)keyboardDismiss
{
    [_currentPwdText resignFirstResponder];
    [_changePwdText resignFirstResponder];
    [_confirmPwdText resignFirstResponder];
}

#pragma mark - Webservice Action

- (void)changePassword
{
    NSString *userID = [USER_DEFAULT objectForKey:@"ReturnID"];
    
    WebService *webService = [WebService newWithWebServiceAction:@"ChangePassword" andDelegate:self];
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"UserID" andValue:userID];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"OldPass" andValue:_currentPwdText.text];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"NewPass" andValue:_changePwdText.text];
    NSArray *parameter = @[parameter1, parameter2, parameter3];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"ChangePasswordResult"];
}

-(void)changeDevicePassword{
    
    NSString *deviceID = [USER_DEFAULT objectForKey:@"ReturnID"];
    
    WebService *webService = [WebService newWithWebServiceAction:@"ChangeDevicePassword" andDelegate:self];
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"DeviceID" andValue:deviceID];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"OldPass" andValue:_currentPwdText.text];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"NewPass" andValue:_changePwdText.text];
    NSArray *parameter = @[parameter1, parameter2, parameter3];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"ChangeDevicePasswordResult"];


}

#pragma mark - WebServiceProtocol

- (void)WebServiceGetCompleted:(id)theWebService
{
    if (_hud) {
        [_hud hide:YES];
    }
    
    if ([[theWebService soapResults] length]> 0) {
//        SBJsonParser *parser = [[SBJsonParser alloc] init];
//        NSError *error = nil;
//        id object = [parser objectWithString:[theWebService soapResults] error:&error];
        NSString *str = [theWebService soapResults];
        str = [str stringByReplacingOccurrencesOfString:@"	" withString:@""];
        id object = [str objectFromJSONString];
        if (object) {
            if ([[object objectForKey:@"state"] isEqualToString:@"ok"]) {
                UIAlertView *getError = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"修改密码成功") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil];
                [getError show];
            } else {
                UIAlertView *getError = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"修改密码失败") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil];
                [getError show];
            }
        }
    }
}

- (void)WebServiceGetError:(id)theWebService type:(WebServiceFailureType)failureType
{
    if (_hud) {
        [_hud hide:YES];
    }
    
    
    switch (failureType) {
        case WebServiceTimeOut:
            break;
        case WebServiceInitFailed:
            break;
        case WebServiceConnectFailed:
            break;
        default:
            break;
    }
}

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
        return NO;// 不接收UIButton上的点击事件
    }
    return YES;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46.0f;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tipsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        if (indexPath.row == 0) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10,46-3, 300, 4)];
            imageView.backgroundColor = [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1.0];
            [cell addSubview:imageView];
        }if (indexPath.row==_tipsArray.count-1) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10,46-3, 300, 4)];
            imageView.backgroundColor = [UIColor clearColor];
            [cell addSubview:imageView];
        }
        else{
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10,46-3, 300, 4)];
            imageView.backgroundColor = [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1.0];
            [cell addSubview:imageView];
        }
        cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"textfieldbgimage.png"]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == 0) {
        [cell.contentView addSubview:_currentPwdText];
    } else if (indexPath.row == 1) {
        [cell.contentView addSubview:_changePwdText];
    } else if (indexPath.row == 2) {
        [cell.contentView addSubview:_confirmPwdText];
    }
    
    return cell;
}


@end
