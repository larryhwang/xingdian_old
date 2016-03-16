//
//  OverspeedViewController.m
//  途强汽车在线
//
//  Created by apple on 14-8-11.
//  Copyright (c) 2014年 thinkrace. All rights reserved.
//

#import "OverspeedViewController.h"
#import "RadioButton.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "MBProgressHUD.h"

typedef NS_ENUM(NSInteger, WebServiceType) {
    WebServiceTypeSet = 100,
    WebServiceTypeGetResponse
};

@interface OverspeedViewController () <WebServiceProtocol, RadioButtonDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UISwitch *commandSwitch;
@property (strong, nonatomic) UITextField *timeTextField;
@property (strong, nonatomic) UITextField *speedTextField;
@property (strong, nonatomic) NSString *alarmtType;

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *startGetResponseTime;
@property (strong, nonatomic) UIAlertView *alertView;

@property (strong, nonatomic) NSString *commandID;
@property (strong, nonatomic) MBProgressHUD *hud;

@end

@implementation OverspeedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title =MyLocal(@"超速报警设置");
        self.alarmtType = @"0";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDismiss)];
    [self.view addGestureRecognizer:tap];
    
    IOS7;
    
	// 返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 11, 21)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 75, 30)];
    label1.text = MyLocal(@"报警开关:");
    label1.font = [UIFont systemFontOfSize:17.0f];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label1];
    
    self.commandSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(120, 50, 70, 30)];
    _commandSwitch.onTintColor = [UIColor blueColor];
    [self.view addSubview:_commandSwitch];
    
    UILabel *paramaLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 75, 30)];
    paramaLabel.text = MyLocal(@"参数设置:");
    paramaLabel.font = [UIFont systemFontOfSize:17.0f];
    paramaLabel.textAlignment = NSTextAlignmentCenter;
    paramaLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:paramaLabel];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 130, 280, 30)];
    timeLabel.text = MyLocal(@"车辆超速时间超过               秒");
    timeLabel.font = [UIFont systemFontOfSize:17.0f];
    timeLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:timeLabel];
    
    self.timeTextField = [[UITextField alloc] initWithFrame:CGRectMake(157, 130, 70, 25)];
    _timeTextField.backgroundColor = [UIColor clearColor];
    _timeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _timeTextField.font = [UIFont systemFontOfSize:17.0];
    _timeTextField.keyboardType = UIKeyboardTypeNumberPad;
    _timeTextField.textAlignment = NSTextAlignmentCenter;
    _timeTextField.placeholder = @"5~600";
    [self.view addSubview:_timeTextField];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(157, 155, 70, 1)];
    line1.backgroundColor = [UIColor blackColor];
    [self.view addSubview:line1];
    
    UILabel *speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 160, 280, 30)];
    speedLabel.text = MyLocal(@"车辆行驶速度超过               km/h");
    speedLabel.font = [UIFont systemFontOfSize:17.0f];
    speedLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:speedLabel];
    
    self.speedTextField = [[UITextField alloc] initWithFrame:CGRectMake(157, 160, 70, 25)];
    _speedTextField.backgroundColor = [UIColor clearColor];
    _speedTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _speedTextField.font = [UIFont systemFontOfSize:17.0];
    _speedTextField.keyboardType = UIKeyboardTypeNumberPad;
    _speedTextField.textAlignment = NSTextAlignmentCenter;
    _speedTextField.placeholder = @"1~255";
    [self.view addSubview:_speedTextField];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(157, 185, 70, 1)];
    line2.backgroundColor = [UIColor blackColor];
    [self.view addSubview:line2];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, 75, 30)];
    label2.text = MyLocal(@"报警方式:");
    label2.font = [UIFont systemFontOfSize:17.0f];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label2];
    
    RadioButton *radioButton1 = [[RadioButton alloc] initWithGroupId:@"overspeedSet" index:0];
    radioButton1.frame = CGRectMake(20, 234, 22, 22);
    [self.view addSubview:radioButton1];
    UILabel *typeLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(50, 230, 100, 30)];
    typeLabel1.text = MyLocal(@"平台报警");
    typeLabel1.font = [UIFont systemFontOfSize:14.0];
    typeLabel1.backgroundColor = [UIColor clearColor];
    [self.view addSubview:typeLabel1];
    
    RadioButton *radioButton2 = [[RadioButton alloc]initWithGroupId:@"overspeedSet" index:1];
    radioButton2.frame = CGRectMake(20, 264, 22, 22);
    radioButton2.button.selected = YES;
    [self.view addSubview:radioButton2];
    UILabel *typeLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(50, 260, 160, 30)];
    typeLabel2.text = MyLocal(@"平台报警+短信报警");
    typeLabel2.font = [UIFont systemFontOfSize:14.0];
    typeLabel2.backgroundColor = [UIColor clearColor];
    [self.view addSubview:typeLabel2];
    [RadioButton addObserverForGroupId:@"overspeedSet" observer:self];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame = CGRectMake(20, 320, 120, 44);
    [button1 setBackgroundImage:[UIImage imageNamed:@"3.png"] forState:UIControlStateNormal];
    [button1 setTitle:MyLocal(@"确定") forState:UIControlStateNormal];
    button1.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [button1 addTarget:self action:@selector(setOverSpeedAlarm) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(180, 320, 120, 44);
    [button2 setBackgroundImage:[UIImage imageNamed:@"3.png"] forState:UIControlStateNormal];
    [button2 setTitle:MyLocal(@"取消") forState:UIControlStateNormal];
    button2.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [button2 addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    _hud.color = [UIColor colorWithWhite:0.5 alpha:0.8];
    [self.view addSubview:_hud];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Target Actions

- (void)back
{
    if (_timer) {
        [_timer invalidate];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)keyboardDismiss
{
    [_timeTextField resignFirstResponder];
    [_speedTextField resignFirstResponder];
}

- (void)setOverSpeedAlarm
{
    if (_commandSwitch.on) {
        if (_timeTextField.text.length == 0 || _speedTextField.text.length == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"请输入超速时间和行驶速度") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    
    [_hud show:YES];
    
    NSString *str = [NSString stringWithFormat:@"%@,%@",_timeTextField.text ? _timeTextField.text : @"",_speedTextField.text ? _speedTextField.text : @""];
    
    NSString *deviceID = [USER_DEFAULT objectForKey:@"DeviceID"];
    WebService *webService = [WebService newWithWebServiceAction:@"SendDeviceCommand" andDelegate:self];
    webService.tag = WebServiceTypeSet;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"deviceID" andValue:deviceID];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"Type" andValue:@"14"];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"Param1" andValue:_commandSwitch.on ? @"1" : @"0"];
    WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"Param2" andValue:_alarmtType];
    WebServiceParameter *parameter5 = [WebServiceParameter newWithKey:@"Param3" andValue:str];
//    WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"Param2" andValue:_timeTextField.text ? _timeTextField.text : @""];
//    WebServiceParameter *parameter5 = [WebServiceParameter newWithKey:@"Param3" andValue:_speedTextField.text ? _speedTextField.text : @""];
//    WebServiceParameter *parameter6 = [WebServiceParameter newWithKey:@"Param4" andValue:_alarmtType];
//    WebServiceParameter *parameter7 = [WebServiceParameter newWithKey:@"Param5" andValue:@""];
    
    webService.webServiceParameter = @[parameter1, parameter2, parameter3, parameter4, parameter5];
    [webService getWebServiceResult:@"SendDeviceCommandResult"];
}

