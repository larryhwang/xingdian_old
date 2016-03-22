//
//  HomeViewController.m
//  NewGps2012
//
//  Created by TR on 13-1-29.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "HomeViewController.h"
#import "DeviceList.h"
#import "DeviceInfoCell.h"
#import "SearchViewController.h"
#import "SelectDeviceViewController.h"
#import "DeviceDetailsViewController.h"
#import "WebServiceParameter.h"
#import "SBJson.h"
#import "FMDatabaseAdditions.h"
#import "UIImage+Scale.h"
#import "MoreViewController.h"

#define TimerGetStatusInterval 20
#define TimerGetDetailInterval 3600
#define WebServiceTag_GetDeviceStatus 1
#define WebServiceTag_GetDeviceDetail 2
#define WebServiceTag_GetGroup      3

@interface HomeViewController ()
@property (strong, nonatomic) UIButton *rightButton;
@end

@implementation HomeViewController{
    NSInteger *sect;
    NSTimer *Atimer;
}

#pragma mark - initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = MyLocal(@"车辆列表");
        
        //获取Document文件夹下的数据库文件，没有则创建
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dbPath = [docPath stringByAppendingPathComponent:@"user.db"];
        //获取数据库并打开
        self.DB  = [FMDatabase databaseWithPath:dbPath];
        if (![_DB open]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:MyLocal(@"数据库打开失败") message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [alert show];
        }
        
        self.groups = [[NSMutableArray alloc] init];
        self.allDevices = [[NSMutableArray alloc] init];// 所有设备
        self.onlineDevices = [[NSMutableArray alloc] init];// 在线设备
        self.offlineDevices = [[NSMutableArray alloc] init];// 离线设备
        self.tableDataLists = _allDeviceLists;
        
//        [self loadTabelViewData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    IOS7;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //右/搜索按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 38.5, 28)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"5.png"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    
    
    //左/更多按钮
    UIButton *more = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 22)];
    [more setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [more addTarget:self action:@selector(showMoreVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:more];
    
    //右/刷新按钮
    self.rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 38.5, 28)];
    [_rightButton setBackgroundImage:[UIImage imageNamed:@"6.png"] forState:UIControlStateNormal];
    [_rightButton addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:_rightButton],[[UIBarButtonItem alloc]initWithCustomView:leftButton]];
    
    UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    view2.backgroundColor = [UIColor colorWithRed:62/255.0f green:62/255.0f blue:62/255.0f alpha:1.0f];
    [self.view addSubview:view2];
    
    self.all = [UIButton buttonWithType:UIButtonTypeCustom];
    self.all.frame = CGRectMake(0, 0, 105, 44);
    self.all.showsTouchWhenHighlighted = YES;
    [_all setBackgroundImage:[UIImage imageNamed:@"l-1.png"] forState:UIControlStateNormal];
    [_all setBackgroundImage:[UIImage imageNamed:@"l-1.png"] forState:UIControlStateSelected];
    [_all.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
    //[_all setTitleColor:[UIColor colorWithRed:33/255.0f green:103/255.0f blue:184/255.0f alpha:1.0f] forState:UIControlStateSelected];
    [_all setTitleColor:mycolor forState:UIControlStateSelected];
    [_all setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_all setTitle:[NSString stringWithFormat:MyLocal(@"全部 %d"), _allDevices.count] forState:UIControlStateNormal];
    [_all addTarget:self action:@selector(allButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [view2 addSubview:_all];
    
    UIImageView *line1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"l-2.png"]];
    line1.frame = CGRectMake(105, 0, 2, 44);
    [view2 addSubview:line1];
    
    self.online = [UIButton buttonWithType:UIButtonTypeCustom];
    self.online.frame = CGRectMake(107, 0, 105, 44);
    self.online.showsTouchWhenHighlighted = YES;
    [_online setBackgroundImage:[UIImage imageNamed:@"l-1.png"] forState:UIControlStateNormal];
    [_online setBackgroundImage:[UIImage imageNamed:@"l-1.png"] forState:UIControlStateSelected];
    [_online.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
//    [_online setTitleColor:[UIColor colorWithRed:33/255.0f green:103/255.0f blue:184/255.0f alpha:1.0f] forState:UIControlStateSelected];
    [_online setTitleColor:mycolor forState:UIControlStateSelected];
    [_online setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_online setTitle:[NSString stringWithFormat:MyLocal(@"在线 %d"), _onlineDevices.count] forState:UIControlStateNormal];
    [_online addTarget:self action:@selector(onlineButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [view2 addSubview:_online];
    
    UIImageView *line2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"l-2.png"]];
    line2.frame = CGRectMake(212, 0, 2, 44);
    [view2 addSubview:line2];
    
    self.offline = [UIButton buttonWithType:UIButtonTypeCustom];
    self.offline.frame = CGRectMake(214, 0, 106, 44);
    self.offline.showsTouchWhenHighlighted = YES;
    [_offline setBackgroundImage:[UIImage imageNamed:@"l-1.png"] forState:UIControlStateNormal];
    [_offline setBackgroundImage:[UIImage imageNamed:@"l-1.png"] forState:UIControlStateSelected];
    [_offline.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
//    [_offline setTitleColor:[UIColor colorWithRed:33/255.0f green:103/255.0f blue:184/255.0f alpha:1.0f] forState:UIControlStateSelected];
    [_offline setTitleColor:mycolor forState:UIControlStateSelected];
    [_offline setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_offline setTitle:[NSString stringWithFormat:MyLocal(@"离线 %d"), _offlineDevices.count] forState:UIControlStateNormal];
    [_offline addTarget:self action:@selector(offlineButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [view2 addSubview:_offline];
//    self.naviView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 42, 106, 2)];
//    self.naviView.image = [[UIImage imageNamed:@"d.png"] scaleToSize:CGSizeMake(106, 2)];
//    [self.view addSubview:_naviView];
    
    if (BYT_IOS7) {
        self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-49-44-44-20)];
    }else{
        self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-49-44-44)];
    }
    self.table.delegate = self;
    self.table.dataSource = self;
    //隐藏cell的线条
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.view addSubview:_table];
    
    [self allButtonAction];
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.color = [UIColor colorWithWhite:0.5 alpha:0.8];
    [self.view addSubview:_hud];
    
