//
//  FamilyNumberSetViewController.m
//  途强汽车在线
//
//  Created by MyThinkRace on 13-12-4.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "FamilyNumberSetViewController.h"

#import "WebServiceParameter.h"
#import "MBProgressHUD.h"

@interface FamilyNumberSetViewController (){
    UIView *view1;
    NSArray *labelTexts;  //label中的文本
    NSString *placeholder;    //输入框中的占位符
    UITextField *textField0,*textField1;    //文本框 
    NSString *checkboxNumber0,*checkboxNumber1;   //复选框 输入的数据
}

@property (strong, nonatomic) NSString *deviceID;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) NSArray *images;

@property (strong, nonatomic) MBProgressHUD *hud;

@property (strong, nonatomic) NSString *commandID;// WebService返回的指令ID,用于调用GetResponse接口判断设备是否成功设置

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *startGetResponseTime;
@property (strong, nonatomic) UIAlertView *alertView;

@end

@implementation FamilyNumberSetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title =MyLocal(@"亲情号码设置");
        
        // 返回按钮
        UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 11, 21)];
        [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateNormal];
        [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateHighlighted];
        [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        
        self.deviceID = [USER_DEFAULT objectForKey:@"DeviceID"];
        
        labelTexts = @[MyLocal(@"亲情号码一"),MyLocal(@"亲情号码二")];
        placeholder = MyLocal(@"号码长度为3～20位");
        
        self.titles = @[MyLocal(@"添加亲情号码"),MyLocal( @"删除亲情号码"), MyLocal(@"查询亲情号码")];
        self.images = @[@"familyadd_old", @"familydelect_old", @"familysearch_old"];
        
        checkboxNumber0 = @"";
        checkboxNumber1 = @"";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    IOS7;
    
    if (BYT_IOS7) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT-44) style:UITableViewStylePlain];
    }else{
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT-44) style:UITableViewStylePlain];
    }
    //隐藏cell的线条
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    _hud.color = [UIColor colorWithWhite:0.5 alpha:0.8];
    [self.view addSubview:_hud];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    UITableViewCell *cell;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,60-2, VIEW_WIDTH, 2)];
    imageView.image = [UIImage imageNamed:@"line.png"];
    [cell addSubview:imageView];
    
    cell.imageView.image = [UIImage imageNamed:_images[indexPath.row]];
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
    switch (indexPath.row) {
        case 0:{
            if (BYT_IOS7) {
                //2个文本框
                //半透明背景
                view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height)];
                view1.backgroundColor = [UIColor colorWithRed:147/255.0f green:147/255.0f blue:147/255.0f alpha:0.5f];
                
                //为view1 添加手势
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDismiss)];
                tap.delegate = self;
                tap.cancelsTouchesInView = NO;
                [view1 addGestureRecognizer:tap];
                
                
                //alertview背景
                UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(25,70, 270, 210)];
                view2.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"alertviewbackimage2.png"]];
                
                //2个文本框
                for (int i=0; i<2; i++) {
                    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 20+i*35, 75, 30)];
                    label.text = labelTexts[i];
                    label.font = [UIFont systemFontOfSize:14.0f];
                    label.textColor = [UIColor blackColor];
                    label.backgroundColor = [UIColor clearColor];
                    [view2 addSubview:label];
                }
                textField0 = [[UITextField alloc]initWithFrame:CGRectMake(90, 20+0*35, 170, 30)];
                textField0.borderStyle = UITextBorderStyleRoundedRect;
                textField0.tag = 100+0;
                textField0.delegate = self;
                textField0.placeholder = placeholder;
                [view2 addSubview:textField0];
                
                textField1 = [[UITextField alloc]initWithFrame:CGRectMake(90 , 20+1*35, 170, 30)];
                textField1.tag = 100+1;
                textField1.delegate = self;
                textField1.placeholder = placeholder;
                textField1.borderStyle = UITextBorderStyleRoundedRect;
                [view2 addSubview:textField1];
                
                //确定按钮
                UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                button1.tag = 100;
                button1.frame = CGRectMake(10, 210-44, 120, 44);
                [button1 setTitle:MyLocal(@"确定") forState:UIControlStateNormal];
                button1.titleLabel.font = [UIFont systemFontOfSize:18.0f];
                [button1 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
                [view2 addSubview:button1];
                //取消按钮
                UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                button2.tag = 101;
                button2.frame = CGRectMake(140, 210-44, 120, 44);
                [button2 setTitle:MyLocal(@"取消") forState:UIControlStateNormal];
                button2.titleLabel.font = [UIFont systemFontOfSize:18.0f];
                [button2 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
                [view2 addSubview:button2];
                
                [view1 addSubview:view2];
                [self.view addSubview:view1];
            }else{
                //2个文本框
                //半透明背景
                view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height)];
                view1.backgroundColor = [UIColor colorWithRed:147/255.0f green:147/255.0f blue:147/255.0f alpha:0.5f];
                
                //为view1 添加手势
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDismiss)];
                tap.delegate = self;
                tap.cancelsTouchesInView = NO;
                [view1 addGestureRecognizer:tap];
                
                //alertview背景
                UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(25,70, 270, 210)];
                view2.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"alertviewbackimage.png"]];
                
                //2个文本框
                for (int i=0; i<2; i++) {
                    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 20+i*35, 75, 30)];
                    label.text = labelTexts[i];
                    label.font = [UIFont systemFontOfSize:14.0f];
                    label.textColor = [UIColor whiteColor];
                    label.backgroundColor = [UIColor clearColor];
                    [view2 addSubview:label];
                }
                textField0 = [[UITextField alloc]initWithFrame:CGRectMake(90   , 20+0*35, 170, 30)];
                textField0.tag = 100+0;
                textField0.delegate = self;
                textField0.placeholder = placeholder;
                textField0.backgroundColor = [UIColor whiteColor];
                [view2 addSubview:textField0];
                
                textField1 = [[UITextField alloc]initWithFrame:CGRectMake(90   , 20+1*35, 170, 30)];
                textField1.tag = 100+1;
                textField1.delegate = self;
                textField1.placeholder = placeholder;
                textField1.backgroundColor = [UIColor whiteColor];
                [view2 addSubview:textField1];
                
                //确定按钮
                UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                button1.tag = 100;
                button1.frame = CGRectMake(10, 160, 120, 40);
                [button1 setTitle:MyLocal(@"确定") forState:UIControlStateNormal];
                [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [button1 setBackgroundImage:[UIImage imageNamed:@"buttonbackimage"] forState:UIControlStateNormal];
                [button1 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
                [view2 addSubview:button1];
                //取消按钮
                UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                button2.tag = 101;
                button2.frame = CGRectMake(140, 160, 120, 40);
                [button2 setTitle:MyLocal(@"取消") forState:UIControlStateNormal];
                [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [button2 setBackgroundImage:[UIImage imageNamed:@"buttonbackimage"] forState:UIControlStateNormal];
                [button2 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
                [view2 addSubview:button2];
                
                [view1 addSubview:view2];
                [self.view addSubview:view1];
            }
        }
            break;
        case 1:{
            
            if (BYT_IOS7) {
                //2个复选框
                
                //半透明背景
                view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height)];
                view1.backgroundColor = [UIColor colorWithRed:147/255.0f green:147/255.0f blue:147/255.0f alpha:0.5f];
                
                //alertview背景
                UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(25,120, 270, 210)];
                view2.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"alertviewbackimage2.png"]];
                
                //2个复选框
                for (int i=0; i<2; i++) {
                    UIButton *checkboxButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    checkboxButton.frame = CGRectMake(80, 20+i*35, 30, 30);
                    checkboxButton.tag = 100+i;
                    [checkboxButton setBackgroundImage:[UIImage imageNamed:@"disagree"] forState:UIControlStateNormal];
                    [checkboxButton setBackgroundImage:[UIImage imageNamed:@"agree"] forState:UIControlStateSelected];
                    [checkboxButton addTarget:self action:@selector(checkboxButton:) forControlEvents:UIControlEventTouchUpInside];
                    
                    [view2 addSubview:checkboxButton];
                    
                    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(115, 20+i*35, 75, 30)];
                    label.text = labelTexts[i];
                    label.font = [UIFont systemFontOfSize:14.0f];
                    label.textColor = [UIColor blackColor];
                    label.backgroundColor = [UIColor clearColor];
                    [view2 addSubview:label];
                }
                
                //确定按钮
                UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                button1.tag = 102;
                button1.frame = CGRectMake(10, 210-44, 120, 44);
                [button1 setTitle:MyLocal(@"确定") forState:UIControlStateNormal];
                button1.titleLabel.font = [UIFont systemFontOfSize:18.0f];
                [button1 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
                [view2 addSubview:button1];
                //取消按钮
                UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                button2.tag = 103;
                button2.frame = CGRectMake(140, 210-44, 120, 44);
                [button2 setTitle:MyLocal(@"取消") forState:UIControlStateNormal];
                button2.titleLabel.font = [UIFont systemFontOfSize:18.0f];

                [button2 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
                [view2 addSubview:button2];
                
                [view1 addSubview:view2];
                
                [self.view addSubview:view1];
            }else{
                //2个复选框
                
                //半透明背景
                view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height)];
                view1.backgroundColor = [UIColor colorWithRed:147/255.0f green:147/255.0f blue:147/255.0f alpha:0.5f];
                
                //alertview背景
                UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(25,120, 270, 210)];
                view2.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"alertviewbackimage.png"]];
                
                //2个复选框
                for (int i=0; i<2; i++) {
                    UIButton *checkboxButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    checkboxButton.frame = CGRectMake(80, 20+i*35, 30, 30);
                    checkboxButton.tag = 100+i;
                    [checkboxButton setBackgroundImage:[UIImage imageNamed:@"disagree"] forState:UIControlStateNormal];
                    [checkboxButton setBackgroundImage:[UIImage imageNamed:@"agree"] forState:UIControlStateSelected];
                    [checkboxButton addTarget:self action:@selector(checkboxButton:) forControlEvents:UIControlEventTouchUpInside];
                    
                    [view2 addSubview:checkboxButton];
                    
                    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(115, 20+i*35, 75, 30)];
                    label.text = labelTexts[i];
                    label.font = [UIFont systemFontOfSize:14.0f];
                    label.textColor = [UIColor whiteColor];
                    label.backgroundColor = [UIColor clearColor];
                    [view2 addSubview:label];
                }
                
                //确定按钮
                UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                button1.tag = 102;
                button1.frame = CGRectMake(10, 160, 120, 40);
                [button1 setTitle:MyLocal(@"确定") forState:UIControlStateNormal];
                [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [button1 setBackgroundImage:[UIImage imageNamed:@"buttonbackimage"] forState:UIControlStateNormal];
                [button1 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
                [view2 addSubview:button1];
                //取消按钮
                UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                button2.tag = 103;
                button2.frame = CGRectMake(140, 160, 120, 40);
                [button2 setTitle:MyLocal(@"取消") forState:UIControlStateNormal];
                [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [button2 setBackgroundImage:[UIImage imageNamed:@"buttonbackimage"] forState:UIControlStateNormal];
                [button2 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
                [view2 addSubview:button2];
                
                [view1 addSubview:view2];
                
                [self.view addSubview:view1];
                //            [[[UIApplication sharedApplication].windows objectAtIndex:0] addSubview:view1];
            }
        }
            break;
        case 2:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"您确定要发送查询亲情号码指令吗?") delegate:self cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:MyLocal(@"取消"), nil];
            alert.delegate = self;
            alert.tag = 1000;
            [alert show];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Target Action

