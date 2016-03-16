//
//  IssuesViewController.m
//  途强
//
//  Created by TR on 13-9-27.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

/*
设备指令下发,首先调用对应的下发接口,判断设备是否能够正确下发[(设备不在线(接口返回1001),设备ID不正确(接口返回1002),设备无返回(接口返回2001))这三种情况不能下发,直接提示用户]

除此之外,接口返回的数据就是"请求查看设备是否下发成功"这个接口的参数,判断这个接口返回数据,为空表示设备暂时还未设置成功,继续调用这个接口,直到返回有数据为止(或者30秒为止，共6次)
*/

#import "IssuesViewController.h"
//#import "RadioAlertView.h"
#import "SOSViewController.h"
#import "LocationViewController.h"
#import "WebServiceParameter.h"
#import "MBProgressHUD.h"
#import "CustomIOS7AlertView.h"
#import "IssuesCell.h"
#import "FamilyNumberSetViewController.h"
#import "OverspeedViewController.h"
#import "ShockViewController.h"
#import "CutpowerViewController.h"
#import "LowpowerViewController.h"
#import "Location2ViewController.h"
#import "HYAlertView.h"
#import "SVProgressHUD.h"
#import "LMHttpPost.h"
#import "ListenViewController.h"

@interface IssuesViewController ()<HYAlertViewDelegate>{
    //震动灵敏度设置
    UIView *view1;
    NSArray *labelTexts;
    NSString *radioButtonValue1;
    NSString *radioButtonValue2;
}

@property (strong, nonatomic) UISwitch *commandSwitch;

@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSString *type;  //余额查询 类型 参数
@property (strong, nonatomic) NSString *type2;  //远程设防撤防 类型 参数
@property (copy, nonatomic) NSString *overspeedType;// 超速报警上报方式
@property (copy, nonatomic) NSString *pulloutType;// 拔出报警上报方式

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) NSArray *images;
@property (strong, nonatomic) NSArray *HImages;

@property (strong, nonatomic) MBProgressHUD *hud;

@property (strong, nonatomic) NSString *commandID;// WebService返回的指令ID,用于调用GetResponse接口判断设备是否成功设置

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *startGetResponseTime;
@property (strong, nonatomic) UIAlertView *alertView;

@property (strong, nonatomic) UITextField *textField1;
@property (strong, nonatomic) UITextField *textField2;
@property (strong, nonatomic) UITextField *textField3;
@end

@implementation IssuesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.deviceID = [USER_DEFAULT objectForKey:@"DeviceID"];
        NSString *type = [USER_DEFAULT objectForKey:@"Type"];
        self.overspeedType = @"1";
        self.pulloutType = @"1";
        self.title = [NSString stringWithFormat:@"%@%@", MyLocal(@"下发指令集:"), type];
        if ([type isEqualToString:@"ET100"] || [type isEqualToString:@"PA200"]) {
            self.titles = @[MyLocal(@"SOS号码设置"), MyLocal(@"震动灵敏度设置"), MyLocal(@"位移报警设置"),MyLocal(@"震动报警"),MyLocal(@"断电报警"),MyLocal(@"低电报警"),MyLocal(@"超速报警"), MyLocal(@"延时设防设置"), MyLocal(@"震动检测时间"),MyLocal(@"中心号码")];
            self.images = @[@"sos", @"vibration", @"location", @"vibrationwarm_old",@"cutpower_alarm",@"lowpower_alarm",@"overspeed", @"zidongshefang", @"zhendongyanshi",@"zhongxinhaoma"];
       }
   //          else if ([type isEqualToString:@"ET110"]) {