#pragma mark - 单选按钮 代理方法

- (void)radioButtonSelectedAtIndex:(NSUInteger)index inGroup:(NSString*)groupId
{
    self.alarmtType = [NSString stringWithFormat:@"%ld", (long)index];
}

#pragma mark - WebServiceProtocol

- (void)getCommandResponse
{
    NSDate *date = [NSDate date];
    if ([date timeIntervalSinceDate:_startGetResponseTime] > 30.0) {
        if (_hud) {
            [_hud hide:YES];
        }
        if (_timer) {
            [_timer invalidate];
        }
        
        if (!_alertView) {
            self.alertView = [[UIAlertView alloc] initWithTitle:nil message:@"设备未返回" delegate:self cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
            [_alertView show];
        }
        
        return;
    }
    
    WebService *webService = [WebService newWithWebServiceAction:@"GetResponse" andDelegate:self];
    webService.tag = WebServiceTypeGetResponse;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"CommandID" andValue:_commandID];
    
    webService.webServiceParameter = @[parameter1];
    [webService getWebServiceResult:@"GetResponseResult"];
}

// 定时30秒调用6次GetResponse方法
- (void)timerGetCommandResponse
{
    if (_timer) {
        [_timer invalidate];
        self.timer = nil;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(getCommandResponse) userInfo:nil repeats:YES];
}

- (void)WebServiceGetCompleted:(id)theWebService
{
    if ([theWebService tag] == WebServiceTypeGetResponse) {
        // 如果是查询设备响应，
        if ([[theWebService soapResults] length] > 0) {
            if (_hud) {
                [_hud hide:YES];
            }
            if (_timer) {
                [_timer invalidate];
            }
            
            // 设备成功返回，表示设置成功或者错误
            if (!_alertView) {
                self.alertView = [[UIAlertView alloc] initWithTitle:nil message:[theWebService soapResults] delegate:self cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
                [_alertView show];
            }
        } else {
            return;
        }
    } else {
        if ([[theWebService soapResults] isEqualToString:@"1001"]) {
            // 设备不在线
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:MyLocal(@"设置失败") message:MyLocal(@"设备不在线") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
            [alert show];
            
            if (_hud) {
                [_hud hide:YES];
            }
        } else if ([[theWebService soapResults] isEqualToString:@"1002"]) {
            if (_hud) {
                [_hud hide:YES];
            }
            // 设备ID无效
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:MyLocal(@"设置失败") message:MyLocal(@"设备ID无效") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
            [alert show];
        } else if ([[theWebService soapResults] isEqualToString:@"2001"]) {
            if (_hud) {
                [_hud hide:YES];
            }
            // 设备无返回
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:MyLocal(@"设置失败") message:MyLocal(@"设备无返回") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
            [alert show];
        } else {
            // 接口返回的查询码，定时查询GetResponse方法查看设备是否设置成功
            self.commandID = [NSString stringWithFormat:@"%@", [theWebService soapResults]];
            self.startGetResponseTime = [NSDate date];
            [self timerGetCommandResponse];
        }
    }
}

- (void)WebServiceGetError:(id)theWebService type:(WebServiceFailureType)failureType
{
    if (_hud) {
        [_hud hide:YES];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _alertView) {
        self.alertView = nil;
    }
}

@end
