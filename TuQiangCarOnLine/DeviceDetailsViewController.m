//
//  DeviceDetailsViewController.m
//  NewGps2012
//
//  Created by TR on 13-2-19.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "DeviceDetailsViewController.h"
#import "WebServiceParameter.h"
#import "SBJson.h"

@interface DeviceDetailsViewController ()
@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) NSMutableArray *subTitles;
@end

@implementation DeviceDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = MyLocal(@"设备详情");
        
        //获取Document文件夹下的数据库文件，没有则创建
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dbPath = [docPath stringByAppendingPathComponent:@"user.db"];
        //获取数据库并打开
        self.DB  = [FMDatabase databaseWithPath:dbPath];
        [_DB open];
        [_DB executeUpdate:@"create table if not exists DeviceDetail (deviceID integer primary key, deviceName text, imei text, validity text, licencePlate text, type text, sim text, contactPerson text, contactTelphone text, address text)"];
        
        self.deviceID = (int)[USER_DEFAULT integerForKey:@"DeviceID"];
        self.theDeviceDetail = [[DeviceDetail alloc] init];
        self.titles = @[MyLocal(@"设备名称"), MyLocal(@"设备IMEI"), MyLocal(@"有效期"), MyLocal(@"车牌号码"), MyLocal(@"设备型号"), MyLocal(@"设备手机卡号"), MyLocal(@"设备联系人"), MyLocal(@"联系人电话")];
        self.subTitles = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", @"", @"", @"", nil];
        
        [self getDeviceDetail];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    IOS7;
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.view.backgroundColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0];
    
    // 返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 11, 21)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    if (BYT_IOS7) {
        self.detailTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT-44-20) style:UITableViewStyleGrouped];
    }else{
        self.detailTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT-44) style:UITableViewStyleGrouped];
    }
    self.detailTable.dataSource = self;
    self.detailTable.delegate = self;
    self.detailTable.backgroundView = nil;
    self.detailTable.backgroundColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0];
    [self.view addSubview:_detailTable];
    
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.color = [UIColor colorWithWhite:0.5 alpha:0.8];
    [_hud show:YES];
    [self.view addSubview:_hud];
    
    [self loadDeviceDetail];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)getDeviceDetail
{
    [_subTitles removeAllObjects];
    
    FMResultSet *resultSet = [_DB executeQuery:@"select * from DeviceDetail where deviceID = ?", [NSNumber numberWithInt:_deviceID]];
    while ([resultSet next]) {
        [_subTitles addObject:[resultSet stringForColumn:@"deviceName"]];
        [_subTitles addObject:[resultSet stringForColumn:@"imei"]];
        [_subTitles addObject:[resultSet stringForColumn:@"validity"]];
        [_subTitles addObject:[resultSet stringForColumn:@"licencePlate"]];
        [_subTitles addObject:[resultSet stringForColumn:@"type"]];
        [_subTitles addObject:[resultSet stringForColumn:@"sim"]];
        [_subTitles addObject:[resultSet stringForColumn:@"contactPerson"]];
        [_subTitles addObject:[resultSet stringForColumn:@"contactTelphone"]];
        [_subTitles addObject:[resultSet stringForColumn:@"address"]];
    }
}

#pragma mark - Target Action

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - WebService Action

- (void)loadDeviceDetail
{
    NSString *timeZone = [USER_DEFAULT objectForKey:@"TimeZone"];
    WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceDetail" andDelegate:self];
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"DeviceID" andValue:[NSString stringWithFormat:@"%d", _deviceID]];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"TimeZones" andValue:timeZone];
    
    NSArray *parameter = @[parameter1, parameter2];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetDeviceDetailResult"];
}

#pragma mark - WebServiceProtocol

- (void)WebServiceGetCompleted:(id)theWebService
{
    if (_hud) {
        [_hud hide:YES];
    }
    
    if ([[theWebService soapResults] length]> 0) {
//        SBJsonParser *parser = [[SBJsonParser alloc]init];
//        NSError *error = nil;
//        id object = [parser objectWithString:[theWebService soapResults] error:&error];
        NSString *str = [theWebService soapResults];
        str = [str stringByReplacingOccurrencesOfString:@"	" withString:@""];
        id object = [str objectFromJSONString];
        if (object) {
            if ([[object objectForKey:@"state"] intValue] == 0) {
                NSString *name = [object objectForKey:@"name"];
                NSString *sn = [object objectForKey:@"sn"];
                NSString *hireExpireTime = [object objectForKey:@"hireExpireTime"];
                NSString *carNum = [object objectForKey:@"carNum"];
                NSString *type = [object objectForKey:@"type"];
                NSString *phone = [object objectForKey:@"phone"];
                NSString *userName = [object objectForKey:@"userName"];
                NSString *cellPhone = [object objectForKey:@"cellPhone"];
                NSString *address = [object objectForKey:@"address"];
                
                [_DB executeUpdate:@"delete from DeviceDetail where deviceID = ?", [NSNumber numberWithInt:_deviceID]];
                [_DB executeUpdate:@"insert into DeviceDetail (deviceID, deviceName, imei, validity, licencePlate, type, sim, contactPerson, contactTelphone, address) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [NSNumber numberWithInt:_deviceID], name, sn, hireExpireTime, carNum, type, phone, userName, cellPhone, address];
                [self getDeviceDetail];
                
                [_detailTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = _titles[indexPath.row];
    if (_subTitles.count != 0) {
        cell.detailTextLabel.text = _subTitles[indexPath.row];
    }
    if (indexPath.row == 8) {
        cell.detailTextLabel.lineBreakMode = NSLineBreakByCharWrapping;
        cell.detailTextLabel.numberOfLines = 0;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_subTitles.count != 0 && indexPath.row == 8) {
        NSString *labelStr = _subTitles[indexPath.row];
        CGSize labelSize = [labelStr sizeWithFont:[UIFont systemFontOfSize:14.0]
                                constrainedToSize:CGSizeMake(200, 2000)
                                    lineBreakMode:NSLineBreakByWordWrapping];
        return labelSize.height+35;
    }
    
    return 44.0;
}

@end
