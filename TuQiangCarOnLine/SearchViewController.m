//
//  SearchViewController.m
//  NewGps2012
//
//  Created by TR on 13-2-4.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "SearchViewController.h"
#import "DeviceInfoCell.h"
#import "DeviceList.h"
#import "WebServiceParameter.h"
#import "SBJson.h"
#import "SelectDeviceViewController.h"
#import "DeviceDetail.h"
#import "UIImage+Scale.h"


@interface SearchViewController () <UIAlertViewDelegate>

@end

@implementation SearchViewController

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
}


#pragma mark - initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = MyLocal(@"查找");
        self.searchResults = [[NSMutableArray alloc] init];
        
        //获取Document文件夹下的数据库文件，没有则创建
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dbPath = [docPath stringByAppendingPathComponent:@"user.db"];
        //获取数据库并打开
        self.DB  = [FMDatabase databaseWithPath:dbPath];
        if (![_DB open]) {
            [self showAlert:MyLocal(@"数据库打开失败") withTag:-1];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    IOS7;
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 11, 21)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47, 36)];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"5.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"5-1.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;

    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.searchBar.backgroundImage = [[UIImage imageNamed:@"TRCOnline_2d-1.png"] scaleToSize:CGSizeMake(320, 44)];
    self.searchBar.placeholder = MyLocal(@"输入设备名/车牌号");
    self.searchBar.delegate = self;
    [self.view addSubview:_searchBar];
    
    if (BYT_IOS7) {
        self.searchDeviceTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44-44-20) style:UITableViewStylePlain];
    }else{
        self.searchDeviceTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44-44) style:UITableViewStylePlain];
    }
    self.searchDeviceTable.delegate = self;
    self.searchDeviceTable.dataSource = self;
    //隐藏cell的线条
    _searchDeviceTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_searchDeviceTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Target Action

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)search
{
    [_searchBar resignFirstResponder];
    
    [_searchResults removeAllObjects];
    NSString *searchCondition = _searchBar.text;
    NSString *likeStr = [NSString stringWithFormat:@"%%%@%%", searchCondition];
    FMResultSet *resultSet = [_DB executeQuery:@"select * from Device where deviceName like ? or licencePlate like ?",likeStr, likeStr];
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
        aDevice.course = [resultSet stringForColumn:@"course"];
        [_searchResults addObject:aDevice];
    }
    
    if(_searchResults.count == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"无匹配结果")  delegate:self cancelButtonTitle:MyLocal(@"确定")  otherButtonTitles:nil, nil];
        [alert show];
    }
    
    [_searchDeviceTable reloadData];
}

#pragma mark - TableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 53.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Device *aDevice = _searchResults[indexPath.row];
    int deviceID = aDevice.deviceID;
    NSString *deviceName = aDevice.deviceName;
    NSString *licencePlate = aDevice.licencePlate;
    NSString *carIcon = aDevice.icon;
    
    if (aDevice.status == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"车辆未启用") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if (aDevice.status == 4) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"车辆已欠费") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if (aDevice.status == 1 || aDevice.status == 2) {
        carIcon = [NSString stringWithFormat:@"car%@", carIcon];
    } else {
        carIcon = [NSString stringWithFormat:@"offline%@", carIcon];
    }
    int power = aDevice.power;
    int isShowAcc = aDevice.isShowAcc;
    NSString *type = aDevice.type;
    
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

#pragma mark - TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cellIdentifier";
    DeviceInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[DeviceInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
       
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,53-2, 320, 2)];
        imageView.image = [UIImage imageNamed:@"line.png"];
        [cell addSubview:imageView];
    }
    if (_searchResults.count > 0) {
        Device *aDevice = _searchResults[indexPath.row];
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
//
//        switch (aDevice.status) {
//            case 0:
//                cell.statusLabel.text = MyLocal(@"未启用");
//                cell.deviceImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"offline%@.png", aDevice.icon]];
//                break;
//            case 1:
//                cell.statusLabel.text = MyLocal(@"运动");
//                cell.deviceImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"car%@.png", aDevice.icon]];
//                break;
//            case 2:
//                cell.statusLabel.text = MyLocal(@"静止");
//                cell.deviceImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"car%@.png", aDevice.icon]];
//                break;
//            case 3:
//                cell.statusLabel.text = MyLocal(@"离线");
//                cell.deviceImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"offline%@.png", aDevice.icon]];
//                break;
//            case 4:
//                cell.statusLabel.text = MyLocal(@"欠费");
//                cell.deviceImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"offline%@.png", aDevice.icon]];
//                break;
//            default:
//                break;
//        }
        cell.deviceNameLabel.text = aDevice.deviceName;
        if (aDevice.licencePlate == nil || aDevice.licencePlate.length == 0) {
            cell.licencePlateLabel.text = MyLocal(@"暂无");
        } else {
            cell.licencePlateLabel.text = aDevice.licencePlate;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if ([cell.statusLabel.text isEqualToString:MyLocal(@"未启用")]||[cell.statusLabel.text isEqualToString:MyLocal(@"欠费")]) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;
        }
    }
    return cell;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self search];
}

@end