//            self.titles = @[@"SOS号码设置", @"位移报警设置", @"断油电", @"恢复油电", @"远程设防/撤防",@"重启",@"中心号码", @"超速报警"];
//            self.images = @[@"sos", @"location", @"cutoil_old", @"restoreoil_old", @"removal_old",@"restart",@"zhongxinhaoma",@"overspeed"];
//        }
            else if ([type isEqualToString:@"ET130"]||[type isEqualToString:@"ET110"]) {
            self.titles = @[MyLocal(@"SOS号码设置"), MyLocal(@"设防模式"), MyLocal(@"远程设防/撤防"), MyLocal(@"震动灵敏度设置"), MyLocal(@"位移报警设置"), MyLocal(@"震动报警"), MyLocal(@"切断电源"), MyLocal(@"恢复电源"), MyLocal(@"断电报警"), MyLocal(@"低电报警"), MyLocal(@"超速报警"), MyLocal(@"延时设防设置"), MyLocal(@"震动检测时间"),MyLocal(@"中心号码")];
            self.images = @[@"sos", @"shenfangmoshi", @"removal_old",@"vibration", @"location", @"vibrationwarm_old", @"cutpower",  @"recover_power", @"cutpower_alarm",@"lowpower_alarm",@"overspeed", @"zidongshefang", @"zhendongyanshi",@"zhongxinhaoma"];
        } else if ([type isEqualToString:@"ET150"]) {
            self.titles = @[MyLocal(@"SOS号码设置"), MyLocal(@"位移报警设置"), MyLocal(@"切断电源"), MyLocal(@"恢复电源"), MyLocal(@"设防模式"), MyLocal(@"远程设防/撤防"), MyLocal(@"震动报警"),MyLocal(@"断电报警"),MyLocal(@"低电报警"), MyLocal(@"超速报警"), MyLocal(@"延时设防设置"), MyLocal(@"震动检测时间"),MyLocal(@"中心号码")];
            self.images = @[@"sos", @"location", @"cutpower", @"recover_power", @"shenfangmoshi", @"removal_old", @"vibrationwarm_old", @"cutpower_alarm",@"lowpower_alarm",@"overspeed", @"zidongshefang", @"zhendongyanshi",@"zhongxinhaoma"];
        } else if ([type isEqualToString:@"ET200"]) {
            self.titles = @[MyLocal(@"SOS号码设置"), MyLocal(@"位移报警设置"),MyLocal(@"震动报警"),MyLocal(@"远程设防/撤防"), MyLocal(@"切断电源"), MyLocal(@"恢复电源"), MyLocal(@"设防模式"), MyLocal(@"断电报警"), MyLocal(@"低电报警"), MyLocal(@"超速报警"), MyLocal(@"延时设防设置"), MyLocal(@"震动检测时间"),MyLocal(@"中心号码")];
            self.images = @[@"sos",  @"location", @"vibrationwarm_old", @"removal_old", @"cutpower", @"recover_power", @"shenfangmoshi",  @"cutpower_alarm",@"lowpower_alarm",@"overspeed", @"zidongshefang", @"zhendongyanshi",@"zhongxinhaoma"];
        } else if ([type isEqualToString:@"GT600"]) {
            self.titles = @[MyLocal(@"SOS号码设置"), MyLocal(@"断油电"), MyLocal(@"恢复油电"),MyLocal(@"震动报警"), MyLocal(@"重启"),MyLocal( @"延时设防设置"), MyLocal(@"震动检测时间"),MyLocal(@"中心号码"),MyLocal(@"超速报警"), MyLocal(@"位移报警设置"), MyLocal(@"低电报警"), MyLocal(@"断电报警")];
            self.images = @[@"sos", @"cutoil_old", @"restoreoil_old", @"vibrationwarm_old", @"restart", @"zidongshefang", @"zhendongyanshi",@"zhongxinhaoma",@"overspeed",  @"location", @"lowpower_alarm", @"cutpower_alarm"];
        } else if ([type isEqualToString:@"GT07"] || [type isEqualToString:@"GT06"] || [type isEqualToString:@"GT06A"] || [type isEqualToString:@"GT06B"] || [type isEqualToString:@"GT06N"] || [type isEqualToString:@"GT06M"] || [type isEqualToString:@"TR06"] || [type isEqualToString:@"TR06B"]) {
            self.titles = @[MyLocal(@"SOS号码设置"),MyLocal(@"断油电"), MyLocal(@"恢复油电"), MyLocal(@"重启"),MyLocal(@"中心号码"),MyLocal(@"超速报警")];
            self.images = @[@"sos", @"cutoil_old", @"restoreoil_old", @"restart",@"zhongxinhaoma",@"overspeed"];
        } else if ([type isEqualToString:@"GPS007"] ||  [type isEqualToString:@"GT03A"] || [type isEqualToString:@"GT03B"] || [type isEqualToString:@"TR03A"] || [type isEqualToString:@"TR03B"] || [type isEqualToString:@"TR03C"] || [type isEqualToString:@"WK03"]) {
            self.titles = @[MyLocal(@"SOS号码设置"),MyLocal( @"SOS号码同步")];
            self.images = @[@"sos", @"sossynchronous_old"];
        } else if ([type isEqualToString:@"GT05"]) {
            self.titles = @[MyLocal(@"SOS号码设置"), MyLocal(@"位移报警设置"), MyLocal(@"重启")];
            self.images = @[@"sos", @"location", @"restart"];
        } else if ([type isEqualToString:@"GT03D"]) {
            self.titles = @[MyLocal(@"SOS号码设置"),MyLocal(@"SOS号码同步"),MyLocal(@"远程设防/撤防",@"重启")];
            self.images = @[@"sos",@"sossynchronous_old",@"removal_old",@"restart"];
        } else if ([type isEqualToString:@"TR03D"]) {
            self.titles = @[MyLocal(@"SOS号码设置"),MyLocal(@"SOS号码同步"),MyLocal(@"震动报警"),MyLocal(@"远程设防/撤防"), MyLocal(@"重启")];
            self.images = @[@"sos",@"sossynchronous_old",@"vibrationwarm_old",@"removal_old",@"restart"];
        } else if ([type isEqualToString:@"GT220"] || [type isEqualToString:@"V10"]) {
            self.titles = @[MyLocal(@"SOS号码设置"), MyLocal(@"位移报警设置"), MyLocal(@"震动灵敏度设置"),MyLocal( @"断油电"), MyLocal(@"恢复油电"), MyLocal(@"重启"), MyLocal(@"延时设防设置"), MyLocal(@"震动检测时间"),MyLocal(@"中心号码"),MyLocal(@"震动报警"),MyLocal(@"超速报警"), MyLocal(@"断电报警"), MyLocal(@"低电报警"), MyLocal(@"余额查询")];
            self.images = @[@"sos", @"location", @"vibration", @"cutoil_old", @"restoreoil_old", @"restart", @"zidongshefang", @"zhendongyanshi",@"zhongxinhaoma",@"vibrationwarm_old", @"overspeed", @"cutpower_alarm",@"lowpower_alarm",@"momey_old"];
        } else if ([type isEqualToString:@"GT250"]) {
            self.titles = @[MyLocal(@"SOS号码设置"), MyLocal(@"位移报警设置"), MyLocal(@"断油电"), MyLocal(@"恢复油电"), MyLocal(@"设防模式"), MyLocal(@"远程设防/撤防"),MyLocal(@"震动报警")];
            self.images = @[@"sos", @"location",  @"cutoil_old", @"restoreoil_old", @"shenfangmoshi", @"removal_old",@"vibrationwarm_old"];
        }else if ([type isEqualToString:@"GT100"] || [type isEqualToString:@"PA100"]) {
            self.titles = @[MyLocal(@"SOS号码设置"), MyLocal(@"位移报警设置"), MyLocal(@"震动灵敏度设置"), MyLocal(@"震动报警"), MyLocal(@"断油电"), MyLocal(@"恢复油电"), MyLocal(@"重启"), MyLocal(@"延时设防设置"), MyLocal(@"震动检测时间"),MyLocal(@"中心号码"), MyLocal(@"超速报警")];
            self.images = @[@"sos", @"location", @"vibration", @"vibrationwarm_old", @"cutoil_old", @"restoreoil_old", @"restart", @"zidongshefang", @"zhendongyanshi",@"zhongxinhaoma", @"overspeed"];
        } else if ([type isEqualToString:@"GT300"] || [type isEqualToString:@"TR300"]) {
            self.titles = @[MyLocal(@"SOS号码设置"), MyLocal(@"SOS号码同步"), MyLocal(@"亲情号码设置"), MyLocal(@"震动报警"), MyLocal(@"远程设防/撤防"), MyLocal(@"重启")];
            self.images = @[@"sos", @"sossynchronous_old", @"family_old", @"vibrationwarm_old", @"removal_old", @"restart"];
        } else if ([type isEqualToString:@"GT12"]) {
            self.titles = @[MyLocal(@"SOS号码设置"), MyLocal(@"断油电"),MyLocal( @"恢复油电"), MyLocal(@"重启")];
            self.images = @[@"sos", @"cutoil_old", @"restoreoil_old", @"restart"];
        } else if ([type isEqualToString:@"GT500"]) {
            self.titles = @[MyLocal(@"SOS号码设置"), MyLocal(@"设防模式"), MyLocal(@"远程设防/撤防"), MyLocal(@"位移报警设置"), MyLocal(@"超速报警"), MyLocal(@"震动报警"), MyLocal(@"拔出报警"), MyLocal(@"ACC电压设置"), MyLocal(@"延时设防设置"), MyLocal(@"震动检测时间"), MyLocal(@"震动灵敏度设置"), MyLocal(@"重启")];
            self.images = @[@"sos", @"shenfangmoshi", @"removal_old", @"location", @"overspeed", @"vibrationwarm_old", @"pullout", @"acc_dianya", @"zidongshefang", @"zhendongyanshi", @"vibration", @"restart"];
        } else if ([type isEqualToString:@"GT500S"]){
            self.titles = @[MyLocal(@"SOS号码设置"), MyLocal(@"远程设防/撤防"), MyLocal(@"远程聆听"), MyLocal(@"位移报警设置"), MyLocal(@"超速报警"), MyLocal(@"震动报警"), MyLocal(@"断电报警"), MyLocal(@"延时设防设置"), MyLocal(@"震动检测时间"), MyLocal(@"震动灵敏度设置"), MyLocal(@"重启")];
            self.images = @[@"sos", @"removal_old", @"listen", @"location", @"overspeed", @"vibrationwarm_old", @"pullout", @"zidongshefang", @"zhendongyanshi", @"vibration", @"restart"];
        }else {
            self.titles = @[MyLocal(@"SOS号码设置"), MyLocal(@"位移报警设置"), MyLocal(@"断油电"), MyLocal(@"恢复油电"), MyLocal(@"重启")];
            self.images = @[@"sos", @"location", @"cutoil_old", @"restoreoil_old", @"restart"];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    IOS7;
    
    //自定义AlertView的数据
    labelTexts = @[MyLocal(@"震动灵敏度一(最高)"),MyLocal(@"震动灵敏度二"),MyLocal(@"震动灵敏度三"),MyLocal(@"震动灵敏度四(最低)")];
    
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

#pragma mark - Target Actions

- (void)back
{
    if (_timer) {
        [_timer invalidate];
        self.timer = nil;
    }
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
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    IssuesCell *cell;
    if (cell == nil) {
        cell = [[IssuesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString *imageName = _images[indexPath.row];
    NSString *labelName = _titles[indexPath.row];
    cell.imageName = imageName;
    cell.labelName = labelName;
    if ([labelName isEqualToString:MyLocal(@"ACC电压设置")] || [labelName isEqualToString:MyLocal(@"延时设防设置")] || [labelName isEqualToString:MyLocal(@"震动检测时间")] || [labelName isEqualToString:MyLocal(@"中心号码")]|| [labelName isEqualToString:MyLocal(@"远程聆听")]) {
        [cell SetViewImageFrame:CGRectMake(15, 10, 40, 40)];
       
    }else{
        [cell SetViewImageDefaultFrame];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_timer) {
        [_timer invalidate];
        self.timer = nil;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    IssuesCell *cell = (IssuesCell *)[_tableView cellForRowAtIndexPath:indexPath];
    NSString *title = cell.labelName;
    
    if ([title isEqualToString:MyLocal(@"SOS号码设置")]) {
        SOSViewController *sos = [[SOSViewController alloc] init];
        [self.navigationController pushViewController:sos animated:YES];
    } else if ([title isEqualToString:MyLocal(@"震动灵敏度设置")]) {
        
        if (BYT_IOS7) {
            //半透明背景
            view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height)];
            view1.backgroundColor = [UIColor colorWithRed:147/255.0f green:147/255.0f blue:147/255.0f alpha:0.5f];
            
            //alertview背景
            UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(25,70, 270, 210)];
            view2.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"alertviewbackimage2.png"]];
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 250, 30)];
            label.text = MyLocal(@"请选择震动灵敏度等级");
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:20.0f];
            label.textColor = [UIColor blackColor];
            label.backgroundColor = [UIColor clearColor];
            
            [view2 addSubview:label];
            
            //文本框
            for (int i=0; i<4; i++) {
                //4个单选按钮
                RadioButton *radioButton = [[RadioButton alloc]initWithGroupId:@"firstgroup" index:i];
                radioButton.frame = CGRectMake(30, 34+30*i, 22, 22);
                [view2 addSubview:radioButton];
                [RadioButton addObserverForGroupId:@"firstgroup" observer:self];
                
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(70, 30+i*30, 150, 30)];
                label.text = labelTexts[i];
                label.font = [UIFont systemFontOfSize:14.0f];
                label.textColor = [UIColor blackColor];
                label.backgroundColor = [UIColor clearColor];
                [view2 addSubview:label];
            }
            
            //确定按钮
            UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button1.tag = 1000;
            button1.frame = CGRectMake(10, 210-44, 120, 44);
            [button1 setTitle:MyLocal(@"确定") forState:UIControlStateNormal];
            button1.titleLabel.font = [UIFont systemFontOfSize:18.0f];
            [button1 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [view2 addSubview:button1];
            //取消按钮
            UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button2.tag = 1001;
            button2.frame = CGRectMake(140, 210-44, 120, 44);
            [button2 setTitle:MyLocal(@"取消") forState:UIControlStateNormal];
            button2.titleLabel.font = [UIFont systemFontOfSize:18.0f];
            [button2 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [view2 addSubview:button2];
            
            [view1 addSubview:view2];
            [self.view addSubview:view1];
        }else{
            //半透明背景
            view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height)];
            view1.backgroundColor = [UIColor colorWithRed:147/255.0f green:147/255.0f blue:147/255.0f alpha:0.5f];
            
            //alertview背景
            UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(25,70, 270, 210)];
            view2.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"alertviewbackimage.png"]];
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 250, 30)];
            label.text = MyLocal(@"请选择震动灵敏度等级");
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:20.0f];
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = [UIColor clearColor];
            
            [view2 addSubview:label];
            
            //文本框
            for (int i=0; i<4; i++) {
                //4个单选按钮
                RadioButton *radioButton = [[RadioButton alloc]initWithGroupId:@"firstgroup" index:i];
                radioButton.frame = CGRectMake(30, 34+30*i, 22, 22);
                [view2 addSubview:radioButton];
                [RadioButton addObserverForGroupId:@"firstgroup" observer:self];
                
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(70, 30+i*30, 150, 30)];
                label.text = labelTexts[i];
                label.font = [UIFont systemFontOfSize:14.0f];
                label.textColor = [UIColor whiteColor];
                label.backgroundColor = [UIColor clearColor];
                [view2 addSubview:label];
            }
            
            //确定按钮
            UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button1.tag = 1000;
            button1.frame = CGRectMake(10, 160, 120, 40);
            [button1 setTitle:MyLocal(@"确定") forState:UIControlStateNormal];
            [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button1 setBackgroundImage:[UIImage imageNamed:@"buttonbackimage"] forState:UIControlStateNormal];
            [button1 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [view2 addSubview:button1];
            //取消按钮
            UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button2.tag = 1001;
            button2.frame = CGRectMake(140, 160, 120, 40);
            [button2 setTitle:MyLocal(@"取消") forState:UIControlStateNormal];
            [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button2 setBackgroundImage:[UIImage imageNamed:@"buttonbackimage"] forState:UIControlStateNormal];
            [button2 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [view2 addSubview:button2];
            
            [view1 addSubview:view2];
            [self.view addSubview:view1];
        }
    } else if ([title isEqualToString:MyLocal(@"位移报警设置")]) {
//        LocationViewController *location = [[LocationViewController alloc] init];
//        [self.navigationController pushViewController:location animated:YES];
        Location2ViewController *location2 = [[Location2ViewController alloc] init];
        [self.navigationController pushViewController:location2 animated:YES];
    } else if ([title isEqualToString:MyLocal(@"重启")]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"您确定要发送重启设备指令吗?") delegate:self cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:MyLocal(@"取消"), nil];
        //需提示输入账号密码  只支持5.0+
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        [alert textFieldAtIndex:0].placeholder = MyLocal(@"请输入密码");
        [alert textFieldAtIndex:0].secureTextEntry = YES;
        alert.delegate = self;
        alert.tag = 2;
        [alert show];
    } else if ([title isEqualToString:MyLocal(@"断油电")]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"您确定下发断油电指令吗?") delegate:self cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:MyLocal(@"取消"), nil];
        //需提示输入账号密码  只支持5.0+
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        [alert textFieldAtIndex:0].placeholder = MyLocal(@"请输入密码");
        [alert textFieldAtIndex:0].secureTextEntry = YES;
        alert.tag = 3;
        alert.delegate = self;
        [alert show];
    } else if ([title isEqualToString:MyLocal(@"恢复油电")]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"您确定下发恢复油电指令吗?") delegate:self cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:MyLocal(@"取消"), nil];
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        [alert textFieldAtIndex:0].placeholder = MyLocal(@"请输入密码");
        [alert textFieldAtIndex:0].secureTextEntry = YES;
        alert.delegate = self;
        alert.tag = 4;
        [alert show];
    }  else if ([title isEqualToString:MyLocal(@"切断电源")]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"您确定下发切断电源指令吗?") delegate:self cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:MyLocal(@"取消"), nil];
        //需提示输入账号密码  只支持5.0+
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        [alert textFieldAtIndex:0].placeholder = MyLocal(@"请输入密码");
        [alert textFieldAtIndex:0].secureTextEntry = YES;
        alert.tag = 11;
        alert.delegate = self;
        [alert show];
    } else if ([title isEqualToString:MyLocal(@"恢复电源")]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"您确定下发恢复电源指令吗?") delegate:self cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:MyLocal(@"取消"), nil];
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        [alert textFieldAtIndex:0].placeholder = MyLocal(@"请输入密码");
        [alert textFieldAtIndex:0].secureTextEntry = YES;
        alert.delegate = self;
        alert.tag = 12;
        [alert show];
    } else if ([title isEqualToString:MyLocal(@"查询参数")]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MyLocal(@"您确定要发送查询设备参数指令吗?") delegate:self cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:MyLocal(@"取消"), nil];
        alert.delegate = self;
        alert.tag = 5;
        [alert show];
    }else if ([title isEqualToString:MyLocal(@"余额查询")]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:MyLocal(@"请选择移动卡或联通卡") delegate:self cancelButtonTitle:MyLocal(@"取消") otherButtonTitles:MyLocal(@"联通"),MyLocal(@"移动"), nil];
        alert.delegate = self;
        alert.tag = 6;
        [alert show];
    }else if ([title isEqualToString:MyLocal(@"亲情号码设置")]){
        FamilyNumberSetViewController *familyNumberVC = [[FamilyNumberSetViewController alloc] init];
        [self.navigationController pushViewController:familyNumberVC animated:YES];
    }else if ([title isEqualToString:MyLocal(@"远程设防/撤防")]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:MyLocal(@"你确定要下发远程设防/撤防指令吗？") delegate:self cancelButtonTitle:MyLocal(@"取消") otherButtonTitles:MyLocal(@"远程设防"), MyLocal(@"远程撤防"), nil];
        alert.tag = 7;
        alert.delegate = self;
        [alert show];
    }else if ([title isEqualToString:MyLocal(@"SOS号码同步")]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:MyLocal(@"你确定要下发SOS号码同步指令吗？") delegate:self cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:MyLocal(@"取消"), nil];
        alert.delegate = self;
        alert.tag = 9;
        [alert show];
    }else if ([title isEqualToString:MyLocal(@"设防模式")]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:MyLocal(@"你确定要下发设防模式指令吗？") delegate:self cancelButtonTitle:MyLocal(@"取消") otherButtonTitles:MyLocal(@"自动设防/撤防"),MyLocal(@"手动设防/撤防"), nil];
        alert.delegate = self;
        alert.tag = 10;
        [alert show];
        
    }else if ([title isEqualToString:MyLocal(@"超速报警")]){
        OverspeedViewController *overspeedVC = [[OverspeedViewController alloc] init];
        [self.navigationController pushViewController:overspeedVC animated:YES];
    }else if ([title isEqualToString:MyLocal(@"震动报警")]){
        ShockViewController *shockVC = [[ShockViewController alloc] init];
        [self.navigationController pushViewController:shockVC animated:YES];
    }else if ([title isEqualToString:MyLocal(@"断电报警")]){
        CutpowerViewController *cutpowerVC = [[CutpowerViewController alloc] init];
        [self.navigationController pushViewController:cutpowerVC animated:YES];
    }else if ([title isEqualToString:MyLocal(@"低电报警")]){
        LowpowerViewController *lowpowerVC = [[LowpowerViewController alloc] init];
        [self.navigationController pushViewController:lowpowerVC animated:YES];
    }else if ([title isEqualToString:MyLocal(@"拔出报警")]) {
        //半透明背景
        view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height)];
        view1.backgroundColor = [UIColor colorWithRed:147/255.0f green:147/255.0f blue:147/255.0f alpha:0.5f];
        
        //alertview背景
        UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(25, 70, 270, 210)];
        [view1 addSubview:view2];
        [self.view addSubview:view1];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 270, 30)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:18];
        titleLabel.text = MyLocal(@"设置拔出报警");
        [view2 addSubview:titleLabel];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, 75, 30)];
        label1.text = MyLocal(@"报警开关");
        label1.font = [UIFont systemFontOfSize:14.0f];
        label1.textAlignment = NSTextAlignmentCenter;
        label1.backgroundColor = [UIColor clearColor];
        [view2 addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(15, 70, 75, 30)];
        label2.text = MyLocal(@"上报方式");
        label2.font = [UIFont systemFontOfSize:14.0f];
        label2.textAlignment = NSTextAlignmentCenter;
        label2.backgroundColor = [UIColor clearColor];
        [view2 addSubview:label2];
        
        self.commandSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(120, 40, 70, 30)];
        _commandSwitch.onTintColor = [UIColor blueColor];
        _commandSwitch.on = YES;
        [view2 addSubview:_commandSwitch];
        
        RadioButton *radioButton1 = [[RadioButton alloc]initWithGroupId:@"pulloutSet" index:1000];
        radioButton1.frame = CGRectMake(120, 74, 22, 22);
        [view2 addSubview:radioButton1];
        UILabel *typeLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(145, 70, 50, 30)];
        typeLabel1.text = MyLocal(@"平台");
        typeLabel1.font = [UIFont systemFontOfSize:11.0];
        typeLabel1.backgroundColor = [UIColor clearColor];
        [view2 addSubview:typeLabel1];
        
        RadioButton *radioButton2 = [[RadioButton alloc]initWithGroupId:@"pulloutSet" index:1001];
        radioButton2.frame = CGRectMake(120, 104, 22, 22);
        radioButton2.button.selected = YES;
        [view2 addSubview:radioButton2];
        UILabel *typeLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(145, 100, 70, 30)];
        typeLabel2.text = MyLocal(@"平台+短信");
        typeLabel2.font = [UIFont systemFontOfSize:11.0];
        typeLabel2.backgroundColor = [UIColor clearColor];
        [view2 addSubview:typeLabel2];
        
        RadioButton *radioButton3 = [[RadioButton alloc]initWithGroupId:@"pulloutSet" index:1002];
        radioButton3.frame = CGRectMake(120, 134, 22, 22);
        [view2 addSubview:radioButton3];
        UILabel *typeLabel3 = [[UILabel alloc]initWithFrame:CGRectMake(145, 130, 110, 30)];
        typeLabel3.text = MyLocal(@"平台+短信+电话");
        typeLabel3.font = [UIFont systemFontOfSize:11.0];
        typeLabel3.backgroundColor = [UIColor clearColor];
        [view2 addSubview:typeLabel3];
        [RadioButton addObserverForGroupId:@"pulloutSet" observer:self];
        
         if (BYT_IOS7) {
            view2.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"alertviewbackimage2.png"]];
             titleLabel.textColor = [UIColor blackColor];
            label1.textColor = [UIColor blackColor];
            label2.textColor = [UIColor blackColor];
            typeLabel1.textColor = [UIColor blackColor];
            typeLabel2.textColor = [UIColor blackColor];
            typeLabel3.textColor = [UIColor blackColor];
            
            UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button1.tag = 4000;
            button1.frame = CGRectMake(10, 210-44, 120, 44);
            [button1 setTitle:MyLocal(@"确定") forState:UIControlStateNormal];
            button1.titleLabel.font = [UIFont systemFontOfSize:18.0f];
            [button1 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [view2 addSubview:button1];
            
            UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button2.tag = 4001;
            button2.frame = CGRectMake(140, 210-44, 120, 44);
            [button2 setTitle:MyLocal(@"取消") forState:UIControlStateNormal];
            button2.titleLabel.font = [UIFont systemFontOfSize:18.0f];
            [button2 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [view2 addSubview:button2];
        }else{
            view2.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"alertviewbackimage.png"]];
            titleLabel.textColor = [UIColor whiteColor];
            label1.textColor = [UIColor whiteColor];
            label2.textColor = [UIColor whiteColor];
            typeLabel1.textColor = [UIColor whiteColor];
            typeLabel2.textColor = [UIColor whiteColor];
            typeLabel3.textColor = [UIColor whiteColor];
            
            //确定按钮
            UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button1.tag = 4000;
            button1.frame = CGRectMake(10, 160, 120, 40);
            [button1 setTitle:MyLocal(@"确定") forState:UIControlStateNormal];
            [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button1 setBackgroundImage:[UIImage imageNamed:@"buttonbackimage"] forState:UIControlStateNormal];
            [button1 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [view2 addSubview:button1];
            //取消按钮
            UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button2.tag = 4001;
            button2.frame = CGRectMake(140, 160, 120, 40);
            [button2 setTitle:MyLocal(@"取消") forState:UIControlStateNormal];
            [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button2 setBackgroundImage:[UIImage imageNamed:@"buttonbackimage"] forState:UIControlStateNormal];
            [button2 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [view2 addSubview:button2];
        }
    }else if ([title isEqualToString:MyLocal(@"ACC电压设置")]){
        HYAlertView *alert = [[HYAlertView alloc]initWithWidth:270 WithTitle:MyLocal(@"ACC电压设置")];
        alert.titleColor = [UIColor blackColor];
        alert.delegate = self;
        alert.tag = indexPath.row+1;
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, alert.width, 150)];
        view.backgroundColor = [UIColor whiteColor];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 75, 30)];
        label1.text = MyLocal(@"熄火电压:");
        label1.font = [UIFont systemFontOfSize:12.0f];
        label1.textAlignment = NSTextAlignmentCenter;
        label1.backgroundColor = [UIColor clearColor];
        [view addSubview:label1];
        
        self.textField1 = [[UITextField alloc]initWithFrame:CGRectMake(90, label1.frame.origin.y, 60, 25)];
        _textField1.borderStyle = UITextBorderStyleLine;
        [view addSubview:_textField1];
        
        UILabel *detailLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(_textField1.frame.origin.x+_textField1.frame.size.width, label1.frame.origin.y, 115, 30)];
        detailLabel1.text = MyLocal(@"V    (默认电压13.2V)");
        detailLabel1.font = [UIFont systemFontOfSize:12.0f];
        detailLabel1.textAlignment = NSTextAlignmentCenter;
        detailLabel1.backgroundColor = [UIColor clearColor];
        [view addSubview:detailLabel1];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, 75, 30)];
        label2.text = MyLocal(@"点火电压:");
        label2.font = [UIFont systemFontOfSize:12.0f];
        label2.textAlignment = NSTextAlignmentCenter;
        label2.backgroundColor = [UIColor clearColor];
        [view addSubview:label2];
        
        self.textField2 = [[UITextField alloc]initWithFrame:CGRectMake(90, label2.frame.origin.y+2.5, 60, 25)];
        _textField2.borderStyle = UITextBorderStyleLine;
        [view addSubview:_textField2];
        
        UILabel *detailLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(_textField2.frame.origin.x+_textField2.frame.size.width, label2.frame.origin.y, detailLabel1.frame.size.width, 30)];
        detailLabel2.text = MyLocal(@"V    (默认电压13.5V)");
        detailLabel2.font = [UIFont systemFontOfSize:12.0f];
        detailLabel2.textAlignment = NSTextAlignmentCenter;
        detailLabel2.backgroundColor = [UIColor clearColor];
        [view addSubview:detailLabel2];
        
        
        UIButton *defaultButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        defaultButton.frame = CGRectMake(70, label2.frame.origin.y+label2.frame.size.height+10, 130, 30);
        [defaultButton setTitle:NSLocalizedString(@"恢复默认值", nil) forState:UIControlStateNormal];
        [defaultButton setTitleColor:[UIColor colorWithRed:32.0/255.0 green:145.0/255.0 blue:250.0/255.0 alpha:1] forState:UIControlStateNormal];
        [view addSubview:defaultButton];
        [defaultButton addTarget:self action:@selector(DefaultButton:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *downLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 250, 60)];
        downLabel.text = MyLocal(@"备注:请按实际车辆点火或熄火电压设置(非专业人员请勿操作)");
        downLabel.numberOfLines = 0;
        downLabel.font = [UIFont systemFontOfSize:12.0f];
        downLabel.textAlignment = NSTextAlignmentCenter;
        downLabel.backgroundColor = [UIColor clearColor];
        [view addSubview:downLabel];
        
        [alert Show:view];
    }else if ([title isEqualToString:MyLocal(@"延时设防设置")]){
        HYAlertView *alert = [[HYAlertView alloc]initWithWidth:270 WithTitle:MyLocal(@"延时设防设置")];
        alert.titleColor = [UIColor blackColor];
        alert.delegate = self;
        alert.tag = indexPath.row+1;
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, alert.width, 90)];
        view.backgroundColor = [UIColor whiteColor];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 95, 30)];
        label1.text = MyLocal(@"延时设防时间:");
        label1.font = [UIFont systemFontOfSize:14.0f];
        label1.textAlignment = NSTextAlignmentCenter;
        label1.backgroundColor = [UIColor clearColor];
        [view addSubview:label1];
        
        self.textField1 = [[UITextField alloc]initWithFrame:CGRectMake(label1.frame.origin.x+label1.frame.size.width, label1.frame.origin.y, 60, 25)];
        _textField1.borderStyle = UITextBorderStyleLine;
        _textField1.placeholder = @"1-60";
        [view addSubview:_textField1];
        
        UILabel *detailLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(_textField1.frame.origin.x+_textField1.frame.size.width, label1.frame.origin.y, 20, 30)];
        detailLabel1.text = MyLocal(@"分");
        detailLabel1.font = [UIFont systemFontOfSize:14.0f];
        detailLabel1.textAlignment = NSTextAlignmentCenter;
        detailLabel1.backgroundColor = [UIColor clearColor];
        [view addSubview:detailLabel1];
        
        UIButton *defaultButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        defaultButton.frame = CGRectMake(70, label1.frame.origin.y+label1.frame.size.height+10, 130, 30);
        [defaultButton setTitle:NSLocalizedString(@"恢复默认值", nil) forState:UIControlStateNormal];
        [defaultButton setTitleColor:[UIColor colorWithRed:32.0/255.0 green:145.0/255.0 blue:250.0/255.0 alpha:1] forState:UIControlStateNormal];
        [view addSubview:defaultButton];
        [defaultButton addTarget:self action:@selector(DefaultButton1:) forControlEvents:UIControlEventTouchUpInside];
        
        [alert Show:view];
    }else if ([title isEqualToString:MyLocal(@"震动检测时间")]){
        HYAlertView *alert = [[HYAlertView alloc]initWithWidth:270 WithTitle:MyLocal(@"震动检测时间")];
        alert.titleColor = [UIColor blackColor];
        alert.delegate = self;
        alert.tag = indexPath.row+1;
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, alert.width, 150)];
        view.backgroundColor = [UIColor whiteColor];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 75, 30)];
        label1.text = MyLocal(@"检测时间:");
        label1.font = [UIFont systemFontOfSize:14.0f];
        label1.textAlignment = NSTextAlignmentCenter;
        label1.backgroundColor = [UIColor clearColor];
        [view addSubview:label1];
        
        self.textField1 = [[UITextField alloc]initWithFrame:CGRectMake(90, label1.frame.origin.y, 60, 25)];
        _textField1.borderStyle = UITextBorderStyleLine;
        _textField1.keyboardType = UIKeyboardTypeNumberPad;
        _textField1.placeholder = @"10-300";
        [view addSubview:_textField1];
        
        UILabel *detailLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(_textField1.frame.origin.x+_textField1.frame.size.width, label1.frame.origin.y, 20, 30)];
        detailLabel1.text = MyLocal(@"秒");
        detailLabel1.font = [UIFont systemFontOfSize:14.0f];
        detailLabel1.textAlignment = NSTextAlignmentCenter;
        detailLabel1.backgroundColor = [UIColor clearColor];
        [view addSubview:detailLabel1];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(15, label1.frame.origin.y+label1.frame.size.height+10, 75, 30)];
        label2.text = MyLocal(@"报警延时:");
        label2.font = [UIFont systemFontOfSize:14.0f];
        label2.textAlignment = NSTextAlignmentCenter;
        label2.backgroundColor = [UIColor clearColor];
        [view addSubview:label2];
        
        self.textField2 = [[UITextField alloc]initWithFrame:CGRectMake(90, label2.frame.origin.y+2.5, 60, 25)];
        _textField2.keyboardType = UIKeyboardTypeNumberPad;

        _textField2.borderStyle = UITextBorderStyleLine;
        _textField2.placeholder = @"10-300";
        [view addSubview:_textField2];
        
        UILabel *detailLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(_textField2.frame.origin.x+_textField2.frame.size.width, label2.frame.origin.y, detailLabel1.frame.size.width, 30)];
        detailLabel2.text = MyLocal(@"秒");
        detailLabel2.font = [UIFont systemFontOfSize:14.0f];
        detailLabel2.textAlignment = NSTextAlignmentCenter;
        detailLabel2.backgroundColor = [UIColor clearColor];
        [view addSubview:detailLabel2];
        
        UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(15, label2.frame.origin.y+label2.frame.size.height+10, 75, 30)];
        label3.text = MyLocal(@"报警间隔:");
        label3.font = [UIFont systemFontOfSize:14.0f];
        label3.textAlignment = NSTextAlignmentCenter;
        label3.backgroundColor = [UIColor clearColor];
        [view addSubview:label3];
        
        self.textField3 = [[UITextField alloc]initWithFrame:CGRectMake(90, label3.frame.origin.y+2.5, 60, 25)];
        _textField3.borderStyle = UITextBorderStyleLine;
        _textField3.placeholder = @"1-3000";
        _textField3.keyboardType = UIKeyboardTypeNumberPad;
        [view addSubview:_textField3];
        
        UILabel *detailLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(_textField3.frame.origin.x+_textField3.frame.size.width, label3.frame.origin.y, detailLabel1.frame.size.width, 30)];
        detailLabel3.text = MyLocal(@"分");
        detailLabel3.font = [UIFont systemFontOfSize:14.0f];
        detailLabel3.textAlignment = NSTextAlignmentCenter;
        detailLabel3.backgroundColor = [UIColor clearColor];
        [view addSubview:detailLabel3];
        
        UIButton *defaultButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        defaultButton.frame = CGRectMake(70, label3.frame.origin.y+label3.frame.size.height+10, 130, 30);
        [defaultButton setTitle:NSLocalizedString(@"恢复默认值", nil) forState:UIControlStateNormal];
        [defaultButton setTitleColor:[UIColor colorWithRed:32.0/255.0 green:145.0/255.0 blue:250.0/255.0 alpha:1] forState:UIControlStateNormal];
        [view addSubview:defaultButton];
        [defaultButton addTarget:self action:@selector(DefaultButton2:) forControlEvents:UIControlEventTouchUpInside];
        
        [alert Show:view];
        
    }else if ([title isEqualToString:MyLocal(@"中心号码")]){
        HYAlertView *alert = [[HYAlertView alloc]initWithWidth:270 WithTitle:MyLocal(@"中心号码")];
        alert.titleColor = [UIColor blackColor];
        alert.delegate = self;
        alert.tag = indexPath.row+1;
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, alert.width, 30)];
        view.backgroundColor = [UIColor whiteColor];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 75, 30)];
        label1.text = MyLocal(@"中心号码:");
        label1.font = [UIFont systemFontOfSize:14.0f];
        label1.textAlignment = NSTextAlignmentCenter;
        label1.backgroundColor = [UIColor clearColor];
        [view addSubview:label1];
        
        self.textField1 = [[UITextField alloc]initWithFrame:CGRectMake(90, label1.frame.origin.y, 150, 25)];
        _textField1.borderStyle = UITextBorderStyleLine;
        _textField1.keyboardType = UIKeyboardTypeNumberPad;
        _textField1.placeholder = MyLocal(@"号码为3～20位");
        [view addSubview:_textField1];
        
        [alert Show:view];
        
    }else if([title isEqualToString:MyLocal(@"远程聆听")]){
        ListenViewController *listen = [[ListenViewController alloc]init];
        [self.navigationController pushViewController:listen animated:YES];
    }
}

