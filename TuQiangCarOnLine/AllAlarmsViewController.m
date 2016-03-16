//
//  AllAlarmsViewController.m
//  NewGps2012
//
//  Created by TR on 13-3-22.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "AllAlarmsViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "SBJson.h"
#import "AlarmCell.h"

#import "AlarmLocationViewController.h"

#define pageCount 30
#define TimerGetAlarmsInterval 600

@interface AllAlarmsViewController ()

@end

@implementation AllAlarmsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = MyLocal(@"报警列表");
        
        self.alarmsArray = [[NSMutableArray alloc] init];
        self.alarmTypes = @[MyLocal(@"进电子栅栏"), MyLocal(@"出电子栅栏"), MyLocal(@"低电报警"), MyLocal(@"超速报警"), MyLocal(@"SOS报警"), MyLocal(@"断电报警"), MyLocal(@"震动报警"), MyLocal(@"位移报警"), MyLocal(@"离线报警"), MyLocal(@"输入口2"), MyLocal(@"输入口3"), MyLocal(@"进GPS盲区"), MyLocal(@"出GPS盲区"), MyLocal(@"离线报警"), MyLocal(@"开机提醒"), MyLocal(@"关机提醒"), MyLocal(@"第一次定位提醒"), MyLocal(@"GPS天线开路报警"), MyLocal(@"GPS天线短路报警"), MyLocal(@"外电低电报警"), MyLocal(@"外电低电保护报警"), MyLocal(@"拔出报警"), MyLocal(@"换卡报警")];
        self.pageNumber = 1;
        
        self.keyID = [[USER_DEFAULT objectForKey:@"ReturnID"] stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)[USER_DEFAULT integerForKey:@"LoginType"]]];

        //获取Document文件夹下的数据库文件，没有则创建
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dbPath = [docPath stringByAppendingPathComponent:@"user.db"];
        //获取数据库并打开
        self.DB  = [FMDatabase databaseWithPath:dbPath];
        [_DB open];
        [_DB executeUpdate:@"create table if not exists AllAlarms (keyID text, alarmID integer, deviceName text, deviceModel text, notificationType integer, geoName text, positionDate, alarmDate text, fenceNo integer, address text)"];

        [self loadTableData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    IOS7;
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47, 36)];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"6.png"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(refreshAlarms) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    if (BYT_IOS7) {
        self.alarmsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44-49-20) style:UITableViewStylePlain];
    }else{
        self.alarmsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-49-44) style:UITableViewStylePlain];
    }
    //隐藏cell的线条
    _alarmsTable.separatorColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"line.png"]];
    
    self.alarmsTable.delegate = self;
    self.alarmsTable.dataSource = self;
    self.alarmsTable.backgroundView = nil;
    self.alarmsTable.backgroundColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0];
    
    [self.view addSubview:_alarmsTable];
    
    [NSTimer scheduledTimerWithTimeInterval:TimerGetAlarmsInterval target:self selector:@selector(refreshAlarms) userInfo:nil repeats:YES];
    [self refreshAlarms];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    //修改导航条上的字体为白色
    if (BYT_IOS7) {
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor, nil]];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    
    [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"Notification_Type"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _alarmsArray.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"CellIdentifier";
    AlarmCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[AlarmCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    if (indexPath.row == _alarmsArray.count) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = [UIColor colorWithRed:118/255.0 green:123/255.0 blue:129/255.0 alpha:1];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
            if (_alarmsArray.count == 0) {
                cell.textLabel.text = MyLocal(@"无报警记录信息");
                
            } else {
                cell.textLabel.text = MyLocal(@"数据加载完成");
            }
        }
        return cell;
    }
    NSArray *alarm = _alarmsArray[indexPath.row];
    cell.name = alarm[1];
    cell.model = alarm[2];
    
    NSInteger alarmTypeIndex = [[alarm objectAtIndex:3] integerValue];
    NSLog(@"alarmTypeIndex = %@",[NSNumber numberWithInteger:alarmTypeIndex]);
    if (alarmTypeIndex == 1) {
        int fenceNo = [alarm[7] intValue];
        if (fenceNo == -1) {
            cell.alarmType =MyLocal(@"进电子围栏");
        } else {
            cell.alarmType = [NSString stringWithFormat:MyLocal(@"进%d号电子围栏"), fenceNo];
        }
    } else if (alarmTypeIndex == 2) {
        int fenceNo = [alarm[7] intValue];
        if (fenceNo == -1) {
            cell.alarmType = MyLocal(@"出电子围栏");
        } else {
            cell.alarmType = [NSString stringWithFormat:MyLocal(@"出%d号电子围栏"), fenceNo];
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _alarmsArray.count) {
        NSArray *alarm = _alarmsArray[indexPath.row];
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
    if (_alarmsArray.count > 0 && _isLoadingMore) {
        if (indexPath.row == _alarmsArray.count) {
            _pageNumber++;
            [self getAlarms];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != _alarmsArray.count){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSArray *alarm = _alarmsArray[indexPath.row];
        AlarmLocationViewController *alarmLocationView = [[AlarmLocationViewController alloc] init];
        alarmLocationView.alarmAddress = alarm[8];
        alarmLocationView.alarmID = [NSString stringWithFormat:@"%d", [alarm[0] intValue]];
        [self.navigationController pushViewController:alarmLocationView animated:YES];
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MyLocal(@"删除");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_alarmsArray removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - WebServiceAction

- (void)getAlarms
{
    NSString *timeZone = [USER_DEFAULT objectForKey:@"TimeZone"];
    WebService *webService = [WebService newWithWebServiceAction:@"GetWarnList" andDelegate:self];
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"ID" andValue:[USER_DEFAULT objectForKey:@"ReturnID"]];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"PageNo" andValue:[NSString stringWithFormat:@"%ld",(long) _pageNumber]];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"PageCount" andValue:[NSString stringWithFormat:@"%d", pageCount]];
    WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"TypeID" andValue:[NSString stringWithFormat:@"%ld", (long)[USER_DEFAULT integerForKey:@"LoginType"]]];
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
            // 根据状态判断登录是否成功，0表示成功
            if (state == 0) {
                if (_isRefresh) {
                    [_DB executeUpdate:@"drop table if exists AllAlarms"];
                    [_DB executeUpdate:@"create table if not exists AllAlarms (keyID text, alarmID integer, deviceName text, deviceModel text, notificationType integer, geoName text, positionDate, alarmDate text, fenceNo integer, address text)"];
                    _isRefresh = NO;
                }
                NSArray *alarms = [object objectForKey:@"arr"];
                for (id alarm in alarms) {
                    int alarmID = [[alarm objectForKey:@"id"] intValue];
                    NSString *deviceName = [alarm objectForKey:@"name"];
                    NSString *deviceModel = [alarm objectForKey:@"model"];
                    int notificationType = [[alarm objectForKey:@"notificationType"] intValue];
                    if (notificationType == -1) {
                        continue;
                    }
                    NSString *geoName = [alarm objectForKey:@"geoName"];
                    NSString *positionDate = [alarm objectForKey:@"deviceDate"];
                    NSString *alarmDate = [alarm objectForKey:@"createDate"];
                    int fenceNo = [[alarm objectForKey:@"fenceNo"] intValue];
                    NSString *alarmAddress = [alarm objectForKey:@"address"];
                    
                    [_DB executeUpdate:@"insert into AllAlarms (keyID, alarmID, deviceName, deviceModel, notificationType, geoName, positionDate, alarmDate, fenceNo, address) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _keyID, [NSNumber numberWithInt:alarmID], deviceName, deviceModel, [NSNumber numberWithInt:notificationType], geoName, positionDate, alarmDate, [NSNumber numberWithInt:fenceNo], alarmAddress];
                }
                if (alarms.count < pageCount || alarms == nil) {
                    _isLoadingMore = NO;
                }
                [self loadTableData];
                
                
                [_alarmsTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            } else {
                _isLoadingMore = NO;
                [self loadTableData];
                [_alarmsTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
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
    [_alarmsArray removeAllObjects];
    FMResultSet *resultSet = [_DB executeQuery:@"select * from AllAlarms where keyID = ?", _keyID];
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
        [_alarmsArray addObject:aAlarm];
    }
}
// 刷新数据
- (void)refreshAlarms
{
    _isLoadingMore = YES;
    _isRefresh = YES;
    _pageNumber = 1;
    [self getAlarms];
}

@end