//    [self sectionHeaderView:nil sectionOpened:0];
    
//    [NSTimer scheduledTimerWithTimeInterval:TimerGetStatusInterval target:self selector:@selector(getDeviceStatus) userInfo:nil repeats:YES];
    
    
    if (_hud) {
        [_hud show:YES];
    }
    
    [_rightButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (Atimer){
        [Atimer invalidate];
        Atimer = nil;
    }
   Atimer =  [NSTimer scheduledTimerWithTimeInterval:TimerGetDetailInterval/60 target:self selector:@selector(refreshAction:) userInfo:nil repeats:YES];//修改导航条上的字体为白色
    if (BYT_IOS7) {
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor, nil]];
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    //获取Document文件夹下的数据库文件，没有则创建
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingPathComponent:@"user.db"];
    //获取数据库并打开
    self.DB  = [FMDatabase databaseWithPath:dbPath];
    if (![_DB open]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:MyLocal(@"数据库打开失败") message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alert show];
    }
}
-(void)viewDidDisappear:(BOOL)animated
{
    [Atimer invalidate];
    Atimer = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// tableView所需要的数据
#pragma mark - TabelViewData

- (void)loadTabelViewData
{
    [_groups removeAllObjects];
    
    FMResultSet *resultSet = [_DB executeQuery:@"select * from DeviceGroup"];
    while ([resultSet next]) {
        int groupID = [resultSet intForColumn:@"groupID"];
        NSString *groupName = [resultSet stringForColumn:@"groupName"];
        [_groups addObject:@[[NSNumber numberWithInt:groupID], groupName]];
    }
    
    [_allDevices removeAllObjects];
    [_onlineDevices removeAllObjects];
    [_offlineDevices removeAllObjects];
    resultSet = [_DB executeQuery:@"select * from Device"];
    while ([resultSet next]) {
        Device *aDevice = [[Device alloc] init];
        aDevice.deviceID = [resultSet intForColumn:@"deviceID"];
        aDevice.deviceName = [resultSet stringForColumn:@"deviceName"];
        aDevice.groupID = [resultSet intForColumn:@"groupID"];
        aDevice.licencePlate = [resultSet stringForColumn:@"licencePlate"];
        aDevice.status = [resultSet intForColumn:@"status"];
        aDevice.icon = [resultSet stringForColumn:@"icon"];
        aDevice.latitude = [resultSet stringForColumn:@"latitude"];
        aDevice.longitude = [resultSet stringForColumn:@"longitude"];
        aDevice.acc = [resultSet intForColumn:@"acc"];
        aDevice.power = [resultSet intForColumn:@"power"];
        aDevice.isShowAcc = [resultSet intForColumn:@"isShowAcc"];
        aDevice.type = [resultSet stringForColumn:@"type"];
        
        [_allDevices addObject:aDevice];
        if (aDevice.status == 1 || aDevice.status == 2) {
            [_onlineDevices addObject:aDevice];
        } else {
            [_offlineDevices addObject:aDevice];
        }
    }
    
    self.allDeviceLists = [self grouping:_allDevices];
    self.onlineDeviceLists = [self grouping:_onlineDevices];
    self.offlineDeviceLists = [self grouping:_offlineDevices];
    
    if (_all.selected) {
        self.tableDataLists = _allDeviceLists;
    } else if (_online.selected) {
        self.tableDataLists = _onlineDeviceLists;
    } else if (_offline.selected) {
        self.tableDataLists = _offlineDeviceLists;
    }
}

- (NSMutableArray *)grouping:(NSMutableArray *)devices
{
    NSMutableArray *tableData = [[NSMutableArray alloc] init];
    // 当为IMEI登录时，只有一个默认组（不包含groupID）
    if ([USER_DEFAULT integerForKey:@"LoginType"] == 1) {
        DeviceGroup *list = [[DeviceGroup alloc] init];
        list.groupName = MyLocal(@"默认组");
        list.devicesByGroup = [devices mutableCopy];
        [tableData addObject:list];
    } else {
        //默认组
        DeviceGroup *list = [[DeviceGroup alloc] init];
        list.groupName = MyLocal(@"默认组");
        list.devicesByGroup = [[NSMutableArray alloc] init];
        for (Device *aDevice in devices) {
            if (aDevice.groupID <= 0) {
                [list.devicesByGroup addObject:aDevice];
            }
        }
        [tableData addObject:list];
        
        // 其他分组
        for (int i = 0; i < _groups.count; i++) {
            DeviceGroup *list = [[DeviceGroup alloc] init];
            list.groupID = [[[_groups objectAtIndex:i] objectAtIndex:0] intValue];// 分组ID
            list.groupName = [[_groups objectAtIndex:i] objectAtIndex:1];// 分组名
            list.devicesByGroup = [[NSMutableArray alloc] init];
            for (Device *aDevice in devices) {
                if (aDevice.groupID == list.groupID) {
                    [list.devicesByGroup addObject:aDevice];
                }
            }
            [tableData addObject:list];// 添加一个非默认分组下的所有设备
        }
    }
    
    return tableData;
}

// tableView的代理方法
#pragma mark - TableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 53.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_tableDataLists.count > 0) {
        DeviceGroup *devices = _tableDataLists[section];
        
        CustomHeaderView *header = [[CustomHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)
                                                                     title:[NSString stringWithFormat:@"%@%lu", devices.groupName, (unsigned long)devices.devicesByGroup.count]
                                                                   section:section
                                                                  unfolded:devices.isUnfolded];

      
        header.delegate = self;
        
        return header;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DeviceGroup *list = _tableDataLists[indexPath.section];
    Device *theDevice = list.devicesByGroup[indexPath.row];
    int deviceID = theDevice.deviceID;
    NSString *deviceName = theDevice.deviceName;
    NSString *licencePlate = theDevice.licencePlate;
    NSString *carIcon = theDevice.icon;
    if (theDevice.status == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"车辆未启用") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if (theDevice.status == 4) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"车辆已欠费") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if (theDevice.status == 1 || theDevice.status == 2) {
        carIcon = [NSString stringWithFormat:@"car%@", carIcon];
    } else {
        carIcon = [NSString stringWithFormat:@"offline%@", carIcon];
    }
    int power = theDevice.power;
    int isShowAcc = theDevice.isShowAcc;
    NSString *type = theDevice.type;
    
    [USER_DEFAULT setInteger:deviceID forKey:@"DeviceID"];
    [USER_DEFAULT setObject:deviceName forKey:@"DeviceName"];
    [USER_DEFAULT setObject:licencePlate forKey:@"LicencePlate"];
    [USER_DEFAULT setObject:carIcon forKey:@"CarAlarmIcon"];
    [USER_DEFAULT setInteger:power forKey:@"Power"];
    [USER_DEFAULT setInteger:isShowAcc forKey:@"IsShowAcc"];
    [USER_DEFAULT setObject:type forKey:@"Type"];

    SelectDeviceViewController *deviceViewController = [[SelectDeviceViewController alloc] init];
    deviceViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:deviceViewController animated:YES];
}
// tableView的数据源
#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _tableDataLists.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_tableDataLists.count > 0) {
        DeviceGroup *devices = _tableDataLists[section];
        if (devices.isUnfolded) {
            sect = section;
            return devices.devicesByGroup.count;
        } else {
            return 0;
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *customIdentifier = @"CustomCell";
    DeviceInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:customIdentifier];
    if (cell == nil) {
        cell = [[DeviceInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:customIdentifier];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,53-2, 320, 2)];
        imageView.image = [UIImage imageNamed:@"line.png"];
        [cell addSubview:imageView];
    }
    
    if (_tableDataLists.count > 0) {
        DeviceGroup *devices = _tableDataLists[indexPath.section];
        Device *aDevice = [devices.devicesByGroup objectAtIndex:indexPath.row];
        switch (aDevice.status) {
            case 0:
                cell.statusLabel.text = MyLocal(@"未启用");
                //aDevice.icon  offline_23_45
                if ([aDevice.icon intValue]==23) {
                    //灰色摩托车
                    cell.deviceImage.image = [UIImage imageNamed:@"TRCOnline_2-22.png"];
                }else{
                    //灰色汽车
                    cell.deviceImage.image = [UIImage imageNamed:@"TRCOnline_2-9.png"];
                }

                break;
            case 1:
                //aDevice.icon  car_23_90
                cell.statusLabel.text = MyLocal(@"运动");
                if ([aDevice.icon intValue]==23) {
                    //绿色摩托车
                    cell.deviceImage.image = [UIImage imageNamed:@"TRCOnline_2-21.png"];
                }else{
                    //绿色汽车
                    cell.deviceImage.image = [UIImage imageNamed:@"TRCOnline_2-8.png"];
                }
                break;
            case 2:
                cell.statusLabel.text = MyLocal(@"静止");
                if ([aDevice.icon intValue]==23) {
                    //橙色摩托车
                    cell.deviceImage.image = [UIImage imageNamed:@"TRCOnline_2-20.png"];
                }else{
                    //橙色汽车
                    cell.deviceImage.image = [UIImage imageNamed:@"TRCOnline_2-7.png"];
                }
                break;
            case 3:
                cell.statusLabel.text = MyLocal(@"离线");
                NSLog(@"ddddd%@",aDevice.icon);
 
                if ([aDevice.icon intValue]==23) {
                    //灰色摩托车
                    cell.deviceImage.image = [UIImage imageNamed:@"TRCOnline_2-22.png"];
                }else{
                    //灰色汽车
                    cell.deviceImage.image = [UIImage imageNamed:@"TRCOnline_2-9.png"];
                }
                break;
            case 4:
                cell.statusLabel.text = MyLocal(@"欠费");
                if ([aDevice.icon intValue]==23) {
                    //灰色摩托车
                    cell.deviceImage.image = [UIImage imageNamed:@"TRCOnline_2-22.png"];
                }else{
                    //灰色汽车
                    cell.deviceImage.image = [UIImage imageNamed:@"TRCOnline_2-9.png"];
                }
                break;
                
            default:
                break;
        }
        cell.deviceNameLabel.text = aDevice.deviceName;
        if (aDevice.licencePlate == nil || aDevice.licencePlate.length == 0) {
            cell.licencePlateLabel.text = MyLocal(@"暂无车牌号码显示");
        } else {
            cell.licencePlateLabel.text = aDevice.licencePlate;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if ([cell.statusLabel.text isEqualToString:MyLocal(@"未启用")]||[cell.statusLabel.text isEqualToString:MyLocal(@"欠费")]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    return cell;
}
// tableView的header点击，实现列表的展开与收回
#pragma mark - CustomHeaderViewDelegate

- (void)sectionHeaderView:(CustomHeaderView *)sectionHeaderView sectionClosed:(NSInteger)section
{
    DeviceGroup *devices = _tableDataLists[section];// 获取某个组及对应下的所有设备
    devices.isUnfolded = !devices.isUnfolded;// 更改组的展开状态
    [(DeviceGroup *)(_allDeviceLists[section]) setUnfoldState:devices.isUnfolded];// 保存展开状态
    [(DeviceGroup *)(_onlineDeviceLists[section]) setUnfoldState:devices.isUnfolded];
    [(DeviceGroup *)(_offlineDeviceLists[section]) setUnfoldState:devices.isUnfolded];
    
    if (devices.isUnfolded) {
        sect = section;
    }else{
        sect = NULL;
    }
    
    if (devices.devicesByGroup.count > 0) {
        devices.indexPaths = [[NSMutableArray alloc] init];
        // 对应所有应该展开或者是收回的NSIndexPath
        for (int i = 0; i < devices.devicesByGroup.count; i++) {
            [devices.indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
        }
    }
    // 添加或者删除NSIndexPath对应的行
    [self.table deleteRowsAtIndexPaths:devices.indexPaths withRowAnimation:UITableViewRowAnimationTop];
}

- (void)sectionHeaderView:(CustomHeaderView *)sectionHeaderView sectionOpened:(NSInteger)section
{
    DeviceGroup *devices = _tableDataLists[section];
    devices.isUnfolded = !devices.isUnfolded;
    [(DeviceGroup *)(_allDeviceLists[section]) setUnfoldState:devices.isUnfolded];
    [(DeviceGroup *)(_onlineDeviceLists[section]) setUnfoldState:devices.isUnfolded];
    [(DeviceGroup *)(_offlineDeviceLists[section]) setUnfoldState:devices.isUnfolded];
    
    if (devices.isUnfolded) {
        sect = section;
    }else{
        sect = NULL;
    }
    
    if (devices.devicesByGroup.count > 0) {
        devices.indexPaths = [[NSMutableArray alloc] init];
        for (int i = 0; i < devices.devicesByGroup.count; i++) {
            [devices.indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
        }
    }
    if (devices.indexPaths) {
        [self.table insertRowsAtIndexPaths:devices.indexPaths withRowAnimation:UITableViewRowAnimationTop];
    }
}
// 点击全部、在线、离线按钮时设置对应按钮区域背景颜色和选中状态
// 点击搜索按钮切换到另外一个界面
// 刷新所有数据（从服务器获取到本地再从本地读取）
// 获取tableView每个分组的展开状态
#pragma mark - Target Action

- (void)allButtonAction
{
    [_naviView setFrame:CGRectMake(0, 42, 106, 2)];
    
    self.all.selected = YES;
    self.online.selected = NO;
    self.offline.selected = NO;
    
    self.tableDataLists = _allDeviceLists;
    [self.table reloadData];
}

- (void)onlineButtonAction
{
    [_naviView setFrame:CGRectMake(107, 42, 106, 2)];

    self.all.selected = NO;
    self.online.selected = YES;
    self.offline.selected = NO;
    
    self.tableDataLists = _onlineDeviceLists;
    [self.table reloadData];
}

- (void)offlineButtonAction
{
    [_naviView setFrame:CGRectMake(214, 42, 106, 2)];

    self.all.selected = NO;
    self.online.selected = NO;
    self.offline.selected = YES;

    self.tableDataLists = _offlineDeviceLists;
    [self.table reloadData];
}

- (void)search
{
    SearchViewController *search = [[SearchViewController alloc] init];
    search.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:search animated:YES];
}

- (void)refreshAction:(id)sender
{
    
    if (_hud&&[sender isKindOfClass:[UIButton class]]) {
        [_hud show:YES];
    }
    
    NSInteger loginType = [USER_DEFAULT integerForKey:@"LoginType"];
    if (loginType == 0) {
        [self getDeviceGroups];
    }else{
        [self getDeviceList];
    }
}
- (void)refresh
{
    [self loadTabelViewData];
    
//    [self sectionHeaderView:nil sectionOpened:0];
//    DeviceGroup *devices = _tableDataLists[(int)sect];
//    if (_tableDataLists.count > 0 ) {
//        
//        devices.isUnfolded = YES;
//    }else{
//        //           devices.isUnfolded = NO;
//        //
//    }

    [self.table reloadData];
    [self sectionHeaderView:nil sectionOpened:sect];
    
    [_all setTitle:[NSString stringWithFormat:MyLocal(@"全部%@"), [NSNumber numberWithUnsignedInteger:_allDevices.count]] forState:UIControlStateNormal];
    [_all setTitle:[NSString stringWithFormat:MyLocal(@"全部%@"), [NSNumber numberWithUnsignedInteger:_allDevices.count]] forState:UIControlStateSelected];
    [_online setTitle:[NSString stringWithFormat:MyLocal(@"在线%d"), _onlineDevices.count] forState:UIControlStateNormal];
    [_offline setTitle:[NSString stringWithFormat:MyLocal(@"离线%d"), _offlineDevices.count] forState:UIControlStateNormal];
    if (_hud) {
        [_hud hide:YES];
    }
    
//    NSLog(@"-------------%@",[NSNumber numberWithInteger:_allDevices.count]);
}

- (void)refreshStatus
{
//    [self sectionHeaderView:nil sectionOpened:0]; 
//    for (UIView *view in self.table.subviews) {
//        if ([view isKindOfClass:[DeviceInfoCell class]]) {
//            DeviceInfoCell *cell = (DeviceInfoCell *)view;
//            NSString *deviceName = cell.deviceNameLabel.text;
//            NSInteger status = [_DB intForQuery:@"select status from Device where deviceName = ?", deviceName];
//            switch (status) {
//                case 0:
//                    cell.statusLabel.text = MyLocal(@"未启用");
//                    break;
//                case 1:
//                    cell.statusLabel.text = MyLocal(@"运动");
//                    break;
//                case 2:
//                    cell.statusLabel.text = MyLocal(@"静止");
//                    break;
//                case 3:
//                    cell.statusLabel.text = MyLocal(@"离线");
//                    break;
//                case 4:
//                    cell.statusLabel.text = MyLocal(@"欠费");
//                    break;
//                default:
//                    break;
//            }
//        }
//    }
    
    NSInteger count = _tableDataLists.count;
    for (int i = 0; i < count; i++) {
        DeviceGroup *devices = _tableDataLists[i];
        if (devices.isUnfolded) {
            for (int j = 0; j < devices.devicesByGroup.count; j++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                DeviceInfoCell *cell = (DeviceInfoCell *)[_table cellForRowAtIndexPath:indexPath];
                NSString *deviceName = cell.deviceNameLabel.text;
                NSInteger status = [_DB intForQuery:@"select status from Device where deviceName = ?", deviceName];
                NSString *icon = [_DB stringForQuery:@"select icon from Device where deviceName = ?", deviceName];
                switch (status) {
                    case 0:
                        cell.statusLabel.text = MyLocal(@"未启用");
                        if ([icon intValue]==23) {
                            //灰色摩托车
                            cell.deviceImage.image = [UIImage imageNamed:@"TRCOnline_2-22.png"];
                        }else{
                            //灰色汽车
                            cell.deviceImage.image = [UIImage imageNamed:@"TRCOnline_2-9.png"];
                        }
                        break;
                    case 1:
                        cell.statusLabel.text = MyLocal(@"运动");
                        if ([icon intValue]==23) {
                            //绿色摩托车
                            cell.deviceImage.image = [UIImage imageNamed:@"TRCOnline_2-21.png"];
                        }else{
                            //绿色汽车
                            cell.deviceImage.image = [UIImage imageNamed:@"TRCOnline_2-8.png"];
                        }
                        break;
                    case 2:
                        cell.statusLabel.text = MyLocal(@"静止");
                        if ([icon intValue]==23) {
                            //橙色摩托车
                            cell.deviceImage.image = [UIImage imageNamed:@"TRCOnline_2-20.png"];
                        }else{
                            //橙色汽车
                            cell.deviceImage.image = [UIImage imageNamed:@"TRCOnline_2-7.png"];
                        }
                        break;
                    case 3:
                        cell.statusLabel.text = MyLocal(@"离线");
                        if ([icon intValue]==23) {
                            //灰色摩托车
                            cell.deviceImage.image = [UIImage imageNamed:@"TRCOnline_2-22.png"];
                        }else{
                            //灰色汽车
                            cell.deviceImage.image = [UIImage imageNamed:@"TRCOnline_2-9.png"];
                        }
                        break;
                    case 4:
                        cell.statusLabel.text = MyLocal(@"欠费");
                        if ([icon intValue]==23) {
                            //灰色摩托车
                            cell.deviceImage.image = [UIImage imageNamed:@"TRCOnline_2-22.png"];
                        }else{
                            //灰色汽车
                            cell.deviceImage.image = [UIImage imageNamed:@"TRCOnline_2-9.png"];
                        }
                        break;
                    default:
                        break;
                }
            }
        }
    }
}

#pragma mark - WebServiceAction

- (void)getDeviceStatus
{
    WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceList" andDelegate:self];
    webService.tag = WebServiceTag_GetDeviceStatus;
    WebServiceParameter *getDeviceParameter1 = [WebServiceParameter newWithKey:@"ID" andValue:[USER_DEFAULT objectForKey:@"ReturnID"]];
    WebServiceParameter *getDeviceParameter2 = [WebServiceParameter newWithKey:@"PageNo" andValue:@"1"];
    WebServiceParameter *getDeviceParameter3 = [WebServiceParameter newWithKey:@"PageCount" andValue:@"9999"];
    WebServiceParameter *getDeviceParameter4 = [WebServiceParameter newWithKey:@"TypeID" andValue:[NSString stringWithFormat:@"%ld", (long)[USER_DEFAULT integerForKey:@"LoginType"]]];
    WebServiceParameter *getDeviceParameter5 = [WebServiceParameter newWithKey:@"IsAll" andValue:@"false"];
    WebServiceParameter *getDeviceParameter6 = [WebServiceParameter newWithKey:@"MapType" andValue:@"Google"];

    webService.webServiceParameter = @[getDeviceParameter1, getDeviceParameter2, getDeviceParameter3, getDeviceParameter4, getDeviceParameter5, getDeviceParameter6];
    [webService getWebServiceResult:@"GetDeviceListResult"];
}

- (void)getDeviceList
{
    WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceList" andDelegate:self];
    webService.tag = WebServiceTag_GetDeviceDetail;
    WebServiceParameter *getDeviceParameter1 = [WebServiceParameter newWithKey:@"ID" andValue:[USER_DEFAULT objectForKey:@"ReturnID"]];
    WebServiceParameter *getDeviceParameter2 = [WebServiceParameter newWithKey:@"PageNo" andValue:@"1"];
    WebServiceParameter *getDeviceParameter3 = [WebServiceParameter newWithKey:@"PageCount" andValue:@"9999"];
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
    WebServiceParameter *getGroupParameter = [WebServiceParameter newWithKey:@"UserID" andValue:[USER_DEFAULT objectForKey:@"ReturnID"]];
    webService.webServiceParameter = @[getGroupParameter];
    [webService getWebServiceResult:@"GetGroupByUserIDResult"];
}


#pragma mark - WebServiceProtocol

- (void)WebServiceGetCompleted:(id)theWebService
{
    if ([[theWebService webServiceResult] length] > 0) {
//        SBJsonParser *parser = [[SBJsonParser alloc] init];
//        NSError *error = nil;
        // 解析成json数据
//        id object = [parser objectWithString:[theWebService soapResults] error:&error];
        NSString *str = [theWebService soapResults];
        str = [str stringByReplacingOccurrencesOfString:@"	" withString:@""];
        id object = [str objectFromJSONString];
        if (object) {
            // 获得状态
            if ([theWebService tag] == WebServiceTag_GetDeviceStatus) {
                int state = [[object objectForKey:@"state"] intValue];
                if (state == 0) {
                    NSArray *allDevice = [object objectForKey:@"arr"];
                    for (id aDevice in allDevice) {
                        int deviceID = [[aDevice objectForKey:@"id"] intValue];
                        int status = [[aDevice objectForKey:@"status"] intValue];
                        BOOL bo;
                        bo = [_DB executeUpdate:@"update Device set status = ? where deviceID = ?", [NSNumber numberWithInt:status], [NSNumber numberWithInt:deviceID]];
                        if (!bo) {
                            
                        }
                    }
                    
                    [self performSelectorOnMainThread:@selector(refreshStatus) withObject:nil waitUntilDone:NO];
                }
            } else if ([theWebService tag] == WebServiceTag_GetDeviceDetail) {
                int state = [[object objectForKey:@"state"] intValue];
                if (state == 0) {
                    BOOL bo = [_DB executeUpdate:@"drop table Device"];
                    bo = [_DB executeUpdate:@"create table Device (deviceID integer primary key, deviceName text, groupID integer, licencePlate text, status integer, icon text, latitude text, longitude text, acc integer, power integer, isShowAcc integer, type text, course text)"];
                    
                    NSArray *allDevice = [object objectForKey:@"arr"];
                    for (id aDevice in allDevice) {
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
                    [self performSelectorOnMainThread:@selector(refresh) withObject:nil waitUntilDone:NO];
                }else{
                    BOOL bo = [_DB executeUpdate:@"drop table Device"];
                    bo = [_DB executeUpdate:@"create table Device (deviceID integer primary key, deviceName text, groupID integer, licencePlate text, status integer, icon text, latitude text, longitude text, acc integer, power integer, isShowAcc integer, type text, course text)"];
                    [self performSelectorOnMainThread:@selector(refresh) withObject:nil waitUntilDone:NO];
                }
                if (_hud) {
                    [_hud hide:YES];
                }
            } else if ([theWebService tag] == WebServiceTag_GetGroup) {
                int state = [[object objectForKey:@"state"] intValue];
                // 根据状态判断是否成功，0表示成功
                if (state == 0) {
                    BOOL bo;
                    bo = [_DB executeUpdate:@"drop table DeviceGroup"];
                    bo = [_DB executeUpdate:@"create table DeviceGroup (groupID integer, groupName text)"];

                    NSArray *allDevice = [object objectForKey:@"arr"];
                    for (id aDevice in allDevice) {
                        int groupID = [[aDevice objectForKey:@"id"] intValue];
                        NSString *name = [aDevice objectForKey:@"name"];
                        BOOL bo;
                        bo = [_DB executeUpdate:@"insert into DeviceGroup (groupID, groupName) values (?, ?)", [NSNumber numberWithInt:groupID], name];
                    }
                    [self getDeviceList];
                }else{
                    BOOL bo;
                    bo = [_DB executeUpdate:@"drop table DeviceGroup"];
                    bo = [_DB executeUpdate:@"create table DeviceGroup (groupID integer, groupName text)"];
                    
                    [self getDeviceList];
                }
            }
        }
    }
//    if (_hud) {
//        [_hud hide:YES];
//    }
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

- (void)showMoreVC{
    MoreViewController *more = [[MoreViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:more];
    if (BYT_IOS7) {
        [nav.navigationBar setBarTintColor:mycolor];
        
    }else {
        [nav.navigationBar setTintColor:mycolor];
    }
    [self presentViewController:nav animated:YES completion:nil];
}
@end
