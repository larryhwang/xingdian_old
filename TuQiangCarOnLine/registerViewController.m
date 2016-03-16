//
//  registerViewController.m
//  途强汽车在线
//
//  Created by MyThinkRace on 14-3-14.
//  Copyright (c) 2014年 thinkrace. All rights reserved.
//

#import "registerViewController.h"

#import "UIImage+Scale.h"
#import "MBProgressHUD.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "SBJson.h"

#define WebServiceTag_UserRegistered 1

@interface registerViewController ()

@property(nonatomic,strong)UITableView *tableview;

@property(nonatomic,strong)UITextField *userNameTF;
@property(nonatomic,strong)UITextField *accountTF;
@property(nonatomic,strong)UITextField *passwordTF;
@property(nonatomic,strong)UITextField *deviceIMEITF;
@property(nonatomic,strong)UITextField *deviceSIMTF;
@property(nonatomic,strong)UITextField *linkmanTF;
@property(nonatomic,strong)UITextField *phoneNumberTF;

@property(nonatomic,strong)NSString *userName;
@property(nonatomic,strong)NSString *account;
@property(nonatomic,strong)NSString *password;
@property(nonatomic,strong)NSString *deviceIMEI;
@property(nonatomic,strong)NSString *deviceSIM;
@property(nonatomic,strong)NSString *linkman;
@property(nonatomic,strong)NSString *phoneNumber;

@property(nonatomic,strong)UIButton *registerButton;
@property(nonatomic,strong)UIButton *cancelButton;

@property(nonatomic,strong)NSArray *placeholders;

@property (strong, nonatomic) MBProgressHUD *hud;


@end

@implementation registerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = MyLocal(@"注册");
        _placeholders = @[MyLocal(@"用户名称"),MyLocal(@"登录账号"),MyLocal(@"密码"),MyLocal(@"设备IMEI号"),MyLocal(@"设备SIM卡号码"),MyLocal(@"联系人"),MyLocal(@"电话")];
        _userName = @"";
        _account = @"";
        _password = @"";
        _deviceIMEI = @"";
        _deviceSIM = @"";
        _linkman = @"";
        _phoneNumber = @"";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    IOS7;
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 11, 21)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    if (BYT_IOS7) {
        _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-44-20) style:UITableViewStylePlain];
    }else{
        _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-44) style:UITableViewStylePlain];
    }
    [_tableview setContentInset:UIEdgeInsetsMake(0, 0, 160, 0)];
    _tableview.backgroundView = nil;
    _tableview.backgroundColor = [UIColor colorWithRed:220/255.0f green:220/255.0f blue:220/255.0f alpha:1.0f];
    [_tableview setSeparatorColor:[UIColor clearColor]];
    _tableview.dataSource = self;
    _tableview.delegate = self;
    [self.view addSubview:_tableview];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //修改导航条上的字体为白色
    if (BYT_IOS7) {
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor, nil]];
        [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"TRCOnline_1-5.png"] scaleToSize:CGSizeMake(320, 64)] forBarMetrics:UIBarMetricsDefault];

    } else {
        [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"TRCOnline_1-5.png"] scaleToSize:CGSizeMake(320, 44)] forBarMetrics:UIBarMetricsDefault];
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - Target Actions

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)registerButtonClick:(UIButton*)button{
    
    if (self.userNameTF.text.length == 0 && self.accountTF.text.length == 0 && self.passwordTF.text.length == 0 && self.deviceIMEITF.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:MyLocal(@"提示") message:MyLocal(@"带“*”号的为必填项") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
        [alertView show];
    }else{
        [self userRegistered];
    }
}

#pragma mark - 扫描二维码