#pragma mark - 单选按钮 代理方法

- (void)radioButtonSelectedAtIndex:(NSUInteger)index inGroup:(NSString*)groupId{
    if ([groupId isEqualToString:@"firstgroup"]) {
        radioButtonValue1 = [NSString stringWithFormat:@"%lu",(unsigned long)index];
    } else if ([groupId isEqualToString:@"vibrationSet"]) {
        if (index == 100) {
            radioButtonValue2 = @"ON";
        } else if (index == 101){
            radioButtonValue2 = @"OFF";
        } else {
            [view1 removeFromSuperview];
        }
    } else if ([groupId isEqualToString:@"overspeedSet"]) {
        if (index == 10) {
            _overspeedType = @"0";
        } else if (index == 11){
            _overspeedType = @"1";
        }
    } else if ([groupId isEqualToString:@"pulloutSet"]) {
        if (index == 1000) {
            _pulloutType = @"0";
        } else if (index == 1001){
            _pulloutType = @"1";
        } else if (index == 1002){
            _pulloutType = @"2";
        }
    }
}

-(void)buttonClick:(UIButton*)button{
    switch (button.tag) {
        case 1000:
            //下发灵敏度设置
            [self issuedVibrate:[radioButtonValue1 intValue]+1];
            [view1 removeFromSuperview];
            break;
        case 1001:
            [view1 removeFromSuperview];
            break;
        case 2000:
            [self overspeedSet];
            [view1 removeFromSuperview];
            break;
        case 2001:
            [view1 removeFromSuperview];
            break;
        case 3000:
            //下发震动报警指令
            [self vibrationSet:radioButtonValue2];
            [view1 removeFromSuperview];
            break;
        case 3001:
            [view1 removeFromSuperview];
            break;
        case 4000:
            [self pulloutSet];
            [view1 removeFromSuperview];
            break;
        case 4001:
            [view1 removeFromSuperview];
            break;
        default:
            break;
    }
}

