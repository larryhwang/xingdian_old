//
//  NoticeSettingViewController.m
//  途强汽车在线
//
//  Created by apple on 15/3/16.
//  Copyright (c) 2015年 thinkrace. All rights reserved.
//

#import "NoticeSettingViewController.h"
#import "ModelDatePicker.h"
#import "SVProgressHUD.h"
#import "LMHttpPost.h"
#import "UserPush.h"

@interface NoticeSettingViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) UISwitch *Switch1_1;
@property (strong, nonatomic) UISwitch *Switch2_1;
@property (strong, nonatomic) UISwitch *Switch2_2;
@property (strong, nonatomic) UISwitch *Switch3_1;
@property (strong, nonatomic) UITextField *startText;
@property (strong, nonatomic) UITextField *endText;
@property (strong, nonatomic) UserPush *userPush;
@property (assign,nonatomic) NSInteger a;
@property (assign, nonatomic) BOOL b;

@end

@implementation NoticeSettingViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = MyLocal(@"通知中心");
        self.titleArray = @[@[NSLocalizedString(@"接收新消息通知", nil)],@[NSLocalizedString(@"声音", nil)/*,NSLocalizedString(@"振动", nil)*/],@[NSLocalizedString(@"夜间免打扰", nil)]];
        _b = YES;
        _a  = 1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 11, 21)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"j.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, 355)];
    _tableView.scrollEnabled = YES;
    _tableView.allowsSelection = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:_tableView];
    
    [self LoadSwitchView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [self UserPushForType:@"2" IsPush:@"0" Sound:@"0" Shock:@"0" AllDayPush:@"0" StarTime:@"" EndTime:@""];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
}


-(void)LoadSwitchView
    {
        self.Switch1_1 = [[UISwitch alloc]init];
        //    [_Switch1_1 setOnImage:ImageNamed(@"on")];
        //    [_Switch1_1 setOffImage:ImageNamed(@"off")];
        [_Switch1_1 addTarget:self action:@selector(SwitchON:) forControlEvents:UIControlEventTouchUpInside];
        _Switch1_1.onTintColor = RGBCOLOR(69, 151, 204, 1);
        self.Switch2_1 = [[UISwitch alloc]init];
        //    [_Switch2_1 setOnImage:ImageNamed(@"on")];
        //    [_Switch2_1 setOffImage:ImageNamed(@"off")];
        [_Switch2_1 addTarget:self action:@selector(SwitchON:) forControlEvents:UIControlEventTouchUpInside];
        _Switch2_1.onTintColor = RGBCOLOR(69, 151, 204, 1);
        self.Switch2_2 = [[UISwitch alloc]init];
        //    [_Switch2_2 setOnImage:ImageNamed(@"on")];
        //    [_Switch2_2 setOffImage:ImageNamed(@"off")];
        [_Switch2_2 addTarget:self action:@selector(SwitchON:) forControlEvents:UIControlEventTouchUpInside];
        _Switch2_2.onTintColor = RGBCOLOR(69, 151, 204, 1);
        self.Switch3_1 = [[UISwitch alloc]init];
        //    [_Switch3_1 setOnImage:ImageNamed(@"on")];
        //    [_Switch3_1 setOffImage:ImageNamed(@"off")];
        [_Switch3_1 addTarget:self action:@selector(SwitchON:) forControlEvents:UIControlEventTouchUpInside];
        _Switch3_1.onTintColor = RGBCOLOR(69, 151, 204, 1);
        
        self.startText = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 80, 30)];
        _startText.delegate = self;
        _startText.text = @"22:00";
        _startText.textAlignment = NSTextAlignmentRight;
        
        self.endText = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 80, 30)];
        _endText.delegate = self;
        _endText.text = @"08:00";
        _endText.textAlignment = NSTextAlignmentRight;
}