- (void)keyboardDismiss
{
    [textField0 resignFirstResponder];
    [textField1 resignFirstResponder];
}

-(void)buttonClick:(UIButton*)button{
    switch (button.tag) {
        case 100:
            [self FamilyNumberSetWithNumber1:(textField0.text.length>0?textField0.text:@"") number2:(textField1.text.length>0?textField1.text:@"")];
            [view1 removeFromSuperview];
            
            break;
        case 101:
            [view1 removeFromSuperview];
            break;
        case 102:
            [self FamilyNumberDeleteWithNumber1:checkboxNumber0 number2:checkboxNumber1];
            [view1 removeFromSuperview];
            break;
        case 103:
            [view1 removeFromSuperview];
            break;
            
        default:
            
            break;
    }
}

-(void)checkboxButton:(UIButton*)checkbox{
    switch (checkbox.tag) {
        case 100:
            checkbox.selected = !checkbox.selected;
            checkboxNumber0 = checkbox.selected ? @"1" : @"";
            
            break;
        case 101:
            checkbox.selected = !checkbox.selected;
            checkboxNumber1 = checkbox.selected ? @"2" : @"";
            break;
            
        default:
            break;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView == _alertView) {
        self.alertView = nil;
    }
    if (alertView.tag ==1000 && buttonIndex ==0) {
        // 查询
        [self FamilyNumberQuery];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - //----------------------------

#pragma mark - WebService Action
//设置亲情号码
-(void)FamilyNumberSetWithNumber1:(NSString *)n1 number2:(NSString *)n2{
    [_hud show:YES];
    WebService *webService = [WebService newWithWebServiceAction:@"FamilyNumberSet" andDelegate:self];
    webService.tag = FamilyNumberSetWebService;
    
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"deviceID" andValue:_deviceID];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"Number1" andValue:n1];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"Number2" andValue:n2];
    
    webService.webServiceParameter = @[parameter1, parameter2,parameter3];
    [webService getWebServiceResult:@"FamilyNumberSetResult"];
}
//删除亲情号码
-(void)FamilyNumberDeleteWithNumber1:(NSString *)n1 number2:(NSString *)n2{
    [_hud show:YES];
    WebService *webService = [WebService newWithWebServiceAction:@"FamilyNumberDelete" andDelegate:self];
    webService.tag = FamilyNumberDeleteWebService;
    
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"deviceID" andValue:_deviceID];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"Number1" andValue:n1];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"Number2" andValue:n2];
    
    webService.webServiceParameter = @[parameter1, parameter2,parameter3];
    [webService getWebServiceResult:@"FamilyNumberDeleteResult"];
    
    checkboxNumber0 = @"";
    checkboxNumber1 = @"";
}

// 查询号码指令
- (void)FamilyNumberQuery
{
    [_hud show:YES];
    WebService *webService = [WebService newWithWebServiceAction:@"FamilyNumberQuery" andDelegate:self];
    webService.tag = FamilyNumberQueryWebService;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"deviceID" andValue:_deviceID];
    webService.webServiceParameter = @[parameter1];
    [webService getWebServiceResult:@"FamilyNumberQueryResult"];
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
    webService.tag = FamilyNumberResponseWebService;
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
    if ([theWebService tag] == FamilyNumberResponseWebService) {
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

- (void)back
{
    if (_timer) {
        [_timer invalidate];
        self.timer = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