#pragma mark - UIAlertViewDelegate


//-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    if (textField.text.length<3 || textField.text.length>20) {
//        
//    }
//
//}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _alertView) {
        self.alertView = nil;
    }
    if (buttonIndex == 0) {
//        if (_hud) {
//            [_hud show:YES];
//        }
        
        if (alertView.tag == 1) {
//            RadioAlertView *radioAlert = (RadioAlertView *)alertView;
            // 下发灵敏度设置
//            [self issuedVibrate:radioAlert.selectIndex];
        } else if (alertView.tag == 2) {
            // 下发重启设备
            if ([[alertView textFieldAtIndex:0].text isEqualToString:[USER_DEFAULT stringForKey:@"UserPass"]] ) {
                [self issuedRestart];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:MyLocal(@"提示") message:MyLocal(@"您输入的密码错误") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
                [alertView show];
                
                [self.hud setHidden:YES];
            }
            
            return;
        } else if (alertView.tag == 3) {
            //没做大小写转换！！！！
            // 下发断油电
            if ([[alertView textFieldAtIndex:0].text isEqualToString:[USER_DEFAULT stringForKey:@"UserPass"]] ) {
                [self issuedCutOil];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:MyLocal(@"提示") message:MyLocal(@"您输入的密码错误") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
                [alertView show];
                [self.hud setHidden:YES];
            }
              
            return;
        } else if (alertView.tag == 4) {
            // 下发恢复油电
            if ([[alertView textFieldAtIndex:0].text isEqualToString:[USER_DEFAULT stringForKey:@"UserPass"]] ) {
                [self issuedRestoreOil];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:MyLocal(@"提示") message:MyLocal(@"您输入的密码错误") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
                [alertView show];
                
                [self.hud setHidden:YES];
            }
         
            return;
        } else if (alertView.tag == 5) {
            // 下发查询设备参数
            [self issuedParamQuery];
        }else if (alertView.tag == 6){
            
        }else if (alertView.tag == 9){
            //下发SOS号码同步指令
            [self SOSGet];
        } else if (alertView.tag == 11) {
            // 下发切断电源
            if ([[alertView textFieldAtIndex:0].text isEqualToString:[USER_DEFAULT stringForKey:@"UserPass"]] ) {
                [self issuedCutPower];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:MyLocal(@"提示") message:MyLocal(@"您输入的密码错误") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
                [alertView show];
                
                [self.hud setHidden:YES];
            }
            
            return;
        }  else if (alertView.tag == 12) {
            // 下发恢复电源
            if ([[alertView textFieldAtIndex:0].text isEqualToString:[USER_DEFAULT stringForKey:@"UserPass"]] ) {
                [self issuedRestorePower];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:MyLocal(@"提示") message:MyLocal(@"您输入的密码错误") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
                [alertView show];
                
                [self.hud setHidden:YES];
            }
            
            return;
        }
        
    } else if (buttonIndex == 1){
        if (alertView.tag == 6) {
            //下发联通卡的余额查询
            self.type = @"2";
            [self moneyQuery];
        } else if (alertView.tag == 7) {
            //下发远程设防指令
            self.type2 = @"1";
            [self defenseSet];
        } else if (alertView.tag == 10) {
            //自动设防/撤防
            [self defenseMode:@"0"];
        }
    } else if (buttonIndex == 2){
        if (alertView.tag == 6) {
            //下发移动卡的余额查询
            self.type = @"1";
            [self moneyQuery];
        } else if (alertView.tag == 7) {
            //下发远程撤防指令
            self.type2 = @"2";
            [self defenseSet];
        } else if (alertView.tag == 10) {
            //手动撤防撤防
            [self defenseMode:@"1"];
        }
    }
}