-(void)SwitchON:(UISwitch *)switcha_a
{
    NSString *isPush = @"";
    NSString *sound = @"";
    NSString *shock = @"";
    NSString *allDayPush = @"";
    if (_Switch1_1.on) {
        isPush = @"1";
    }else {
        isPush = @"0";
    }
    if (_Switch2_1.on) {
        sound = @"1";
    }else {
        sound = @"0";
    }
    if (_Switch2_2.on) {
        shock = @"1";
    }else {
        shock = @"0";
    }
    if (_Switch3_1.on) {
        allDayPush = @"0";
        if(switcha_a == _Switch3_1) {
            self.titleArray = @[@[NSLocalizedString(@"接收新消息通知", nil)],@[NSLocalizedString(@"声音", nil)/*,NSLocalizedString(@"振动", nil)*/],@[NSLocalizedString(@"夜间免打扰", nil),NSLocalizedString(@"开始时间", nil),NSLocalizedString(@"结束时间", nil)]];
            //        [_tableView reloadData];
            NSIndexPath *index1 = [NSIndexPath indexPathForRow:1 inSection:2];
            NSIndexPath *index2 = [NSIndexPath indexPathForRow:2 inSection:2];
            [_tableView insertRowsAtIndexPaths:@[index1,index2] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }else {
        allDayPush = @"1";
        if(switcha_a == _Switch3_1) {
            self.titleArray = @[@[NSLocalizedString(@"接收新消息通知", nil)],@[NSLocalizedString(@"声音", nil)/*,NSLocalizedString(@"振动", nil)*/],@[NSLocalizedString(@"夜间免打扰", nil)]];
            //        [_tableView reloadData];
            NSIndexPath *index1 = [NSIndexPath indexPathForRow:1 inSection:2];
            NSIndexPath *index2 = [NSIndexPath indexPathForRow:2 inSection:2];
            [_tableView deleteRowsAtIndexPaths:@[index1,index2] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    [self UserPushForType:@"1" IsPush:isPush Sound:sound Shock:shock AllDayPush:allDayPush StarTime:_startText.text?:@"22:00" EndTime:_endText.text?:@"08:00"];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)reloadView:(NSDictionary *)json
{
    if ([_userPush.allDayPush isEqualToString:@"0"]) {
        _startText.text=json[@"StartTime"];
        _endText.text=json[@"EndTime"];
        if ([json[@"StartTime"] length ]==0) {
            _startText.text=@"22:00";
        }if ([json[@"EndTime"] length ]==0) {
            _endText.text=@"08:00";
        }
    }
    if ([_userPush.allDayPush isEqualToString:@"1"]) {
        _b=NO;
    }
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   //  return 1;
   return _titleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray *)[_titleArray objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    if (indexPath.section == 0) {
        cell.accessoryView = _Switch1_1;
    }else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.accessoryView = _Switch2_1;
        }else if (indexPath.row == 1) {
            cell.accessoryView = _Switch2_2;
        }
    }else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.accessoryView = _Switch3_1;
        }else if (indexPath.row == 1) {
            cell.accessoryView = _startText;
        }else if (indexPath.row == 2) {
            cell.accessoryView = _endText;
        }
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = _titleArray[indexPath.section][indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:20];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 24;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = RGBCOLOR(237, 237, 237, 1);
    view.layer.masksToBounds = YES;
    return view;
}

- (void)UserPushForType:(NSString *)type IsPush:(NSString *)isPush Sound:(NSString *)sound Shock:(NSString *)shock AllDayPush:(NSString *)allDayPush StarTime:(NSString *)starTime EndTime:(NSString *)endTime
{
    NSInteger loginType = [USER_DEFAULT integerForKey:@"LoginType"];
    NSString *userID = [USER_DEFAULT objectForKey:@"ReturnID"];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"加载中...", nil)];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[type,  userID, [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:loginType+1]], isPush, sound, shock, allDayPush, @"0", starTime, endTime] forKeys:@[@"Type", @"Id", @"LoginType", @"IsPush",@"Sound", @"Shock", @"AllDayPush", @"Acc",@"StarTime", @"EndTime"]];
    LMHttpPost *httpPost = [[LMHttpPost alloc] init];
    [httpPost getResponseWithName:@"UserPush" parameters:parameters success:^(id responseObject) {
        NSLog(@"UserPushReturn:%@",responseObject);
        NSDictionary *json = (NSDictionary *)responseObject;
        if ([json[@"state"] isEqualToString:@"10000"]) {
            if ([type isEqualToString:@"2"]) {
                UserPush *userPush = [[UserPush alloc]initWithUserPush:json];
                _userPush = userPush;
                if (_a==1) {
                    [self reloadView:json];
                }
                _a=2;
                [self SetNotificationPush];
            }
            [SVProgressHUD dismiss];
        }else if ([json[@"state"] isEqualToString:@"20005"]) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"已设置", nil) duration:1.5];
        }else if ([json[@"state"] isEqualToString:@"10004"]) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"id无效", nil) duration:1.5];
        }else if ([json[@"state"] isEqualToString:@"20004"]) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"操作失败", nil) duration:1.5];
        }else if ([json[@"state"] isEqualToString:@"20001"]) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"参数无效", nil) duration:1.5];
        }else {
            [SVProgressHUD dismiss];
        }
    }failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络连接异常，请稍后再试", nil) duration:1.5];
    }];
}

-(void)SetNotificationPush
{
    if ([_userPush.isPush isEqualToString:@"1"]) {
        [_Switch1_1 setOn:YES animated:YES];
    }else {
        [_Switch1_1 setOn:NO animated:YES];
    }
    
    
    if ([_userPush.sound isEqualToString:@"1"]) {
        [_Switch2_1 setOn:YES animated:YES];
    }else {
        [_Switch2_1 setOn:NO animated:YES];
    }
//        if ([_userPush.shock isEqualToString:@"1"]) {
//            [_Switch2_2 setOn:YES animated:YES];
//        }else {
//            [_Switch2_2 setOn:NO animated:YES];
//        }
    if ([_userPush.allDayPush isEqualToString:@"0"]) {
        [_Switch3_1 setOn:YES animated:YES];
        self.titleArray = @[@[NSLocalizedString(@"接收新消息通知", nil)],@[NSLocalizedString(@"声音", nil)],@[NSLocalizedString(@"夜间免打扰", nil),NSLocalizedString(@"开始时间", nil),NSLocalizedString(@"结束时间", nil)]];
             //   [_tableView reloadData];
        NSIndexPath *index1 = [NSIndexPath indexPathForRow:1 inSection:2];
        NSIndexPath *index2 = [NSIndexPath indexPathForRow:2 inSection:2];
        [_tableView insertRowsAtIndexPaths:@[index1,index2] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else {
        [_Switch3_1 setOn:NO animated:YES];
    }
    [SVProgressHUD dismiss];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"HH:mm";
    ModelDatePicker *datePicker = [[ModelDatePicker alloc] initWithTitle:nil CompleteButton:^(NSDate *selectedDate){
        if (selectedDate) {
            textField.text = [dateFormatter stringFromDate:selectedDate];
            [self SwitchON:nil];
        }
    } mode:UIDatePickerModeTime];
    [datePicker show];
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
