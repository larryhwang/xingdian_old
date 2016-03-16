//
//  ShockViewController.m
//  途强汽车在线
//
//  Created by apple on 14-8-11.
//  Copyright (c) 2014年 thinkrace. All rights reserved.
//

#import "ShockViewController.h"
#import "RadioButton.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "MBProgressHUD.h"

typedef NS_ENUM(NSInteger, WebServiceType) {
    WebServiceTypeSet = 100,
    WebServiceTypeGetResponse
};

@interface ShockViewController () <WebServiceProtocol, RadioButtonDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UISwitch *commandSwitch;
@property (strong, nonatomic) NSString *alarmtType;

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *startGetResponseTime;
@property (strong, nonatomic) UIAlertView *alertView;

@property (strong, nonatomic) NSString *commandID;
@property (strong, nonatomic) MBProgressHUD *hud;

@end

@implementation ShockViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title =MyLocal(@"震动报警设置");
        self.alarmtType = @"1";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    IOS7;
    
	// 返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 11, 21)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 110, 30)];
    label1.text = MyLocal(@"震动报警开关:");
    label1.font = [UIFont systemFontOfSize:17.0f];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label1];
    
    self.commandSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(150, 50, 70, 30)];
    _commandSwitch.onTintColor = [UIColor blueColor];
    _commandSwitch.on = YES;
    [self.view addSubview:_commandSwitch];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 130, 110, 30)];
    label2.text = MyLocal(@"震动报警方式:");
    label2.font = [UIFont systemFontOfSize:17.0f];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label2];
    
    RadioButton *radioButton1 = [[RadioButton alloc] initWithGroupId:@"shockSet" index:0];
    radioButton1.frame = CGRectMake(20, 164, 22, 22);
    [self.view addSubview:radioButton1];
    UILabel *typeLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(50, 160, 150, 30)];
    typeLabel1.text = MyLocal(@"平台报警");
    typeLabel1.font = [UIFont systemFontOfSize:14.0];
    typeLabel1.backgroundColor = [UIColor clearColor];
    [self.view addSubview:typeLabel1];
    
    RadioButton *radioButton2 = [[RadioButton alloc]initWithGroupId:@"shockSet" index:1];
    radioButton2.frame = CGRectMake(20, 204, 22, 22);
    radioButton2.button.selected = YES;
    [self.view addSubview:radioButton2];
    UILabel *typeLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(50, 200, 150, 30)];
    typeLabel2.text = MyLocal(@"平台报警+短信报警");
    typeLabel2.font = [UIFont systemFontOfSize:14.0];
    typeLabel2.backgroundColor = [UIColor clearColor];
    [self.view addSubview:typeLabel2];
    
    RadioButton *radioButton3 = [[RadioButton alloc]initWithGroupId:@"shockSet" index:2];
    radioButton3.frame = CGRectMake(20, 244, 22, 22);
    [self.view addSubview:radioButton3];
    UILabel *typeLabel3 = [[UILabel alloc]initWithFrame:CGRectMake(50, 240, 250, 30)];
    typeLabel3.text = MyLocal(@"平台报警+短信报警+电话报警");
    typeLabel3.font = [UIFont systemFontOfSize:14.0];
    typeLabel3.backgroundColor = [UIColor clearColor];
    [self.view addSubview:typeLabel3];
    
    [RadioButton addObserverForGroupId:@"shockSet" observer:self];
    
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

- (void)setOverSpeedAlarm
{
    [_hud show:YES];
    
    NSString *deviceID = [USER_DEFAULT objectForKey:@"DeviceID"];
    WebService *webService = [WebService newWithWebServiceAction:@"SendDeviceCommand" andDelegate:self];
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"deviceID" andValue:deviceID];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"Type" andValue:@"20"];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"Param1" andValue:_commandSwitch.on ? @"1" : @"0"];
    WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"Param2" andValue:_alarmtType];
    WebServiceParameter *parameter5 = [WebServiceParameter newWithKey:@"Param3" andValue:@""];
    
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