#pragma mark -  //---------与服务器交互----1----------

#pragma mark - WebService Action
// 下发重启指令
- (void)issuedRestart
{
    [_hud show:YES];
    
    WebService *webService = [WebService newWithWebServiceAction:@"Reset" andDelegate:self];
    webService.tag = RestartWebService;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"deviceID" andValue:_deviceID];
    
    webService.webServiceParameter = @[parameter1];
    [webService getWebServiceResult:@"ResetResult"];
}

// 下发恢复油电指令
- (void)issuedRestoreOil
{
    [_hud show:YES];
    WebService *webService = [WebService newWithWebServiceAction:@"Relay" andDelegate:self];
    webService.tag = RestoreOilWebService;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"deviceID" andValue:_deviceID];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"val" andValue:@"0"];
    
    webService.webServiceParameter = @[parameter1, parameter2];
    [webService getWebServiceResult:@"RelayResult"];
}

// 下发断油电指令
- (void)issuedCutOil
{
    [_hud show:YES];
    WebService *webService = [WebService newWithWebServiceAction:@"Relay" andDelegate:self];
    webService.tag = CutOilWebService;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"deviceID" andValue:_deviceID];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"val" andValue:@"1"];
    
    webService.webServiceParameter = @[parameter1, parameter2];
    [webService getWebServiceResult:@"RelayResult"];
}

