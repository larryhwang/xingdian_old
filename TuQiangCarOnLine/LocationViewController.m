//
//  LocationViewController.m
//  途强
//
//  Created by TR on 13-9-27.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "LocationViewController.h"
//#import "rangeAlertView.h"
#import "WebServiceParameter.h"
#import "MBProgressHUD.h"

@interface LocationViewController ()

@property (strong, nonatomic) NSString *deviceID;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) NSArray *images;
@property (strong, nonatomic) NSArray *HImages;

@property (strong, nonatomic) MBProgressHUD *hud;

@property (strong, nonatomic) NSString *commandID;// WebService返回的指令ID,用于调用GetResponse接口判断设备是否成功设置

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *startGetResponseTime;
@property (strong, nonatomic) UIAlertView *alertView;

@end

@implementation LocationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title =MyLocal(@"位移报警设置");
        self.titles = @[MyLocal(@"设置位移报警"),MyLocal(@"关闭位移报警"),MyLocal(@"查询位移报警设置")];
        self.images = @[@"locationSet", @"locationClose", @"locationSearch"];
//        self.HImages = @[@"locationSet-h", @"locationClose-h", @"locationSearch-h"];
        self.deviceID = [USER_DEFAULT objectForKey:@"DeviceID"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    IOS7;
    
	// 返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 11, 21)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    if (BYT_IOS7) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT-44-20) style:UITableViewStylePlain];
    }else{
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT-44) style:UITableViewStylePlain];
    }
    _tableView.dataSource = self;
    _tableView.delegate = self;
    //隐藏cell的线条
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
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
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,60-2, 320, 2)];
    imageView.image = [UIImage imageNamed:@"line.png"];
    [cell addSubview:imageView];
    
    cell.imageView.image = [UIImage imageNamed:_images[indexPath.row]];
    cell.imageView.highlightedImage = [UIImage imageNamed:_HImages[indexPath.row]];
    cell.textLabel.text = _titles[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:18.0];

    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:MyLocal(@"设置位移报警") message:MyLocal(@"提示:半径范围100~1000米") delegate:self cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:MyLocal(@"取消"), nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.delegate = self;
        alert.tag = 1;
        [alert show];

    } else if (indexPath.row == 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"您确定要发送关闭位移报警指令吗?") delegate:self cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:MyLocal(@"取消"), nil];
        alert.delegate = self;
        alert.tag = 2;
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"您确定要发送查询位移报警设置指令吗?") delegate:self cancelButtonTitle:MyLocal(@"确定")otherButtonTitles:MyLocal(@"取消"), nil];
        alert.delegate = self;
        alert.tag = 3;
        [alert show];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _alertView) {
        self.alertView = nil;
    }
    if (buttonIndex == 0) {
        if (alertView.tag == 1) {
            NSString *range = [alertView textFieldAtIndex:0].text;
            if(range.length == 0){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"请填写围栏半径") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
                [alert show];
            }
            if ([range integerValue] > 1000 || [range integerValue] < 100) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"半径有效距离为100~1000") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
                [alert show];
            } else {
                [self issuedSetMoving:range];
            }
        } else if (alertView.tag == 2) {
            // 关闭位移报警
            [self issuedOffMoving];
        } else if (alertView.tag == 3) {
            // 查询位移报警
            [self issuedQueryMoving];
        }
    }
}
#pragma mark - WebService Action
// 设置位移报警
- (void)issuedSetMoving:(NSString *)range
{
    [_hud show:YES];
    WebService *webService = [WebService newWithWebServiceAction:@"MovingSet" andDelegate:self];
    webService.tag = MovingSetWebService;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"deviceID" andValue:_deviceID];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"A" andValue:@"ON"];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"R" andValue:range];
    WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"M" andValue:@"1"];

    webService.webServiceParameter = @[parameter1, parameter2, parameter3, parameter4];
    [webService getWebServiceResult:@"MovingSetResult"];
}

// 关闭位移报警
- (void)issuedOffMoving
{
    [_hud show:YES];
    WebService *webService = [WebService newWithWebServiceAction:@"MovingSetOFF" andDelegate:self];
    webService.tag = MovingOffWebService;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"deviceID" andValue:_deviceID];
    
    webService.webServiceParameter = @[parameter1];
    [webService getWebServiceResult:@"MovingSetOFFResult"];
}

// 查询当前位移报警
- (void)issuedQueryMoving
{
    [_hud show:YES];
    WebService *webService = [WebService newWithWebServiceAction:@"MovingQuery" andDelegate:self];
    webService.tag = MovingQueryWebService;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"deviceID" andValue:_deviceID];
    webService.webServiceParameter = @[parameter1];
    [webService getWebServiceResult:@"MovingQueryResult"];
}

// 根据commandID调用接口判断设备是否设置成功
- (void)getCommandResponse
{
    NSDate *date = [NSDate date];
    if ([date timeIntervalSinceDate:_startGetResponseTime] > 30.0) {
        if (_hud) {
            [_hud hide:YES];
        }
        if (_timer) {
            [_timer invalidate];
            self.timer = nil;
        }
        if (!_alertView) {
            self.alertView = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"设备未返回") delegate:self cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
            [_alertView show];
        }

        return;
    }
    
    WebService *webService = [WebService newWithWebServiceAction:@"GetResponse" andDelegate:self];
    webService.tag = MovingResponseWebService;
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

#pragma mark - WebServiceProtocol

- (void)WebServiceGetCompleted:(id)theWebService
{
    if ([theWebService tag] == MovingResponseWebService) {
        // 如果是查询设备响应
        if ([[theWebService soapResults] length] > 0) {
            if (_hud) {
                [_hud hide:YES];
            }
            if (_timer) {
                [_timer invalidate];
                self.timer = nil;
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
            if (_hud) {
                [_hud hide:YES];
            }
            // 设备不在线
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:MyLocal(@"设置失败") message:MyLocal(@"设备不在线") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
            [alert show];
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

@end
