//
//  MoreViewController.m
//  NewGps2012
//
//  Created by TR on 13-3-22.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "MoreViewController.h"
#import "ChangePwdViewController.h"
#import "UsinghelpViewController.h"
#import "AboutViewController.h"
#import "NavigationViewController.h"
#import "ViewController.h"
#import "UIImage+Scale.h"
#import "ZBarSDK.h"
#import "LMHttpPost.h"
#import "SVProgressHUD.h"
#import "APService.h"
#import "MyserviceViewController.h"
#import "NoticeSettingViewController.h"
#import "PushTypeViewController.h"

@interface MoreViewController () <UITextFieldDelegate, ZBarReaderDelegate>

@property (strong, nonatomic) UITextField *imeiTextField;
@property (strong, nonatomic) UIButton *addButton;
@property (strong, nonatomic) UIButton *logoutButton;
@property (nonatomic) BOOL showIMEITextField;
@property (strong, nonatomic) UISwitch *pushSwitch;
@property (strong, nonatomic) UISwitch *accSwitch;

@end

@implementation MoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = MyLocal(@"更多");
        self.showIMEITextField = NO;
        NSInteger loginType = [USER_DEFAULT integerForKey:@"LoginType"];
        if (loginType == 0) {
            self.tableData = @[MyLocal(@"修改密码"), MyLocal(@"使用帮助"), MyLocal(@"关于本软件"), MyLocal(@"我的服务商"), MyLocal(@"信息推送开关")/*,  MyLocal(@"推送类型设置")*/,MyLocal(@"添加设备")];
        } else {
            self.tableData = @[MyLocal(@"修改密码"), MyLocal(@"使用帮助"), MyLocal(@"关于本软件"), MyLocal(@"我的服务商"), MyLocal(@"信息推送开关")/*,  MyLocal(@"推送类型设置")*/];
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    IOS7;
    
    self.view.backgroundColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0];
    
    // 返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 11, 21)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    
    self.moreTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, 40*_tableData.count)];
    self.moreTable.scrollEnabled = YES;
    self.moreTable.delegate = self;
    self.moreTable.dataSource = self;
    [self.view addSubview:_moreTable];
    
    self.pushSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    _pushSwitch.onTintColor = [UIColor blueColor];
    _pushSwitch.on = YES;
    
    self.accSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    _accSwitch.onTintColor = [UIColor blueColor];
    _accSwitch.on = NO;
    
    self.imeiTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, 250, 40)];
    _imeiTextField.placeholder = MyLocal(@"设备IMEI号");
    _imeiTextField.font = [UIFont fontWithName:@"AppleGothic" size:20.0];
    _imeiTextField.backgroundColor = [UIColor clearColor];
    _imeiTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _imeiTextField.keyboardType = UIKeyboardTypeNumberPad;
    _imeiTextField.delegate = self;
    
    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _addButton.frame = CGRectMake(15, 320, 290, 40);
    _addButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
//    [_addButton setBackgroundImage:[UIImage imageNamed:@"3.png"] forState:UIControlStateNormal];
    _addButton.backgroundColor = mycolor;
    [_addButton setTitle:MyLocal(@"添加") forState:UIControlStateNormal];
    [_addButton addTarget:self action:@selector(addDevice) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_addButton];
    _addButton.hidden = YES;
    
    self.logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _logoutButton.frame = CGRectMake(15, (iPhone5?370:320), 290, 40);
    _logoutButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
//    [_logoutButton setBackgroundImage:[UIImage imageNamed:@"3.png"] forState:UIControlStateNormal];
    _logoutButton.backgroundColor = mycolor;
    [_logoutButton setTitle:MyLocal(@"注销") forState:UIControlStateNormal];
    [_logoutButton addTarget:self action:@selector(logOut) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_logoutButton];
}

- (void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    //修改导航条上的字体为白色
    if (BYT_IOS7) {
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor, nil]];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)logOut
{
    BOOL lastLoginByIMEI = [USER_DEFAULT boolForKey:@"LastLoginByIMEI"];
    if (lastLoginByIMEI) {
        [USER_DEFAULT setBool:NO forKey:@"IsIMEIAutoLogin"];
    } else {
        [USER_DEFAULT setBool:NO forKey:@"IsAutoLogin"];
    }
    [USER_DEFAULT setObject:@"" forKey:@"UserPass"];
    [APService setAlias:@"" callbackSelector:@selector(aliasCallback:tags:alias:) object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:nil];
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
}
- (void)aliasCallback:(int)iResCode tags:(NSSet*)tags alias:(NSString*)alias {
    
    NSLog(@"aliasCallback rescode: %d, tags: %@, alias: %@\n", iResCode, tags , alias);
}
- (void)showIMEIScan
{
    _addButton.hidden = NO;
    self.tableData = @[MyLocal(@"修改密码"), MyLocal(@"使用帮助"), MyLocal(@"关于本软件"), MyLocal(@"我的服务商"), MyLocal(@"信息推送开关")/*,  MyLocal(@"推送类型设置")*/, MyLocal(@"取消添加设备"), @""];
    _moreTable.frame = CGRectMake(_moreTable.frame.origin.x, _moreTable.frame.origin.y, _moreTable.frame.size.width, 40*_tableData.count);
    [_moreTable reloadData];
    _logoutButton.frame = CGRectMake(15, (iPhone5?370:370), 290, 40);
}