// 下发恢复电源指令
- (void)issuedRestorePower
{
    [_hud show:YES];
    WebService *webService = [WebService newWithWebServiceAction:@"SendDeviceCommand" andDelegate:self];
    webService.tag = RestorePowerWebService;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"deviceID" andValue:_deviceID];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"Type" andValue:@"21"];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"Param1" andValue:@"0"];
    WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"Param2" andValue:@""];
    WebServiceParameter *parameter5 = [WebServiceParameter newWithKey:@"Param3" andValue:@""];
    
    webService.webServiceParameter = @[parameter1, parameter2, parameter3, parameter4, parameter5];
    [webService getWebServiceResult:@"SendDeviceCommandResult"];
}

// 下发切断电源指令
- (void)issuedCutPower
{
    [_hud show:YES];
    WebService *webService = [WebService newWithWebServiceAction:@"SendDeviceCommand" andDelegate:self];
    webService.tag = CutPowerWebService;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"deviceID" andValue:_deviceID];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"Type" andValue:@"21"];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"Param1" andValue:@"1"];
    WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"Param2" andValue:@""];
    WebServiceParameter *parameter5 = [WebServiceParameter newWithKey:@"Param3" andValue:@""];
    
    webService.webServiceParameter = @[parameter1, parameter2, parameter3, parameter4, parameter5];
    [webService getWebServiceResult:@"SendDeviceCommandResult"];
}