-(void)whenClickImage
{    
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    [self presentViewController:reader animated:YES completion:nil];
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info{

    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    
//    resultText.text = symbol.data;
//    
//    resultImage.image = [info objectForKey: UIImagePickerControllerOriginalImage];
    
    _deviceIMEITF.text = symbol.data;
    
    [reader dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextfieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.placeholders.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];

    switch (indexPath.row) {
        case 0:{
            _userNameTF = [[UITextField alloc]initWithFrame:CGRectMake(10, 3, 300, 44)];
            _userNameTF.tag = indexPath.row;
            _userNameTF.text = _userName;
            _userNameTF.borderStyle = UITextBorderStyleNone;
            _userNameTF.background = [UIImage imageNamed:@"textfieldbgimage"];
            _userNameTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            _userNameTF.placeholder = _placeholders[indexPath.row];
            _userNameTF.delegate = self;
            [cell addSubview:_userNameTF];
        }
            break;
        case 1:{
            _accountTF = [[UITextField alloc]initWithFrame:CGRectMake(10, 3, 300, 44)];
            _accountTF.tag = indexPath.row;
            _accountTF.text = _account;
            _accountTF.borderStyle = UITextBorderStyleNone;
            _accountTF.background = [UIImage imageNamed:@"textfieldbgimage"];
            _accountTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            _accountTF.placeholder = _placeholders[indexPath.row];
            _accountTF.delegate = self;
            [cell addSubview:_accountTF];
        }
            break;
        case 2:{
            _passwordTF = [[UITextField alloc]initWithFrame:CGRectMake(10, 3, 300, 44)];
            _passwordTF.tag = indexPath.row;
            _passwordTF.text = _password;
            _passwordTF.secureTextEntry = YES;
            _passwordTF.borderStyle = UITextBorderStyleNone;
            _passwordTF.background = [UIImage imageNamed:@"textfieldbgimage"];
            _passwordTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            _passwordTF.placeholder = _placeholders[indexPath.row];
            _passwordTF.delegate = self;
            [cell addSubview:_passwordTF];
        }
            break;
        case 3:{
            _deviceIMEITF = [[UITextField alloc]initWithFrame:CGRectMake(10, 3, 300, 44)];
            _deviceIMEITF.tag = indexPath.row;
            _deviceIMEITF.text = _deviceIMEI;
            _deviceIMEITF.borderStyle = UITextBorderStyleNone;
            _deviceIMEITF.background = [UIImage imageNamed:@"textfieldbgimage"];
            _deviceIMEITF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            _deviceIMEITF.placeholder = _placeholders[indexPath.row];
            _deviceIMEITF.delegate = self;
            [cell addSubview:_deviceIMEITF];
            
            UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(242, 6, 38, 38)];
            imageview.image = [UIImage imageNamed:@"saomiaoimei"];
            imageview.userInteractionEnabled = YES;
            UITapGestureRecognizer *singleTap =
            [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(whenClickImage)];
            [imageview addGestureRecognizer:singleTap];
            [cell addSubview:imageview];
        }
            break;
        case 4:{
            _deviceSIMTF = [[UITextField alloc]initWithFrame:CGRectMake(10, 3, 300, 44)];
            _deviceSIMTF.tag = indexPath.row;
            _deviceSIMTF.text = _deviceSIM;
            _deviceSIMTF.borderStyle = UITextBorderStyleNone;
            _deviceSIMTF.background = [UIImage imageNamed:@"textfieldbgimage"];
            _deviceSIMTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            _deviceSIMTF.placeholder = _placeholders[indexPath.row];
            _deviceSIMTF.delegate = self;
            [cell addSubview:_deviceSIMTF];
        }
            break;
        case 5:{
            _linkmanTF = [[UITextField alloc]initWithFrame:CGRectMake(10, 3, 300, 44)];
            _linkmanTF.tag = indexPath.row;
            _linkmanTF.text = _linkman;
            _linkmanTF.borderStyle = UITextBorderStyleNone;
            _linkmanTF.background = [UIImage imageNamed:@"textfieldbgimage"];
            _linkmanTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            _linkmanTF.placeholder = _placeholders[indexPath.row];
            _linkmanTF.delegate = self;
            [cell addSubview:_linkmanTF];
        }
            break;
        case 6:{
            _phoneNumberTF = [[UITextField alloc]initWithFrame:CGRectMake(10, 3, 300, 44)];
            _phoneNumberTF.tag = indexPath.row;
            _phoneNumberTF.text = _phoneNumber;
            _phoneNumberTF.borderStyle = UITextBorderStyleNone;
            _phoneNumberTF.background = [UIImage imageNamed:@"textfieldbgimage"];
            _phoneNumberTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            _phoneNumberTF.placeholder = _placeholders[indexPath.row];
            _phoneNumberTF.delegate = self;
            [cell addSubview:_phoneNumberTF];
        }
            break;
        case 7:{
            _registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _registerButton.frame = CGRectMake(10, 10, 145, 44);
            [_registerButton setTitle:MyLocal(@"注册") forState:UIControlStateNormal];
            [_registerButton setBackgroundColor:[UIColor blueColor]];
            [_registerButton addTarget:self action:@selector(registerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:_registerButton];
            
            _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _cancelButton.frame = CGRectMake(165, 10, 145, 44);
            [_cancelButton setTitle:MyLocal(@"取消") forState:UIControlStateNormal];
            [_cancelButton setBackgroundColor:[UIColor blueColor]];
            [_cancelButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:_cancelButton];
            
            self.hud = [[MBProgressHUD alloc] initWithView:self.view];
            _hud.color = [UIColor colorWithWhite:0.5 alpha:0.8];
            [self.view addSubview:_hud];
            
        }
            break;
        default:
            break;
    }
    
    if (indexPath.row < 4) {
        UIImageView *mark = [[UIImageView alloc]initWithFrame:CGRectMake(280, (cell.frame.size.height-20)/2, 20, 20)];
        mark.image = [UIImage imageNamed:@"bitian"];
        [cell addSubview:mark];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < 7){
        return 50;
    }else{
        return 60;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _userName = _userNameTF.text;
    _account = _accountTF.text;
    _password = _passwordTF.text;
    _deviceIMEI = _deviceIMEITF.text;
    _deviceSIM = _deviceSIMTF.text;
    _linkman = _linkmanTF.text;
    _phoneNumber = _phoneNumberTF.text;
}

#pragma mark - WebService Action

-(void)userRegistered {
    if (_hud) {
        [_hud show:YES];
    }
    
    WebService *webService = [WebService newWithWebServiceAction:@"UserRegistered " andDelegate:self];
    webService.tag = WebServiceTag_UserRegistered ;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"SerialNumber" andValue:self.deviceIMEITF.text];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"LoginName" andValue:self.accountTF.text];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"UserName" andValue:self.userNameTF.text];
    WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"Password" andValue:self.passwordTF.text];
    WebServiceParameter *parameter5 = [WebServiceParameter newWithKey:@"Contact" andValue:self.linkmanTF.text];
    WebServiceParameter *parameter6 = [WebServiceParameter newWithKey:@"ContactPhone" andValue:self.phoneNumberTF.text];
    WebServiceParameter *parameter7 = [WebServiceParameter newWithKey:@"PhoneNumber" andValue:self.deviceSIMTF.text];
    webService.webServiceParameter = @[parameter1,parameter2,parameter3,parameter4,parameter5,parameter6,parameter7];
    
    [webService getWebServiceResult:@"UserRegisteredResult"];
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
            //
            int result = [[object objectForKey:@"state"]intValue];
            switch (result) {
                case 1001:
                    [self alertViewWithMessage:MyLocal(@"IMEI号不存在")];
                    break;
                case 1002:
                    [self alertViewWithMessage:MyLocal(@"登陆名,密码,用户名不能为空")];
                    break;
                case 1003:
                    [self alertViewWithMessage:MyLocal(@"登陆名已经存在")];
                    break;
                case 1004:
                    [self alertViewWithMessage:MyLocal(@"IMEI号已经被注册")];
                    break;
                case 2001:{
                    
                    [USER_DEFAULT setObject:_accountTF.text forKey:@"UserName"];
                    [USER_DEFAULT setObject:_passwordTF.text forKey:@"UserPass"];
                    
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:MyLocal(@"提示") message:@"注册成功" delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
                    alertView.tag = 100;
                    alertView.delegate = self;
                    [alertView show];
                }
                    break;
                    
                default:
                    break;
            }
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 0) {
        [self back];
    }
}

-(void)alertViewWithMessage:(NSString*)mess{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:MyLocal(@"提示") message:mess delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