//MyLocal(@"信息推送"), MyLocal(@"ACC点火"),
- (void)dismissIMEIScan
{
    _addButton.hidden = YES;
    _imeiTextField.text = @"";
    self.tableData = @[MyLocal(@"修改密码"), MyLocal(@"使用帮助"), MyLocal(@"关于本软件"), MyLocal(@"我的服务商"), MyLocal(@"信息推送开关")/*,  MyLocal(@"推送类型设置")*/, MyLocal(@"添加设备")];
    _moreTable.frame = CGRectMake(_moreTable.frame.origin.x, _moreTable.frame.origin.y, _moreTable.frame.size.width, 40*_tableData.count);
    [_moreTable reloadData];
    _logoutButton.frame = CGRectMake(15, (iPhone5?370:320), 290, 40);
}

- (void)scan
{
    [_imeiTextField resignFirstResponder];
    
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    [self presentViewController:reader animated:YES completion:nil];
    
}

- (void)addDevice
{
    [_imeiTextField resignFirstResponder];
    
    if (_imeiTextField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"请输入设备IMEI号码") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    LMHttpPost *httpPost = [[LMHttpPost alloc] init];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[[USER_DEFAULT objectForKey:@"ReturnID"], _imeiTextField.text] forKeys:@[@"userID", @"SerialNumber"]];
    [httpPost getResponseWithName:@"AddDeviceToUser" parameters:parameters success:^(NSDictionary *json) {
        [SVProgressHUD dismiss];
        NSString *message = @"";
        switch ([json[@"state"] integerValue]) {
            case 1002:
                message = MyLocal(@"发生错误");
                break;
            case 2001:
                message = MyLocal(@"IMEI格式无效");
                break;
            case 2002:
                message = MyLocal(@"IMEI不存在");
                break;
            case 3001:
                message = MyLocal(@"成功");
                break;
            default:
                break;
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
        [alert show];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)navitation
{
    NSString *latStr = [USER_DEFAULT objectForKey:@"Latitude"];
    NSString *lngStr = [USER_DEFAULT objectForKey:@"Longitude"];
    
    if (!latStr) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"设备未定位") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    CLLocationCoordinate2D end = CLLocationCoordinate2DMake([latStr doubleValue], [lngStr doubleValue]);
    MKMapItem *source = [MKMapItem mapItemForCurrentLocation];
    source.name = MyLocal(@"当前位置");
    MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:end addressDictionary:nil]];
    destination.name = MyLocal(@"车辆位置");
    
    if (BYT_IOS7) {
        NavigationViewController *navController = [[NavigationViewController alloc] init];
        navController.hidesBottomBarWhenPushed = YES;
        navController.source = source;
        navController.destination = destination;
        [self.navigationController pushViewController:navController animated:YES];
    } else {
        [MKMapItem openMapsWithItems:@[source, destination] launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsShowsTrafficKey: @YES}];
    }
}

#pragma mark - ZBarReaderDelegate

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info{
    
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    
    //    resultText.text = symbol.data;
    //
    //    resultImage.image = [info objectForKey: UIImagePickerControllerOriginalImage];
    
    _imeiTextField.text = symbol.data;
    
    [reader dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (indexPath.row == 0) {
        cell.textLabel.font = [UIFont fontWithName:@"AppleGothic" size:20.0];
        //cell.accessoryView = _pushSwitch;
    }
    if (indexPath.row == 1){
        cell.textLabel.font = [UIFont fontWithName:@"AppleGothic" size:20.0];
        //cell.accessoryView = _accSwitch;
    }
        
    if (indexPath.row == 6) {
        [cell.contentView addSubview:_imeiTextField];
        UIButton *scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
        scanButton.frame = CGRectMake(0, 0, 30, 30);
        [scanButton setBackgroundImage:[UIImage imageNamed:@"saomiaoimei.png"] forState:UIControlStateNormal];
        [scanButton addTarget:self action:@selector(scan) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView  = scanButton;
    } else {
        cell.textLabel.text = _tableData[indexPath.row];
        cell.textLabel.font = [UIFont fontWithName:@"AppleGothic" size:20.0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (_imeiTextField.isEditing) {
        [_imeiTextField resignFirstResponder];
        return;
    }
    
    if (indexPath.row == 0) {
        ChangePwdViewController *changePwd = [[ChangePwdViewController alloc] init];
        changePwd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:changePwd animated:YES];
    } else if (indexPath.row == 1) {
        UsinghelpViewController *usingHelp = [[UsinghelpViewController alloc] init];
        usingHelp.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:usingHelp animated:YES];
    } else if (indexPath.row == 2) {
        AboutViewController *about = [[AboutViewController alloc] init];
        about.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:about animated:YES];
    } else if (indexPath.row == 3) {
        MyserviceViewController *serviceVC = [[MyserviceViewController alloc] init];
        serviceVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:serviceVC animated:YES];

    }else if (indexPath.row == 4) {
        NoticeSettingViewController *noticeVC = [[NoticeSettingViewController alloc]init];
        noticeVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:noticeVC animated:YES];
       
    }
    /*else if (indexPath.row == 5) {
        PushTypeViewController *pushtypeVC = [[PushTypeViewController alloc] init];
        pushtypeVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:pushtypeVC animated:YES];
        
    }*/
    else if (indexPath.row == 5) {
        _showIMEITextField = !_showIMEITextField;
        if (_showIMEITextField) {
            [self showIMEIScan];
        } else {
            [self dismissIMEIScan];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.25 animations:^{
        _moreTable.frame = CGRectMake(_moreTable.frame.origin.x, (iPhone5?-80:-120), _moreTable.frame.size.width, _moreTable.frame.size.height);
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.25 animations:^{
        _moreTable.frame = CGRectMake(_moreTable.frame.origin.x, 0, _moreTable.frame.size.width, _moreTable.frame.size.height);
    }];
}

@end