// 下发查询参数指令
- (void)issuedParamQuery
{
    [_hud show:YES];
    WebService *webService = [WebService newWithWebServiceAction:@"ParamSet" andDelegate:self];
    webService.tag = ParamQueryWebService;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"deviceID" andValue:_deviceID];
    
    webService.webServiceParameter = @[parameter1];
    [webService getWebServiceResult:@"ParamSetResult"];
}

//下发震动灵敏度设置
- (void)issuedVibrate:(NSInteger)grade
{
    [_hud show:YES];
    WebService *webService = [WebService newWithWebServiceAction:@"SenSorSet" andDelegate:self];
    webService.tag = VibrateSettingWebService;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"deviceID" andValue:_deviceID];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"value" andValue:[NSString stringWithFormat:@"%li", (long)(grade+2)]];// 级别分别为1234，传参需要传3456
    
    webService.webServiceParameter = @[parameter1, parameter2];
    [webService getWebServiceResult:@"SenSorSetResult"];
}

//下发余额查询指令
-(void)moneyQuery{
    [_hud show:YES];
    WebService *webService = [WebService newWithWebServiceAction:@"MoneyQuery" andDelegate:self];
    webService.tag = MoneyQueryWebService;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"deviceID" andValue:_deviceID];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"type" andValue:_type];
    
    webService.webServiceParameter = @[parameter1, parameter2];
    [webService getWebServiceResult:@"MoneyQueryResult"];
}

//下发远程设防撤防指令

-(void)defenseSet{
    [_hud show:YES];
    WebService *webService = [WebService newWithWebServiceAction:@"DefenseSet" andDelegate:self];
    webService.tag = MoneyQueryWebService;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"deviceID" andValue:_deviceID];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"type" andValue:_type2];
    
    webService.webServiceParameter = @[parameter1, parameter2];
    [webService getWebServiceResult:@"DefenseSetResult"];
}

//同步SOS号码

-(void)SOSGet{
    [_hud show:YES];
    WebService *webService = [WebService newWithWebServiceAction:@"SOSGet" andDelegate:self];
    webService.tag = MoneyQueryWebService;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"deviceID" andValue:_deviceID];
    
    webService.webServiceParameter = @[parameter1];
    [webService getWebServiceResult:@"SOSGetResult"];
}

//超速报警设置
- (void)overspeedSet
{
    [_hud show:YES];
    WebService *webService = [WebService newWithWebServiceAction:@"SendDeviceCommand" andDelegate:self];
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"deviceID" andValue:_deviceID];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"Type" andValue:@"14"];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"Param1" andValue:_commandSwitch.on ? @"1" : @"0"];
    WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"Param2" andValue:_overspeedType];
    WebServiceParameter *parameter5 = [WebServiceParameter newWithKey:@"Param3" andValue:@""];
    
    webService.webServiceParameter = @[parameter1, parameter2, parameter3, parameter4, parameter5];
    [webService getWebServiceResult:@"SendDeviceCommandResult"];
}

- (void)pulloutSet
{
    [_hud show:YES];
    WebService *webService = [WebService newWithWebServiceAction:@"SendDeviceCommand" andDelegate:self];
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"deviceID" andValue:_deviceID];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"Type" andValue:@"12"];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"Param1" andValue:_commandSwitch.on ? @"1" : @"0"];
    WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"Param2" andValue:_pulloutType];
    WebServiceParameter *parameter5 = [WebServiceParameter newWithKey:@"Param3" andValue:@""];
    
    webService.webServiceParameter = @[parameter1, parameter2, parameter3, parameter4, parameter5];
    [webService getWebServiceResult:@"SendDeviceCommandResult"];
}

//震动报警设置
-(void)vibrationSet:(NSString*)statu{
    [_hud show:YES];
    WebService *webService = [WebService newWithWebServiceAction:@"VibrationSet" andDelegate:self];
    webService.tag = VibrationSetWebService;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"deviceID" andValue:_deviceID];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"Status" andValue:statu];
    
    webService.webServiceParameter = @[parameter1,parameter2];
    [webService getWebServiceResult:@"VibrationSetResult"];
}

