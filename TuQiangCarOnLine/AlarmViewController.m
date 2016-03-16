//
//  AlarmViewController.m
//  NewGps2012
//
//  Created by TR on 13-2-20.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "AlarmViewController.h"
#import "WebServiceParameter.h"
#import "SBJson.h"
#import "AlarmCell.h"

#import "AlarmLocationViewController.h"

#define pageCount 20
#define TimerGetAlarmInterval 600

@interface AlarmViewController ()


@end

@implementation AlarmViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.deviceID = [USER_DEFAULT integerForKey:@"DeviceID"];
        self.pushID   = [[NSString alloc]init];
        self.alarmTypes = @[MyLocal(@"进电子栅栏"), MyLocal(@"出电子栅栏"), MyLocal(@"低电报警"), MyLocal(@"超速报警"), MyLocal(@"SOS报警"), MyLocal(@"断电报警"), MyLocal(@"震动报警"), MyLocal(@"位移报警"), MyLocal(@"离线报警"), MyLocal(@"输入口2"), MyLocal(@"输入口3"), MyLocal(@"进GPS盲区"), MyLocal(@"出GPS盲区"), MyLocal(@"离线报警"), MyLocal(@"开机提醒"), MyLocal(@"关机提醒"), MyLocal(@"第一次定位提醒"), MyLocal(@"GPS天线开路报警"), MyLocal(@"GPS天线短路报警"), MyLocal(@"外电低电报警"), MyLocal(@"外电低电保护报警"), MyLocal(@"拔出报警"), MyLocal(@"换卡报警")];
        self.alarmsForDevice = [[NSMutableArray alloc] init];
        self.pageNumber = 1;
        
        //获取Document文件夹下的数据库文件，没有则创建
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dbPath = [docPath stringByAppendingPathComponent:@"user.db"];
        //获取数据库并打开
        self.DB  = [FMDatabase databaseWithPath:dbPath];
        [_DB open];
        [_DB executeUpdate:@"create table if not exists DeviceAlarm (alarmID integer, deviceID integer, deviceName text, deviceModel text, notificationType integer, geoName text, positionDate text, alarmDate text, fenceNo integer, address text)"];
                
        [self loadTableData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    IOS7;
    if (BYT_IOS7) {
        self.navigationController.navigationBar.barTintColor = mycolor;
        self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor:[UIColor whiteColor]};
         self.alarmTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44-49-20) style:UITableViewStylePlain];
        if (_isPresent) {
            [self initLeftBtn];
            _alarmTable.frame = CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT-64);
        }

    }else {
        self.navigationController.navigationBar.tintColor = mycolor;
        self.alarmTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44-49) style:UITableViewStylePlain];
        if (_isPresent) {
            [self initLeftBtn];
            _alarmTable.frame = CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT-44);
        }

    }
    
    self.alarmTable.delegate = self;
    self.alarmTable.dataSource = self;
    self.alarmTable.backgroundView = nil;
    self.alarmTable.backgroundColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0];
    _alarmTable.separatorColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"line.png"]];
    [self.view addSubview:_alarmTable];
    
    [NSTimer scheduledTimerWithTimeInterval:TimerGetAlarmInterval target:self selector:@selector(refreshAlarms) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNotification:) name:@"refreshAlertList" object:nil];
    [self refreshAlarms];
}
- (void)getNotification:(NSNotification *)not
{
    _pushID = not.userInfo[@"DeviceID"];
    [self refreshAlarms];
}
- (void)backAction
{
    if (![self.navigationController popViewControllerAnimated:YES]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}
- (void)initLeftBtn
{
    self.title = NSLocalizedString(@"车辆报警", nil);
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 11, 21)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
}
-(void)viewDidAppear:(BOOL)animated
{
    [USER_DEFAULT setObject:@"1" forKey:@"isInAlertVC"];
}
- (void)viewDidDisappear:(BOOL)animated{
    [USER_DEFAULT setObject:@"0" forKey:@"isInAlertVC"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _alarmsForDevice.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"CellIdentifier";
    AlarmCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[AlarmCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    if (indexPath.row == _alarmsForDevice.count) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = [UIColor colorWithRed:118/255.0 green:123/255.0 blue:129/255.0 alpha:1];
        if (_isLoadingMore) {
            UIActivityIndicatorView *activiter = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activiter.center = cell.center;
            CGRect frame = activiter.frame;
            frame.origin.x = 110;
            activiter.frame = frame;
            [activiter startAnimating];
            [cell addSubview:activiter];
            cell.textLabel.text = MyLocal(@"加载中...");
        } else {
            if (_alarmsForDevice.count == 0) {
                cell.textLabel.text = MyLocal(@"无报警记录信息");
            } else {
                cell.textLabel.text = MyLocal(@"数据加载完成");
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    NSArray *alarm = _alarmsForDevice[indexPath.row];
    cell.name = alarm[1];
    cell.model = alarm[2];
    NSInteger alarmTypeIndex = [[alarm objectAtIndex:3] integerValue];
    
    if (alarmTypeIndex == 1) {
        int fenceNo = [alarm[7] intValue];
        if (fenceNo == -1) {
            cell.alarmType = @"进电子围栏";
        } else {
            cell.alarmType = [NSString stringWithFormat:@"进%d号电子围栏", fenceNo];
        }
    } else if (alarmTypeIndex == 2) {
        int fenceNo = [alarm[7] intValue];
        if (fenceNo == -1) {
            cell.alarmType = @"出电子围栏";
        } else {
            cell.alarmType = [NSString stringWithFormat:@"出%d号电子围栏", fenceNo];
        }
    } else {
        cell.alarmType = _alarmTypes[alarmTypeIndex-1];
    }
    
    if (alarmTypeIndex == 1 || alarmTypeIndex == 2) {
        cell.geofenceName = alarm[4];
    } else {
        cell.geofenceName = @"";
    }
    cell.deviceDate = alarm[5];
    cell.createDate = alarm[6];
    

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _alarmsForDevice.count) {
        NSArray *alarm = _alarmsForDevice[indexPath.row];
        NSString *geoName = alarm[4];
        if (geoName.length > 0) {
            return 100.0;
        } else {
            return 80.0;
        }
    } else {
        return 44.0;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 如果没有isLoadingMore为YES判断，会一直加载
    if (_alarmsForDevice.count > 0 && _isLoadingMore) {
        if (indexPath.row == _alarmsForDevice.count) {
            _pageNumber++;
            [self getDeviceAlarm];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *alarm = _alarmsForDevice[indexPath.row];
    AlarmLocationViewController *alarmLocationView = [[AlarmLocationViewController alloc] init];
    alarmLocationView.alarmAddress = alarm[8];
    alarmLocationView.alarmID = [NSString stringWithFormat:@"%d", [alarm[0] intValue]];
    [self.navigationController pushViewController:alarmLocationView animated:YES];
}


#pragma mark - WebServiceAction

- (void)getDeviceAlarm
{
    NSString *timeZone = [USER_DEFAULT objectForKey:@"TimeZone"];
    WebService *webService = [WebService newWithWebServiceAction:@"GetWarnList" andDelegate:self];
    NSString *postID =[NSString stringWithFormat:@"%ld", (long)_deviceID];
    if (![self isBlankString:_pushID]) {
        postID = _pushID;
    }
    
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"ID" andValue:postID];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"PageNo" andValue:[NSString stringWithFormat:@"%ld",(long) _pageNumber]];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"PageCount" andValue:[NSString stringWithFormat:@"%d", pageCount]];
    WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"TypeID" andValue:@"1"];
    WebServiceParameter *parameter5 = [WebServiceParameter newWithKey:@"TimeZones" andValue:timeZone];
    NSArray *parameter = @[parameter1, parameter2, parameter3, parameter4, parameter5];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetWarnListResult"];
}

#pragma mark - WebServiceProtocol

- (void)WebServiceGetCompleted:(id)theWebService
{
    if ([[theWebService soapResults] length] > 0) {
//        SBJsonParser *parser = [[SBJsonParser alloc] init];
//        NSError *error = nil;
//        id object = [parser objectWithString:[theWebService soapResults] error:&error];
        NSString *str = [theWebService soapResults];
        str = [str stringByReplacingOccurrencesOfString:@"	" withString:@""];
        id object = [str objectFromJSONString];
        if (object) {
            int state = [[object objectForKey:@"state"] intValue];
            // 根据状态判断是否有数据，0表示有
            if (state == 0) {
                if (_isRefresh) {
                    [_DB executeUpdate:@"drop table if exists DeviceAlarm"];
                    [_DB executeUpdate:@"create table if not exists DeviceAlarm (alarmID integer, deviceID integer, deviceName text, deviceModel text, notificationType integer, geoName text, positionDate text, alarmDate text, fenceNo Integer, address text)"];
                    _isRefresh = NO;
                }
                
                NSArray *alarms = [object objectForKey:@"arr"];
                for (id alarm in alarms) {
                    int alarmID = [[alarm objectForKey:@"id"] intValue];
                    NSString *deviceName = [alarm objectForKey:@"name"];
                    NSString *deviceModel = [alarm objectForKey:@"model"];
                    int notificationType = [[alarm objectForKey:@"notificationType"] intValue];
                    NSString *geoName = [alarm objectForKey:@"geoName"];
                    NSString *positionDate = [alarm objectForKey:@"deviceDate"];
                    NSString *alarmDate = [alarm objectForKey:@"createDate"];
                    int fenceNo = [[alarm objectForKey:@"fenceNo"] intValue];
                    NSString *alarmAddress = [alarm objectForKey:@"address"];
                    [_DB executeUpdate:@"insert into DeviceAlarm (alarmID, deviceID, deviceName, deviceModel, notificationType, geoName, positionDate, alarmDate, fenceNo, address) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [NSNumber numberWithInt:alarmID], [NSNumber numberWithInteger:_deviceID], deviceName, deviceModel, [NSNumber numberWithInt:notificationType], geoName, positionDate, alarmDate, [NSNumber numberWithInt:fenceNo], alarmAddress];
                }
                if (alarms.count < pageCount || alarms == nil) {
                    _isLoadingMore = NO;
                }
                [self loadTableData];
                [_alarmTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
             } else {
                _isLoadingMore = NO;
                [self loadTableData];
                [_alarmTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
        }
    }
}

- (void)WebServiceGetError:(id)theWebService type:(WebServiceFailureType)failureType
{
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

#pragma mark - UnPublic

- (void)loadTableData
{
    [_alarmsForDevice removeAllObjects];
    FMResultSet *resultSet = [_DB executeQuery:@"select * from DeviceAlarm where deviceID = ?", [NSNumber numberWithInteger:_deviceID]];
    while ([resultSet next]) {
        int alarmID = [resultSet intForColumn:@"alarmID"];
        NSString *deviceName = [resultSet stringForColumn:@"deviceName"];
        NSString *deviceModel = [resultSet stringForColumn:@"deviceModel"];
        int notificationType = [resultSet intForColumn:@"notificationType"];
        NSString *geoName = [resultSet stringForColumn:@"geoName"];
        NSString *positionDate = [resultSet stringForColumn:@"positionDate"];
        NSString *alarmDate = [resultSet stringForColumn:@"alarmDate"];
        int fenceNo = [resultSet intForColumn:@"fenceNo"];
        NSString *alarmAddress = [resultSet stringForColumn:@"address"];
        NSArray *aAlarm = @[[NSNumber numberWithInt:alarmID], deviceName, deviceModel, [NSNumber numberWithInt:notificationType], geoName, positionDate, alarmDate, [NSNumber numberWithInt:fenceNo], alarmAddress];
        [_alarmsForDevice addObject:aAlarm];
    }
}
// 刷新数据
- (void)refreshAlarms
{
    _isLoadingMore = YES;
    _isRefresh = YES;
    _pageNumber = 1;
    [self getDeviceAlarm];
}
//判断是否为空字符串
- (BOOL)isBlankString:(NSString *)string{
    
    
    if (string == nil) {
        return YES;
    }
    if (string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}
@end