//设防模式
-(void)defenseMode:(NSString*)statu{
    [_hud show:YES];
    WebService *webService = [WebService newWithWebServiceAction:@"DefenseMode" andDelegate:self];
    webService.tag = DefenseModeWebService;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"deviceID" andValue:_deviceID];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"type" andValue:statu];
    
    webService.webServiceParameter = @[parameter1,parameter2];
    [webService getWebServiceResult:@"DefenseModeResult"];
}

#pragma mark -  //---------与服务器交互----2----------

// 根据commandID调用接口判断设备是否设置成功
- (void)getCommandResponse
{
    NSDate *date = [NSDate date];
    if ([date timeIntervalSinceDate:_startGetResponseTime] > 60.0) {
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
    webService.tag = ResponseWebService;
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
    if ([theWebService tag] == ResponseWebService) {
        // 如果是查询设备响应，
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
        }else if ([[theWebService soapResults] isEqualToString:@"1009"]) {
            if (_hud) {
                [_hud hide:YES];
            }
            // 下发失败
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:MyLocal(@"设置失败") message:MyLocal(@"下发失败") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles:nil, nil];
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

-(void)DefaultButton:(id)sender
{
    _textField1.text = @"13.2";
    _textField2.text = @"13.5";
}

-(void)DefaultButton1:(id)sender
{
    _textField1.text = @"10";
}

-(void)DefaultButton2:(id)sender
{
    _textField1.text = @"10";
    _textField2.text = @"180";
    _textField3.text = @"30";
}

#pragma mark - HYAlertViewDelegate
- (BOOL)didSelectedOKDisMiss:(HYAlertView *)alertView
{
    if ([alertView.title isEqualToString:MyLocal(@"ACC电压设置")]) {
        NSString *text1 = _textField1.text;
        NSString *text2 = _textField2.text;
        if ([text1 intValue] < 9 || [text1 intValue] > 80) {
            return NO;
        }
        if ([text2 intValue] < 9 || [text2 intValue] > 80) {
            return NO;
        }
        if ([text1 intValue] < [text2 intValue]) {
            return NO;
        }
    }else if ([alertView.title isEqualToString:MyLocal(@"延时设防设置")]) {
        NSString *text1 = _textField1.text;
        if ([text1 intValue] < 1 || [text1 intValue] > 60) {
            return NO;
        }
    }else if ([alertView.title isEqualToString:MyLocal(@"震动检测时间")]) {
        NSString *text1 = _textField1.text;
        NSString *text2 = _textField2.text;
        NSString *text3 = _textField3.text;
        if ([text1 intValue] < 10 || [text1 intValue] > 300) {
            return NO;
        }else if ([text2 intValue] < 10 || [text2 intValue] > 300) {
            return NO;
        }else if ([text3 intValue] < 1 || [text3 intValue] > 3000) {
            return NO;
        }
    }
    return YES;
}

- (void)didSelectedOK:(HYAlertView *)alertView
{
    NSString *type = @"";
    NSString *param1 = @"";
    NSString *param2 = @"";
    NSString *param3 = @"";
    if ([alertView.title isEqualToString:MyLocal(@"ACC电压设置")]) {
        type = @"29";
        NSString *text1 = _textField1.text;
        NSString *text2 = _textField2.text;
        if ([text1 intValue] < 9 || [text1 intValue] > 80) {
            [SVProgressHUD showErrorWithStatus:MyLocal(@"输入的电压范围有误") duration:2];
            return;
        }else if ([text2 intValue] < 9 || [text2 intValue] > 80) {
            [SVProgressHUD showErrorWithStatus:MyLocal(@"输入的电压范围有误") duration:2];
            return;
        }else if ([text1 intValue] > [text2 intValue]) {
            [SVProgressHUD showErrorWithStatus:MyLocal(@"熄火电压大于点火电压") duration:2];
            return;
        }
//        param1 = [NSString stringWithFormat:@"%.0f",[text1 floatValue]*10.0];
//        param2 = [NSString stringWithFormat:@"%.0f",[text2 floatValue]*10.0];
        param1 = text1;
        param2 = text2;
    }else if ([alertView.title isEqualToString:MyLocal(@"延时设防设置")]) {
        type = @"31";
        NSString *text1 = _textField1.text;
        if ([text1 intValue] < 1 || [text1 intValue] > 60) {
            [SVProgressHUD showErrorWithStatus:MyLocal(@"输入的时间范围有误") duration:2];
            return;
        }
        param1 = text1;
    }else if ([alertView.title isEqualToString:MyLocal(@"震动检测时间")]) {
        type = @"30";
        NSString *text1 = _textField1.text;
        NSString *text2 = _textField2.text;
        NSString *text3 = _textField3.text;
        if ([text1 intValue] < 10 || [text1 intValue] > 300) {
            [SVProgressHUD showErrorWithStatus:MyLocal(@"输入的检测时间范围有误") duration:2];
            return;
        }else if ([text2 intValue] < 10 || [text2 intValue] > 300) {
            [SVProgressHUD showErrorWithStatus:MyLocal(@"输入的报警延时范围有误") duration:2];
            return;
        }else if ([text3 intValue] < 1 || [text3 intValue] > 3000) {
            [SVProgressHUD showErrorWithStatus:MyLocal(@"输入的报警间隔范围有误") duration:2];
            return;
        }
        param1 = text1;
        param2 = text2;
        param3 = text3;
    }else if ([alertView.title isEqualToString:MyLocal(@"中心号码")]) {
        type = @"32";
        NSString *text1 = _textField1.text;
        if (_textField1.text.length == 0) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(MyLocal(@"请输入3到20位号码"), nil) duration:2];
            return;
        }
        param1 = text1?:@"";
    }
    [self SendCommandToDevices:type Param1:param1 Param2:param2 Param3:param3];
}

-(void)SendCommandToDevices:(NSString *)type Param1:(NSString *)Param1 Param2:(NSString *)Param2 Param3:(NSString *)Param3
{
    [_hud show:YES];
    WebService *webService = [WebService newWithWebServiceAction:@"SendDeviceCommand" andDelegate:self];
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"deviceID" andValue:_deviceID];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"Type" andValue:type];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"Param1" andValue:Param1];
    WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"Param2" andValue:Param2];
    WebServiceParameter *parameter5 = [WebServiceParameter newWithKey:@"Param3" andValue:Param3];
    
    webService.webServiceParameter = @[parameter1, parameter2, parameter3, parameter4, parameter5];
    [webService getWebServiceResult:@"SendDeviceCommandResult"];
}

//-(void)SendCommandToDevices:(NSString *)cmdType CmdValue:(NSString *)cmdValue
//{
//    [SVProgressHUD showWithStatus:NSLocalizedString(@"App_Loading", nil)];
//    NSDictionary *paramaters = [NSDictionary dictionaryWithObjects:@[UserInfo.didSelectedDevice.ID,UserInfo.didSelectedDevice.model,cmdType,cmdValue] forKeys:@[@"DeviceID",@"Type",@"Param1",@"Param2",@"Param3"]];
//    LMHttpPost *httpPost = [[LMHttpPost alloc]init];
//    [httpPost getResponseWithName:@"SendDeviceCommand" parameters:paramaters success:^(id responseObject) {
//        NSLog(@"SendDeviceCommandReturn:%@",responseObject);
//        NSString *str = (NSString *)responseObject;
//        if ([str integerValue] > 10) {
//            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Issue_send_success", nil) duration:3];
//        }else if([str isEqualToString:@"0"]){
//            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Issue_send_Network anomaly", nil) duration:3];
//            
//        }else if([str isEqualToString:@"2"]){
//            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Issue_send_failure", nil) duration:3];
//            
//        }
//    } failure:^(NSError *error) {
//        [SVProgressHUD dismiss];
//        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"App_Tips_NetworkFailMessage", nil) duration:3];
//    }];
//}

@end
